//
//  Database.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation

///	`execute` (private methods) executes a query as is.
///	`run` (public methods) executes asserts for a transaction wrapping.
///
///	This class uses unique `SAVEPOINT` name generator
///	to support nested transaction. If you perform the
///	`SAVEPOINT` operation youtself manually, the savepoint 
///	name may be duplicated and derive unexpected result. 
///	To precent this situation, supply your own 
///	implementation of savepoint name generator at 
///	initializer.
public class Database {
	////	Types.
	
//	public typealias	ParameterList	=	[String:Value]
	public typealias	RowIterator		=	(row:Row)->()
	
//	public typealias	DataHandler		=	(data:GeneratorOf<Row>)->()
//	public typealias	ErrorHandler	=	(message:String)->()
	
	public enum Location {
		case Memory
		case TemporaryFile
		case PersistentFile(path:String)
	}
	

	private struct Optimisation {
		struct CommonStatementCache {
			let	beginTransaction	=	{} as ()->()
			let	commitTransaction	=	{} as ()->()
			let	rollbackTransaction	=	{} as ()->()
		}
		let	commonStatementCache	=	CommonStatementCache()
		init() {
		}
		init(_ prepare:(cmd:String)->StatementList) {
			func make1(cmd:String) -> ()->() {
				let	stmts1	=	prepare(cmd: cmd)
				return	{
					let	exec1	=	stmts1.execute(parameters: [])
					while let _ = exec1.next() {
					}
				}
			}
			commonStatementCache	=
				CommonStatementCache(
					beginTransaction: make1("BEGIN TRANSACTION;"),
					commitTransaction: make1("COMMIT TRANSACTION;"),
					rollbackTransaction: make1("ROLLBACK TRANSACTION;"))
		}
	}
	
	private lazy var	optimisation:Optimisation	=	Optimisation({ self.prepare(code: $0) })
	
	
	
	
	
	
	
	
	
	
	
	////	Slots.
	
	private let	_savepoint_name_gen:() -> String
	private var	_core					=	Core.Database()
	
	
	
	
	
	
	
	////	Methods.
	
	
	public convenience init(location:Location)
	{
		self.init(location: location, editable: false)
	}
	public convenience init(location:Location, editable:Bool)
	{
		self.init(location: location, editable: editable, atomicUnitNameGenerator: Default.Generator.uniqueAtomicUnitName)
	}
	
	///	:param:	atomicUnitNameGenerator		specifies a name generator which will generate names for SAVEPOINT statement.
	public required init(location:Location, editable:Bool, atomicUnitNameGenerator:()->String)
	{
		//	TODO:	Uncomment this. Commented due to weird compiler error.
//		assert(_core.null == true)
		
		func resolve_name() -> String
		{
			func passAssertingValidPersistentFilePath(path:String) -> String
			{
				assert(path != "")
				assert(path != ":memory:")
				return	path
			}
			
			switch location
			{
			case let Location.Memory:						return	":memory:"
			case let Location.TemporaryFile:				return	""
			case let Location.PersistentFile(path: path):	return	passAssertingValidPersistentFilePath(path)
			}
		}
		func resolve_flag() -> Core.Database.OpenFlag
		{
			if editable == false { return Core.Database.OpenFlag.Readonly }
			return	Core.Database.OpenFlag.ReadWrite
		}
		
		_savepoint_name_gen	=	atomicUnitNameGenerator
		_core.open(resolve_name(), flags: resolve_flag())
		
		assert(_core.null == false)
	}
	deinit
	{
		precondition(_core.null == false)
		
		optimisation	=	Optimisation()
		_core.close()
		
		assert(_core.null == true)
	}
	
	
	
	
	
	
	
	
	
	///	Apply transaction to database.
	public func apply(transaction tx:()->()) {
		if _core.autocommit {
			performTransactionSession(transaction: tx)
		} else {
			performSavepointSession(transaction: tx, name: _savepoint_name_gen())
		}
	}
	///	Apply transaction to database.
	public func apply<T>(transaction tx:()->T) -> T {
		if _core.autocommit {
			return	performTransactionSession(transaction: tx)
		} else {
			return	performSavepointSession(transaction: tx, name: _savepoint_name_gen())
		}
	}
	
	///	Apply transaction to database only when the transaction returns `true`.
	public func applyConditionally<T>(transaction tx:()->T?) -> T? {
		if _core.autocommit {
			return	performTransactionSessionConditionally(transaction: tx)
		} else {
			return	performSavepointSessionConditionally(transaction: tx, name: _savepoint_name_gen())
		}
	}
	
	
	
	
	
	
	
	
	
	
	///	Get schema informations.
	public func schema() -> Database.Schema {
		return	Schema(database: self)
	}
	///	Get table object which provides table access features.
	public func table(name n:String) -> Database.Table {
		return	Table(database: self, name: n)
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	///	Run an atomic transaction which always commits.
	private func performTransactionSession<T>(transaction tx:()->T) -> T {
		if let v1 = performTransactionSessionConditionally(transaction: tx) {
			return	v1
		} else {
			fatalError("Transaction failed unexpectedly.")
		}
	}
	
	///	Run a nested transaction which always comits using `SAVEPOINT`.
	private func performSavepointSession<T>(transaction tx:()->T, name n:String) -> T {
		if let v1 = performSavepointSessionConditionally(transaction: tx, name:n) {
			return	v1
		} else {
			fatalError("Transaction failed unexpectedly.")
		}
	}
	
	///	Run an atomic transaction.
	///	Return `nil` in the transaction closure to rollback the transaction.
	private func performTransactionSessionConditionally<T>(transaction tx:()->T?) -> T? {
		precondition(_core.null == false)
		precondition(_core.autocommit == true)
		
//		prepare(code: "BEGIN TRANSACTION;").execute(parameters: [:]).all()
		optimisation.commonStatementCache.beginTransaction()
		assert(_core.autocommit == false)
		
		if let v = tx() {
//			prepare(code: "COMMIT TRANSACTION;").execute(parameters: [:]).all()
			optimisation.commonStatementCache.commitTransaction()
			assert(_core.autocommit == true)
			return	v
		} else {
//			prepare(code: "ROLLBACK TRANSACTION;").execute(parameters: [:]).all()
			optimisation.commonStatementCache.rollbackTransaction()
			assert(_core.autocommit == true)
			return	nil
		}
	}
	///	Run a nested transaction using `SAVEPOINT`.
	private func performSavepointSessionConditionally<T>(transaction tx:()->T?, name n:String) -> T? {
		precondition(n != "", "The atomic transaction subunit name shouldn't be empty.")
		precondition(_core.null == false)
		precondition(_core.autocommit == false)
		
		run(query: Query.Language.Syntax.SavepointStmt(name: Query.Identifier(name: n).description).description)
		if let v = tx() {
			run(query: Query.Language.Syntax.ReleaseStmt(name: Query.Identifier(name: n).description).description)
			return	v
		} else {
			run(query: Query.Language.Syntax.RollbackStmt(name: Query.Identifier(name: n).description).description)
			return	nil
		}
	}
	
	
	
	
	///	Produces prepared statements.
	///	You need to bound parameters to execute them.
	///
	///	It is caller's responsibility to execute prepared statement to apply
	///	commands in the code.
	///
	///	Produced statements will be invalidated when this database object
	///	deinitialises.
	func prepare(code c:String) -> StatementList {
		println("Database.prepare: \(c)")

		let	(ss1, tail)	=	_core.prepare(c)
		
		if tail != "" {
			Core.Common.crash(message: "The SQL command was not fully consumed. Remaining part = \(tail)")
		}
		
		let	ss2	=	ss1.map { Statement(database: self, core: $0) }	//		({ (n:Core.Statement) -> Statement in return Statement(database: self, core: n )})
		return	StatementList(ss2)
	}
}






























extension Database {
	
	///	Execute the query and captures snapshot of all values of resulting rows.
	func snapshot(query x:Query.Expression) -> [[String:Value]] {
		var	m	=	[] as [[String:Value]]
		func tx() {
			m	=	run(query: x)
		}
		apply(transaction: tx)
		return	m
	}
	
	
	
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	public func run(query x:Query.Expression) -> [[String:Value]] {
		assert(_core.autocommit == false)
//		
//		var	m	=	[String:Value]()
//		for mapping in x.parameters {
//			m[mapping.name]	=	mapping.value()
//		}
//		
//		Debug.log(x.code)
//		Debug.log(m)
//		
		return	prepare(code: x.code).execute(parameters: x.parameters).all()
	}
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	public func run(query q:QueryExpressible) -> [[String:Value]] {
		return	run(query: q.express())
	}
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	public func run(query c:String) -> [[String:Value]] {
		return	run(query: Query.Expression(code: c, parameters: []))
	}
	//	public func run(query c:String) {
	//		return	run(query: Query.Expression(code: c, parameters: []))
	//	}
	
	
	
}










extension Database {
	
	public struct Default {
		public struct Generator {
			///	Maximum resolution is `1/(Int.max-1)` per a second.
			///	That's the hard limit of this algorithm. If you need something
			///	better, you have to make and specify your own generator on initializer
			///	of `Database` class.
			public static func uniqueAtomicUnitName() -> String {
				struct deduplicator {
					var	lastSeed			=	0
					var	duplicationCount	=	0
					
					mutating func stepOne() -> String {
						let	t1	=	Int(NSDate().timeIntervalSince1970)
						if t1 == lastSeed {
							precondition(duplicationCount < Int.max)
							duplicationCount	+=	1
						} else {
							lastSeed			=	t1
							duplicationCount	=	0
						}
						return	"eonil__sqlite3__\(lastSeed)__\(duplicationCount)"
					}
					
					static var	defaultInstance	=	deduplicator()
				}
				
				return	deduplicator.defaultInstance.stepOne()
			}
		}
	}
}


