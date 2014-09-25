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
public class Database
{
	public typealias	ParameterList	=	[String:Value]
	public typealias	RowIterator		=	(row:Row)->()
	
//	public typealias	DataHandler		=	(data:GeneratorOf<Row>)->()
//	public typealias	ErrorHandler	=	(message:String)->()
	
	public typealias	SuccessHandler	=	(data:GeneratorOf<Row>)->()
	public typealias	FailureHandler	=	(message:String)->()
	
	public enum Location
	{
		case Memory
		case TemporaryFile
		case PersistentFile(path:String)
	}
	
	public convenience init(location:Location)
	{
		self.init(location: location, mutable: false)
	}
	public convenience init(location:Location, mutable:Bool)
	{
		self.init(location: location, mutable: mutable, atomicUnitNameGenerator: Default.Generator.uniqueAtomicUnitName)
	}
	
	///	:param:	atomicUnitNameGenerator		specifies a name generator which will generate names for SAVEPOINT statement.
	public required init(location:Location, mutable:Bool, atomicUnitNameGenerator:()->String)
	{
		assert(_core.null == true)
		
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
			if mutable == false { return Core.Database.OpenFlag.Readonly }
			return	Core.Database.OpenFlag.ReadWrite
		}
		
		_savepoint_name_gen	=	atomicUnitNameGenerator
		_core.open(resolve_name(), flags: resolve_flag())
		
		assert(_core.null == false)
	}
	deinit
	{
		precondition(_core.null == false)
		
		_core.close()
		
		assert(_core.null == true)
	}
	
	
	
	
	
	
	
	
	
	///	Apply transaction to database.
	public func apply(transaction tx:()->())
	{
		if _core.autocommit
		{
			performTransactionSession(transaction: tx)
		}
		else
		{
			performSavepointSession(transaction: tx, name: _savepoint_name_gen())
		}
	}
	
	///	Apply transaction to database.
	public func applyConditionally(transaction tx:()->Bool) -> Bool
	{
		if _core.autocommit
		{
			return	performTransactionSessionConditionally(transaction: tx)
		}
		else
		{
			return	performSavepointSessionConditionally(transaction: tx, name: _savepoint_name_gen())
		}
	}
	
	
	
	
	
	
	
	
	///	Executes a single query within a transaction.
	///	You always need a valid transaction context to call this method.
	public func run(query q:QueryExpressive, success s:SuccessHandler=Default.Handler.success, failure f:FailureHandler=Default.Handler.failure)
	{
		run(query: q.express(), success: s, failure: f)
	}
	public func run(query c:String, success s:SuccessHandler=Default.Handler.success, failure f:FailureHandler=Default.Handler.failure)
	{
		run(query: Query.Expression(code: c, parameters: []), success: s, failure: f)
	}
	public func run(query x:Query.Expression, success s:SuccessHandler=Default.Handler.success, failure f:FailureHandler=Default.Handler.failure)
	{
		assert(_core.autocommit == false)
		
		var	m	=	[String:Value]()
		for mapping in x.parameters
		{
			m[mapping.name]	=	mapping.value
		}
		
		Debug.log(x.code)
		Debug.log(m)
		
		execute(code: x.code, parameters: m, success: s, failure: f)
	}
	
	public func schema() -> Database.Schema
	{
		return	Schema(database: self, defaultErrorHandler: Default.Handler.failure)
	}
	public func table(name n:String) -> Database.Table
	{
		return	Table(database: self, name: n, defaultErrorHandler: Default.Handler.failure)
	}
	
	
	
	
	
	
	
	
	
	
	
	
	public struct Default
	{
		///	Just does nothing.
		static func null(rows:GeneratorOf<Row>)
		{
		}
		
		///	Default error handler.
		///	Crashes the caller. Any uncommited transaction will be undone.
		static func crash(message m: String)
		{
			Core.Common.crash(message: m)
		}
		
		public struct Generator
		{
			///	Maximum resolution is `1/(Int.max-1)` per a second.
			///	That's the hard limit of this algorithm. If you need something
			///	better, you have to make and specify your own generator on initializer
			///	of `Database` class.
			public static func uniqueAtomicUnitName() -> String
			{
				struct deduplicator
				{
					var	lastSeed			=	0
					var	duplicationCount	=	0
					
					mutating func stepOne() -> String
					{
						let	t1	=	Int(NSDate().timeIntervalSince1970)
						if t1 == lastSeed
						{
							precondition(duplicationCount < Int.max)
							duplicationCount	+=	1
						}
						else
						{
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
		
		struct Handler
		{
			static let	success	=	Default.null
			static let	failure	=	Default.crash
		}
	}
	
	
	///	Execute the query and captures snapshot of all values of resulting rows.
	func snapshot(query x:Query.Expression, error handler:FailureHandler) -> [[String:Value]]
	{
		func collect(rows:GeneratorOf<Row>) -> [[String:Value]]
		{
			var	vs	=	[[String:Value]]()
			for row in rows
			{
				var	m	=	[String:Value]()
				let	c	=	row.numberOfFields
				for i in 0..<c
				{
					if	row.isNullField(atIndex: i) == false
					{
						let	n:String	=	row.columnNameOfField(atIndex: i)
						let	v:Value		=	row[i]
						
						m[n]	=	v
					}
				}
				vs	+=	[m]
			}
			return	vs
		}
		
		var	m:[[String:Value]]	=	[]
		func tx() -> Bool
		{
			var	ok	=	false
			func s(data:GeneratorOf<Row>)
			{
				ok	=	true
				m	=	collect(data)
			}
			func f(message:String)
			{
				handler(message: message)
			}
			
			run(query: x, success: s, failure: f)
			return	ok
		}
		
		applyConditionally(transaction: tx)
		return	m
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	///	Run an atomic transaction which always commits.
	private func performTransactionSession(transaction tx:() -> ())
	{
		func tx2() -> Bool
		{
			tx()
			return	true
		}
		let	ok	=	performTransactionSessionConditionally(transaction: tx2)
		assert(ok)
	}
	
	///	Run a nested transaction which always comits using `SAVEPOINT`.
	private func performSavepointSession(transaction tx:() -> (), name n:String)
	{
		func tx2() -> Bool
		{
			tx()
			return	true
		}
		let	ok	=	performSavepointSessionConditionally(transaction: tx2, name:n)
		assert(ok)
	}
	
	///	Run an atomic transaction.
	private func performTransactionSessionConditionally(transaction tx:() -> Bool) -> Bool
	{
		precondition(_core.null == false)
		precondition(_core.autocommit == true)
		
		execute(code: "BEGIN TRANSACTION;")
		assert(_core.autocommit == false)
		if tx()
		{
			execute(code: "COMMIT TRANSACTION;")
			assert(_core.autocommit == true)
			return	true
		}
		else
		{
			execute(code: "ROLLBACK TRANSACTION;")
			assert(_core.autocommit == true)
			return	false
		}
	}
	///	Run a nested transaction using `SAVEPOINT`.
	private func performSavepointSessionConditionally(transaction tx:() -> Bool, name n:String) -> Bool
	{
		precondition(n != "", "The atomic transaction subunit name shouldn't be empty.")
		precondition(_core.null == false)
		precondition(_core.autocommit == false)
		
		execute(code: Query.Language.Syntax.SavepointStmt(name: Query.Identifier(name: n).description).description)
		if tx()
		{
			execute(code: Query.Language.Syntax.ReleaseStmt(name: Query.Identifier(name: n).description).description)
			return	true
		}
		else
		{
			execute(code: Query.Language.Syntax.RollbackStmt(name: Query.Identifier(name: n).description).description)
			return	false
		}
	}
//	private func execute(query x:QueryExpressive, success s:SuccessHandler=Default.Handler.success, failure f:FailureHandler=Default.Handler.failure)
//	{
//		execute(query: x.express(), success: s, failure: f)
//	}
//	private func execute(query x:Query.Expression, success s:SuccessHandler=Default.Handler.success, failure f:FailureHandler=Default.Handler.failure)
//	{
//		var	m	=	[String:Value]()
//		for mapping in x.parameters
//		{
//			m[mapping.name]	=	mapping.value
//		}
//		
//		Debug.log(x.code)
//		Debug.log(m)
//		execute(code: x.code, parameters: m, success: s, failure: f)
//	}
	private func execute(code c:String, parameters p:ParameterList=ParameterList(), success s:SuccessHandler=Default.Handler.success, failure f:FailureHandler=Default.Handler.failure)
	{
		let	ss1	=	cache(code: c) as [Statement]
		for s1 in ss1
		{
			s1.bind(parameters: p)
			s(data: GeneratorOf<Row>(s1))
			if s1.execution == false
			{
				s1.step()		///<	Just step once to make the command surely been executed.
			}
		}
	}
	private func cache(code s:String) -> [Statement]
	{
		let	(ss1, tail)	=	_core.prepare(s)
		
		if tail != ""
		{
			Core.Common.crash(message: "The SQL command was not fully consumed, remaining part = \(tail)")
		}
		
		return	ss1.map({ (n:Core.Statement) -> Statement in return Statement(database: self, core: n )})
		
	}
	
	
	
	
	
	
	
	
	
	
	
	private let	_savepoint_name_gen:() -> String
	
	private var	_core				=	Core.Database()
}










