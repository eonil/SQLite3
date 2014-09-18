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
		case TempFile
		case PersistentFile(path:String)
	}
	
	public init(location:Location, mutable:Bool = false)
	{
		assert(_core.null == true)
		
		func resolve_name() -> String
		{
			switch location
			{
			case let Location.Memory:						return	":memory:"
			case let Location.TempFile:						return	""
			case let Location.PersistentFile(path: path):	return	path
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
	public func apply(transaction:(operation:Operation) -> ())
	{
		precondition(_core.null == false)
		
		execute(code: "BEGIN TRANSACTION;")
		assert(_core.autocommit == false)
		transaction(operation: Operation(database: self, version: _dbg.transactionVersion))
		execute(code: "COMMIT TRANSACTION;")
	}
	
	///	`run` method with optional ROLLBACK support.
	///	If you return false, everything will be ROLLBACK.
	///	Returns what the transaction closure returns.
	/// (true for commit, false for rollback)
	public func applyOptionally(transaction:(operation:Operation) -> Bool) -> Bool
	{
		precondition(_core.null == false)
		
		execute(code: "BEGIN TRANSACTION;")
		assert(_core.autocommit == false)
		if transaction(operation: Operation(database: self, version: _dbg.transactionVersion))
		{
			execute(code: "COMMIT TRANSACTION;")
			return	true
		}
		else
		{
			execute(code: "ROLLBACK TRANSACTION;")
			return	false
		}
	}
	
	///	Executes a query with transaction wrapping.
	///	In other words, this `apply` with `execute`.
	public func run(query q:QueryExpressive, success s:SuccessHandler, failure f:FailureHandler)
	{
		run(query: q.express(), success: s, failure: f)
	}
	public func run(query c:String, success s:SuccessHandler, failure f:FailureHandler)
	{
		run(query: Query.Expression(code: c, parameters: []), success: s, failure: f)
	}
	public func run(query x:Query.Expression, success s:SuccessHandler, failure f:FailureHandler)
	{
		func transact(op:Operation)
		{
			op.execute(query: x, success: s, failure: f)
		}
		apply(transact)
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
		///	Default row iterator.
		///	Just does nothing.
//		static func null(row:Row)
//		{
//		}
		
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
		func tx(op:Database.Operation) -> Bool
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
			
			op.execute(query: x, success: s, failure: f)
			return	ok
		}
		
		applyOptionally(tx)
		return	m
	}
	func execute(query x:Query.Expression, success s:SuccessHandler=Default.Handler.success, failure f:FailureHandler=Default.Handler.failure)
	{
		var	m	=	[String:Value]()
		for mapping in x.parameters
		{
			m[mapping.name]	=	mapping.value
		}
		
		Debug.log(x.code)
		Debug.log(m)
		execute(code: x.code, parameters: m, success: s, failure: f)
	}
	func execute(code c:String, parameters p:ParameterList=ParameterList(), success s:SuccessHandler=Default.Handler.success, failure f:FailureHandler=Default.Handler.failure)
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
		
//		class
//		MultistatementRowGenerator : GeneratorType
//		{
//			typealias	Element	=	Row
//			
//			init(all:IndexingGenerator<[Statement]>)
//			{
//				self.all	=	all
//				
//				current	=	self.all.next()
//				current?.bind(parameters: p)
//			}
//			deinit
//			{
//				executeAll()
//			}
//			
//			var	all:IndexingGenerator<[Statement]>
//			var	current:Statement?
//			
//			func next() -> Element?
//			{
//				if let row = current?.next()
//				{
//					return	row
//				}
//				else
//				{
//					if let current = all.next()
//					{
//						return	next()
//					}
//					else
//					{
//						return	nil
//					}
//				}
//			}
//			func executeAll()
//			{
//				if current != nil
//				{
//					for s1 in all
//					{
//						s1.step()
//					}
//				}
//			}
//		}
//		
//		let	g1	=	MultistatementRowGenerator(all: ss1.generate())
//		let	g2	=	GeneratorOf<Row>(g1)
//		
//		s(data: g2)
		
//		
//		if ss1.count > 0
//		{
//			s1.bind(parameters: ps)
//		}
//		if let f = ss1.first
//		{
//			var	rg1	=	ROWGEN(stmtgen: ss1.generate(), rowgen: f)
//			return	GeneratorOf<Row>(rg1)
//		}
//		return	GeneratorOf<Row>(GeneratorOfOne<Row>(nil))
	}
	func cache(code s:String) -> [Statement]
	{
		let	(ss1, tail)	=	_core.prepare(s)
		
		if tail != ""
		{
			Core.Common.crash(message: "The SQL command was not fully consumed, remaining part = \(tail)")
		}
		
		return	ss1.map({ (n:Core.Statement) -> Statement in return Statement(database: self, core: n )})
		
	}
	
	
	
	
	
	
	
	
	
	
	
	internal var	_core				=	Core.Database()
//	internal var _in_transaction		=	false
	internal var	_dbg				=	DebuggingSupport()
	
	
	
	
	struct DebuggingSupport
	{
		struct TransactionVersion
		{
			var	number	=	0
			
			mutating func step()
			{
				number++
				if number == Int.max
				{
					number	=	0
				}
			}
		}
		
		var	transactionVersion	=	TransactionVersion()
	}
}










