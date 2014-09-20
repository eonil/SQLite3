//
//  Database.Schema.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/18/14.
//
//

import Foundation

public extension Database
{
	///	Provides simple and convenient methods
	public struct Schema
	{
		let	database:Database
		
		let	defaultErrorHandler		=	Database.Default.Handler.failure
	}
}





public extension Database.Schema
{
	public typealias	ErrorHandler	=	Database.FailureHandler
	
	public func namesOfAllTables(error handler:ErrorHandler) -> [String]
	{
		let	d	=	database.snapshot(query: "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;", error: handler)
		func getName(r:[String:Value]) -> String
		{
			return	r["name"]! as String
		}
		return	d.map(getName)
	}
	
	public func table(of name:String, error handler:ErrorHandler) -> Schema.Table
	{
		let	p	=	Query.Language.Syntax.Pragma(database: nil, name: "table_info", argument: Query.Language.Syntax.Pragma.Argument.Call(value: name))
		let	c	=	p.description
		let	d	=	database.snapshot(query: Query.Expression(code: c, parameters: []), error: handler)
		
		Debug.log(d)
		
		return	Schema.Table(name: "?", key: [], columns: [])
	}
	
	
	public func create(table q:Query.Schema.Table.Create, error handler:ErrorHandler)
	{
		func tx()
		{
			database.run(query: q.express(), success: Database.Default.Handler.success, failure: handler)
		}
		database.apply(transaction: tx)
	}
	public func create(table tname:String, column cnames:[String], error handler:ErrorHandler)
	{
		func columnize(name:String) -> Schema.Column
		{
			return	Schema.Column(name: name, nullable: true, type: Schema.Column.TypeCode.None, unique: false, index: nil)
		}
		let	cs	=	cnames.map(columnize)
		let	def	=	Schema.Table(name: tname, key: [], columns: cs)
		let	cmd	=	Query.Schema.Table.Create(temporary: false, definition: def)
		create(table: cmd, error: handler)
	}
	public func create(table tname:String, column cnames:[String])
	{
		create(table: tname, column: cnames, error: defaultErrorHandler)
	}
	
	
	
	
	
	
	public func drop(table q:Query.Schema.Table.Drop, error handler:ErrorHandler)
	{
		func tx()
		{
			database.run(query: q.express(), success: Database.Default.Handler.success, failure: handler)
		}
		database.apply(tx)
	}
	public func drop(table tname:String, error handler:ErrorHandler)
	{
		drop(table: Query.Schema.Table.Drop(name: Query.Identifier(name: tname), ifExists: false), error: handler)
	}
	public func drop(table tname:String)
	{
		drop(table: tname, error: defaultErrorHandler)
	}

	
	
	
	
	
	
	
	
	func allRowsOfRawMasterTable() -> [[String:Value]]
	{
		return	database.snapshot(query: "SELECT * FROM sqlite_master", error: defaultErrorHandler)
	}
	
	
}
