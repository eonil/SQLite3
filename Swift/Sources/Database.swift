//
//  Database.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation

public class Database
{
	public typealias	ParameterList	=	[String:AnyObject]
	public typealias	RowIterator		=	(row:Row)->()
	public typealias	ErrorHandler	=	(message:String)->()
	
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
	public func applyOptionally(transaction:(operation:Operation) -> Bool)
	{
		precondition(_core.null == false)
		
		execute(code: "BEGIN TRANSACTION;")
		assert(_core.autocommit == false)
		if transaction(operation: Operation(database: self, version: _dbg.transactionVersion))
		{
			execute(code: "COMMIT TRANSACTION;")
		}
		else
		{
			execute(code: "ROLLBACK TRANSACTION;")
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	struct Default
	{
		///	Default row iterator.
		///	Just does nothing.
		static func null(row:Row)
		{
		}
		static func null(rows:GeneratorOf<Row>)
		{
		}
		
		///	Default error handler.
		///	Crashes the caller. Any uncommited transaction will be undone.
		static func crash(message m: String)
		{
			Core.Common.crash(message: m)
		}
	}
	
	func execute(query q:QueryExpressive, success s:SuccessHandler=Default.null, failure f:ErrorHandler=Default.crash)
	{		
		var	pc	=	0
		func upng() -> String
		{
			pc++
			return	"@param\(pc)"
		}
		let	x	=	q.express(uniqueParameterNameGenerator: upng)
		
		var	m	=	[String:AnyObject]()
		for mapping in x.parameters
		{
			m[mapping.name]	=	mapping.value
		}
		
		Core.Debug.log(message: x.code)
		Core.Debug.log(message: m.description)
		execute(code: x.code, parameters: m, success: s, failure: f)
	}
	func execute(code c:String, parameters p:ParameterList=ParameterList(), success s:SuccessHandler=Default.null, failure f:ErrorHandler=Default.crash)
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










