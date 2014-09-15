//
//  Database.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation

class Database
{
	enum
	Location
	{
		case Memory
		case TempFile
		case PersistentFile(path:String)
	}
	
	
	
	
	
	init(location:Location)
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
		
		_core.open(resolve_name(), flags: Core.Database.OpenFlag.None)
		
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
	func run(transaction:() -> ())
	{
		precondition(_core.null == false)
		
		_run_once("BEGIN TRANSACTION;")
		transaction()
		_run_once("COMMIT TRANSACTION;")
	}
	
	///	`run` method with optional ROLLBACK support.
	///	If you return false, everything will be ROLLBACK.
	func runOptionally(transaction:() -> Bool)
	{
		precondition(_core.null == false)
		
		_run_once("BEGIN TRANSACTION;")
		if transaction()
		{
			_run_once("COMMIT TRANSACTION;")
		}
		else
		{
			_run_once("ROLLBACK TRANSACTION;")
		}
	}

	
	
	
	
	
	private var	_core			=	Core.Database()
	private var _in_transaction	=	false
	
	private func _run_once(SQL:String)
	{
		let	(procs, rest)	=	_core.prepare(SQL)
		
		if let rest2 = rest
		{
			Core.Common.crash(message: "There's unconsumed SQL command string `\(rest2)`")
		}
		
		for proc in procs
		{
			while proc.step()
			{
			}
		}
	}
}