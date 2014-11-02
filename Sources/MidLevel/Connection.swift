//
//  Connection.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation








public class Connection {
	
	private var	_core			=	Core.Connection()
	
	public convenience init(location:Location) {
		self.init(location: location, editable: false)
	}
	
	public required init(location:Location, editable:Bool) {
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
		func resolve_flag() -> Core.Connection.OpenFlag
		{
			if editable == false { return Core.Connection.OpenFlag.Readonly }
			return	Core.Connection.OpenFlag.ReadWrite
		}
		
		_core.open(resolve_name(), flags: resolve_flag())
		assert(_core.null == false)
		
	}
	
	deinit {
		precondition(_core.null == false)
		
		_core.close()
		
		assert(_core.null == true)
	}
	
	
	
}





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
extension Connection {
	
	public enum Location {
		case Memory
		case TemporaryFile
		case PersistentFile(path:String)
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
		let	s2	=	Statement(connection: self, core: s1)
		return	s2
	}
	
	public func execute(code:String) -> [[Value]] {
		let	s	=	prepare(code)
		let	x	=	s.execute()
		return	x.allTuples()
	}
	
}























///	MARK:
///	MARK:	Internal/Private Implementations
///	MARK:

extension Connection {
	
	
	
	
	
	var hasExplicitTransaction:Bool {
		get {
			return	_core.autocommit == false
		}
	}
	
	
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	func run(query:Query.Expression) -> [[String:Value]] {
		return	run(query.code, parameters: query.parameters.map {$0()})
	}
	
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	func run(query:QueryExpressible) -> [[String:Value]] {
		return	run(query.express())
	}
	
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	func run(query:String) -> [[String:Value]] {
		return	run(query, parameters: [])
	}
	
	///	Executes a single query.
	///	You always need a valid transaction context to call this method.
	func run(query:String, parameters:[Value]) -> [[String:Value]] {
		let	s	=	prepare(query)
		let	x	=	s.execute(parameters)
		return	x.allDictionaries()
	}
	
	func setAuthoriser(routingTable:Core.Connection.AuthorisationRoutingTable?) {
		_core.setAuthorizer(routingTable)
	}
}



