//
//  Database.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation














///	MARK:
///	MARK:	Public Interfaces
///	MARK:

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
	
	private var	_core			=	Core.Database()
	private var	_liveTableNames	=	[] as [String]
	private var	_authoriser		=	nil as Core.Database.AuthorisationRoutingTable?
	
	private let	_savepoint_name_gen:() -> String
	
//	private lazy var	optimisation:Optimisation	=	Optimisation({ self.prepare($0) })
	
	private lazy var	_tables:TableCollection	=	TableCollection(owner: self)
	
	
	
	
	
	////////////////////////////////
	
	public convenience init(location:Location) {
		self.init(location: location, editable: false)
	}
	public convenience init(location:Location, editable:Bool) {
		self.init(location: location, editable: editable, atomicUnitNameGenerator: Default.Generator.uniqueAtomicUnitName)
	}
	
	///	:param:	atomicUnitNameGenerator		specifies a name generator which will generate names for SAVEPOINT statement.
	public required init(location:Location, editable:Bool, atomicUnitNameGenerator:()->String) {
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
		
		_installDebuggingGuidanceAuthoriser()
	}
	
	deinit {
		precondition(_core.null == false)
		
//		optimisation	=	Optimisation()
		
		_uninstallDebuggingGuidanceAuthoriser()
		_core.close()
		
		assert(_core.null == true)
	}
	
	
	
	
	
	
	
	public enum Location {
		case Memory
		case TemporaryFile
		case PersistentFile(path:String)
	}
	
}






















///	MARK:
///	MARK:	Public Interfaces
///	MARK:





///	MARK:	Foundational Features
extension Database {
	
	public var tables:TableCollection {
		get {
			return	_tables
		}
	}
	
	
	
	
	
	///	Produces prepared statement.
	///	You need to bound parameters to execute them later.
	///
	///	It is caller's responsibility to execute prepared statement to apply
	///	commands in the code.
	///
	///	Produced statements will be invalidated when this database object
	///	deinitialises.
	public func prepare(code:String) -> Statement {
		let	(ss1, tail)	=	_core.prepare(code)
		
		precondition(ss1.count == 1, "You need to provide only one statement as a command. Multiple statements are not supported. If you need to run multiple statements, split them into multiple strings, and call `prepare` multiple times.")
		precondition(tail == "", "The SQL command was not fully consumed. Remaining part = \(tail)")
		let	s1	=	ss1[0]
		let	s2	=	Statement(database: self, core: s1)
		return	s2
	}
	func compile(code:String) -> Statement {
		return	prepare(code)
	}
	
	
	

	///	Apply transaction to database.
	public func apply<T>(query:QueryExpressible) -> T {
		return	apply { return self.run(query) as T }
	}
	
	///	Apply transaction to database.
	public func apply(transaction:()->()) {
		if _core.autocommit {
			performTransactionSession(transaction: transaction)
		} else {
			performSavepointSession(transaction: transaction, name: _savepoint_name_gen())
		}
	}
	///	Apply transaction to database.
	public func apply<T>(transaction:()->T) -> T {
		if _core.autocommit {
			return	performTransactionSession(transaction: transaction)
		} else {
			return	performSavepointSession(transaction: transaction, name: _savepoint_name_gen())
		}
	}
	
	///	Apply transaction to database only when the transaction returns `true`.
	public func applyConditionally<T>(transaction:()->T?) -> T? {
		if _core.autocommit {
			return	performTransactionSessionConditionally(transaction: transaction)
		} else {
			return	_performSavepointSessionConditionally(transaction: transaction, name: _savepoint_name_gen())
		}
	}
	
}

















































///	MARK:
///	MARK:	Internal/Private Implementations
///	MARK:

///	MARK:	Internal State Query
extension Database {
	
	var hasExplicitTransaction:Bool {
		get {
			return	_core.autocommit == false
		}
	}
	
}





///	MARK:	Optimisations
extension Database {
	
	private struct Optimisation {
		struct CommonStatementCache {
			let	beginTransaction	=	{} as ()->()
			let	commitTransaction	=	{} as ()->()
			let	rollbackTransaction	=	{} as ()->()
		}
		let	commonStatementCache	=	CommonStatementCache()
		init() {
		}
		init(_ prepare:(cmd:String)->Statement) {
			func make1(cmd:String) -> ()->() {
				let	stmt1	=	prepare(cmd: cmd)
				return	{ stmt1.execute().all() }
			}
			commonStatementCache	=
				CommonStatementCache(
					beginTransaction: make1("BEGIN TRANSACTION;"),
					commitTransaction: make1("COMMIT TRANSACTION;"),
					rollbackTransaction: make1("ROLLBACK TRANSACTION;"))
		}
	}
}
























///	MARK:	Table Proxy Object Management
extension Database {
	internal func notifyBornOfTableForName(n:String) {
		_liveTableNames.append(n)
	}
	internal func notifyDeathOfTableForName(n:String) {
		_liveTableNames	=	_liveTableNames.filter {$0 != n}
	}
	
	private func _installDebuggingGuidanceAuthoriser() {
		if !Debug.mode { return }
		
		let prohibitNameForLiveTables	=	{ [unowned self](databaseName:String, tableName:String) -> Bool in
			let	ok	=	self._liveTableNames.filter {$0 == tableName}.count == 0
			assert(ok, "Altering or dropping a table is not allowed while a `Table` object linked to the table is alive.")
			return	ok
		}
		_authoriser	=	Core.Database.AuthorisationRoutingTable(alterTable: prohibitNameForLiveTables, dropTable: prohibitNameForLiveTables)
		_core.setAuthorizer(_authoriser)
	}
	private func _uninstallDebuggingGuidanceAuthoriser() {
		if !Debug.mode { return }
		
		_core.setAuthorizer(nil)
	}
}

































///	MARK:	Transaction Execution Helpers
extension Database {
	
	
	
	///	Run an atomic transaction which always commits.
	private func performTransactionSession<T>(transaction tx:()->T) -> T {
		func tx2() -> T? { return tx() as T? }		//	This `as` is very important.
		if let v1 = performTransactionSessionConditionally(transaction: tx2) {
			return	v1
		} else {
			fatalError("Transaction failed unexpectedly.")
		}
	}
	
	///	Run a nested transaction which always comits using `SAVEPOINT`.
	private func performSavepointSession<T>(transaction tx:()->T, name n:String) -> T {
		func tx2() -> T? { return tx() as T? }		//	This `as` is very important.
		if let v1 = _performSavepointSessionConditionally(transaction: tx2, name:n) {
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
		
		runWithoutExplicitTransactionCheck("BEGIN TRANSACTION;", parameters: [])
//		optimisation.commonStatementCache.beginTransaction()
		assert(_core.autocommit == false)
		
		if let v = tx() {
			runWithoutExplicitTransactionCheck("COMMIT TRANSACTION;", parameters: [])
//			optimisation.commonStatementCache.commitTransaction()
			assert(_core.autocommit == true)
			return	v
		} else {
			runWithoutExplicitTransactionCheck("ROLLBACK TRANSACTION;", parameters: [])
//			optimisation.commonStatementCache.rollbackTransaction()
			assert(_core.autocommit == true)
			return	nil
		}
	}
	///	Run a nested transaction using `SAVEPOINT`.
	private func _performSavepointSessionConditionally<T>(transaction tx:()->T?, name n:String) -> T? {
		precondition(n != "", "The atomic transaction subunit name shouldn't be empty.")
		precondition(_core.null == false)
		precondition(_core.autocommit == false)
		
		run(Query.Language.Syntax.SavepointStmt(name: Query.Identifier(n).description).description)
		if let v = tx() {
			run(Query.Language.Syntax.ReleaseStmt(name: Query.Identifier(n).description).description)
			return	v
		} else {
			run(Query.Language.Syntax.RollbackStmt(name: Query.Identifier(n).description).description)
			return	nil
		}
	}
	
	
	
	

}


















































