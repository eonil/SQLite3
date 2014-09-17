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
	
	func allRowsOfRawMasterTable() -> [[String:AnyObject]]
	{
		return	database.snapshot(query: "SELECT * FROM sqlite_master", error: defaultErrorHandler)
	}
	
	public func namesOfAllTables(error handler:ErrorHandler) -> [String]
	{
		let	d	=	database.snapshot(query: "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;", error: handler)
		func getName(r:[String:AnyObject]) -> String
		{
			return	r["name"]! as String
		}
		return	d.map(getName)
	}
	
	public func table(of name:String, error handler:ErrorHandler) -> Query.Schema.Table
	{
		let	p	=	Query.Language.Syntax.Pragma(database: nil, name: "table_info", argument: Query.Language.Syntax.Pragma.Argument.Call(value: name))
		let	c	=	p.description
		let	d	=	database.snapshot(query: Query.Expression(code: c, parameters: []), error: handler)
		
		Debug.log(d)
		
		return	Query.Schema.Table(name: "?", key: [], columns: [])
	}
	
	
	public func create(table q:Query.Schema.Table.Create, error handler:ErrorHandler)
	{
		database.apply { (operation) -> () in
			operation.execute(query: q, success: Database.Default.Handler.success, failure: handler)
		}
	}
	public func create(table tname:String, column cnames:[String], error handler:ErrorHandler)
	{
		func columnize(name:String) -> Query.Schema.Column
		{
			return	Query.Schema.Column(name: Query.Identifier(name: name), nullable: true, type: Query.Schema.Column.TypeCode.None, unique: false)
		}
		let	cs	=	cnames.map(columnize)
		let	def	=	Query.Schema.Table(name: Query.Identifier(name: tname), key: [], columns: cs)
		let	cmd	=	Query.Schema.Table.Create(temporary: false, definition: def)
		create(table: cmd, error: handler)
	}
	public func create(table tname:String, column cnames:[String])
	{
		create(table: tname, column: cnames, error: defaultErrorHandler)
	}
	
	
	
	
	
	
	public func drop(table q:Query.Schema.Table.Drop, error handler:ErrorHandler)
	{
		database.apply { (operation) -> () in
			operation.execute(query: q, success: Database.Default.Handler.success, failure: handler)
		}
	}
	public func drop(table tname:String, error handler:ErrorHandler)
	{
		drop(table: Query.Schema.Table.Drop(name: Query.Identifier(name: tname), ifExists: false), error: handler)
	}
	public func drop(table tname:String)
	{
		drop(table: tname, error: defaultErrorHandler)
	}

	
}
