//
//  Database.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/2/14.
//
//

import Foundation



///	Provides simple access to a SQLite3 database.
public final class Database {
	let	configuration:Configuration						///<	Current configuration.
	let	connection:Connection							///<	Used connection.
	
	private lazy var	_schema:Schema				=	Schema(owner: self)
	private lazy var	_tables:TableCollection		=	TableCollection(owner: self)
	
	private lazy var	_optimisation:Optimisation	=	Optimisation({ self.connection.prepare($0) })
	

	
	///	Creates a new instance of a `Database` class.
	///	
	///	:location:	The source database location.
	///	:editable:	Set `false` if you want to open the database in read-only mode.
	public convenience init(location:Connection.Location, editable:Bool) {
		self.init(location: location, editable: editable, configuration: Configuration(savepointNameGenerator: SavepointNameGenerator.uniqueAtomicUnitName))
	}
	
	///	Not yet available publicly.
	init(location:Connection.Location, editable:Bool, configuration:Configuration) {
		self.configuration	=	configuration
		self.connection		=	Connection(location: location, editable: editable)
		
		_installDebuggingGuidanceAuthoriser()
	}
	
	deinit {
		_optimisation	=	Optimisation()
		
		_uninstallDebuggingGuidanceAuthoriser()
		
	}
}

extension Database {
	
	///	Gets schema editor.
	public var schema:Schema {
		get {
			return	_schema
		}
	}
	
	///	Gets table collection.
	public var tables:TableCollection {
		get {
			return	_tables
		}
	}
	
	
	
	///	Apply transaction to database.
	public func apply(transaction:()->()) {
		if connection.runningTransaction {
			_performSavepointSession(transaction: transaction, name: configuration.savepointNameGenerator())
		} else {
			_performTransactionSession(transaction: transaction)
		}
	}
	///	Apply transaction to database.
	public func apply<T>(transaction:()->T) -> T {
		if connection.runningTransaction {
			return	_performSavepointSession(transaction: transaction, name: configuration.savepointNameGenerator())
		} else {
			return	_performTransactionSession(transaction: transaction)
		}
	}
	
	///	Apply transaction to database only when the transaction returns `true`.
	public func applyConditionally<T>(transaction:()->T?) -> T? {
		if connection.runningTransaction {
			return	_performSavepointSessionConditionally(transaction: transaction, name: configuration.savepointNameGenerator())
		} else {
			return	_performTransactionSessionConditionally(transaction: transaction)
		}
	}
	
	
	
}


















///	MARK:
///	MARK:	Internal/Private Implementations
///	MARK:

extension Database {
	func compile(code:String) -> Program {
		return	Program(database: self, midlevel: connection.prepare(code))
	}
	
}







extension Database{
	///	Run an atomic transaction which always commits.
	private func _performTransactionSession<T>(transaction tx:()->T) -> T {
		func tx2() -> T? { return tx() as T? }		//	This `as` is very important.
		if let v1 = _performTransactionSessionConditionally(transaction: tx2) {
			return	v1
		} else {
			fatalError("Transaction failed unexpectedly.")
		}
	}
	
	///	Run a nested transaction which always comits using `SAVEPOINT`.
	private func _performSavepointSession<T>(transaction tx:()->T, name n:String) -> T {
		func tx2() -> T? { return tx() as T? }		//	This `as` is very important.
		if let v1 = _performSavepointSessionConditionally(transaction: tx2, name:n) {
			return	v1
		} else {
			fatalError("Transaction failed unexpectedly.")
		}
	}
	
	///	Run an atomic transaction.
	///	Return `nil` in the transaction closure to rollback the transaction.
	private func _performTransactionSessionConditionally<T>(transaction tx:()->T?) -> T? {
		precondition(connection.runningTransaction == false)
		
//		_runWithoutExplicitTransactionCheck("BEGIN TRANSACTION;", parameters: [])
		_optimisation.commonStatementCache.beginTransaction()
		assert(connection.runningTransaction == true)
		
		if let v = tx() {
//			_runWithoutExplicitTransactionCheck("COMMIT TRANSACTION;", parameters: [])
			_optimisation.commonStatementCache.commitTransaction()
			assert(connection.runningTransaction == false)
			return	v
		} else {
//			_runWithoutExplicitTransactionCheck("ROLLBACK TRANSACTION;", parameters: [])
			_optimisation.commonStatementCache.rollbackTransaction()
			assert(connection.runningTransaction == false)
			return	nil
		}
	}
	///	Run a nested transaction using `SAVEPOINT`.
	private func _performSavepointSessionConditionally<T>(transaction tx:()->T?, name n:String) -> T? {
		precondition(n != "", "The atomic transaction subunit name shouldn't be empty.")
		precondition(connection.runningTransaction == true)
		
		connection.run(Query.Language.Syntax.SavepointStmt(name: Query.Identifier(n).description).description)
		if let v = tx() {
			connection.run(Query.Language.Syntax.ReleaseStmt(name: Query.Identifier(n).description).description)
			return	v
		} else {
			connection.run(Query.Language.Syntax.RollbackStmt(name: Query.Identifier(n).description).description)
			return	nil
		}
	}
	
	
	
//	///	Executes a single query.
//	private func _runWithoutExplicitTransactionCheck(query:String, parameters:[Value]) -> [[String:Value]] {
//		let	s	=	compile(query)
//		let	x	=	s.execute(parameters)
//		return	x.allDictionaries()
//	}
	
	
	
	
	
	
	
	
	
	
	
	private func _installDebuggingGuidanceAuthoriser() {
		//	Expected to be eliminated by compiler in release mode.
		if Debug.mode {
			let prohibitNameForLiveTables	=	{ [unowned self](databaseName:String, tableName:String) -> Bool in
				let	ok	=	self.tables.links.filter { let t1 = $0(); return t1 != nil && t1!.name == tableName}.count == 0
				//			let	ok	=	self.tables.liveTableNamesInLinks().filter {$0 == tableName}.count == 0
				assert(ok, "Altering or dropping a table is not allowed while a `Table` object is linked to the table is alive.")
				return	ok
			}
			
			let	auth1	=	Core.Connection.AuthorisationRoutingTable(alterTable: prohibitNameForLiveTables, dropTable: prohibitNameForLiveTables)
			connection.setAuthoriser(auth1)
		}
	}
	private func _uninstallDebuggingGuidanceAuthoriser() {
		//	Expected to be eliminated by compiler in release mode.
		if Debug.mode {
			connection.setAuthoriser(nil)
		}
	}


}




















///	MARK:	Optimisations
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








