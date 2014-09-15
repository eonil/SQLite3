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
	init()
	{
		_core.open(":memory:", flags: Core.Database.OpenFlag.None)
	}
	deinit
	{
		_core.close()
	}
	
	func run(transaction:() -> ())
	{
		_run_once("BEGIN TRANSACTION;")
		_run_once("COMMIT TRANSACTION;")
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