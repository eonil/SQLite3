//
//  Database.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation

///	`execute` executes a query as is.
///	`run` executes a query with transaction wrapping.
///
///
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
	
	public init(location:Location, mutable:Bool = false)
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
		
		_core.open(resolve_name(), flags: resolve_flag())
		
		assert(_core.null == false)
	}
	deinit
	{
		precondition(_core.null == false)
		
		_core.close()
		
		assert(_core.null == true)
	}
	
	
	
	
	
	
	///	Operation will be commited automatically.
	///	There's no way to perform ROLLBACK manually.
	///	ROLLBACK will occur only on crash situation
	///	by the SQLite3 machenism.
	///	Transactions can be nested. You can call this
	///	method multiple times to make nested transactions.
	///	Anyway in that situation, out-most transaction 
	///	rules them all.
	public func apply(transaction:() -> ())
	{
		precondition(_core.null == false)
		
		let	nested	=	_core.autocommit == false
		if nested == false { execute(code: "BEGIN TRANSACTION;") }
		assert(_core.autocommit == false)
		transaction()
		if nested == false { execute(code: "COMMIT TRANSACTION;") }
	}
	
	///	`run` method with optional ROLLBACK support.
	///	If you return false, everything will be ROLLBACK.
	///	Returns what the transaction closure returns.
	/// (true for commit, false for rollback)
	///	Rollback of inner transaction does not affect outer
	///	transaction. It can be commit separately.
	public func applyOptionally(transaction:() -> Bool) -> Bool
	{
		precondition(_core.null == false)
		
		let	nested	=	_core.autocommit == false
		if nested == false { execute(code: "BEGIN TRANSACTION;") }
		assert(_core.autocommit == false)
		if transaction()
		{
			if nested == false { execute(code: "COMMIT TRANSACTION;") }
			return	true
		}
		else
		{
			if nested == false { execute(code: "ROLLBACK TRANSACTION;") }
			return	false
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
	
	
	
	
	
	
	
	
	
	
	
	
	struct Default
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
		
		struct
		Handler
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
		
		applyOptionally(tx)
		return	m
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
	
	
	
	
	
	
	
	
	
	
	
	private var	_core				=	Core.Database()
}










