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
	}
}





public extension Database.Schema
{
	public func namesOfAllTables() -> [String]
	{
		let	d	=	database.snapshot(query: "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;")
		return	d.map {$0["name"]!.text!}
	}
	
	public func table(of name:String) -> Schema.Table
	{
		let	p	=	Query.Language.Syntax.Pragma(database: nil, name: "table_info", argument: Query.Language.Syntax.Pragma.Argument.Call(value: name))
		let	c	=	p.description
		let	d	=	database.snapshot(query: Query.Expression(code: c, parameters: []))
		
		Debug.log(d)
		
		return	Schema.Table(name: "?", key: [], columns: [])
	}
	
	
	public func create(table q:Query.Schema.Table.Create) {
		func tx() {
			database.run(query: q.express())
		}
		database.apply(transaction: tx)
	}
	public func create(table tname:String, column cnames:[String])
	{
		func columnize(name:String) -> Schema.Column
		{
			return	Schema.Column(name: name, nullable: true, type: Schema.Column.TypeCode.None, unique: false, index: nil)
		}
		let	cs	=	cnames.map(columnize)
		let	def	=	Schema.Table(name: tname, key: [], columns: cs)
		let	cmd	=	Query.Schema.Table.Create(temporary: false, definition: def)
		create(table: cmd)
	}
	
	
	
	
	
	
	public func drop(table q:Query.Schema.Table.Drop)
	{
		func tx()
		{
			database.run(query: q.express())
		}
		database.apply(tx)
	}
	public func drop(table tname:String)
	{
		drop(table: Query.Schema.Table.Drop(name: Query.Identifier(name: tname), ifExists: false))
	}


	
	
	
	
	
	
	
	
	func allRowsOfRawMasterTable() -> [[String:Value]]
	{
		return	database.snapshot(query: "SELECT * FROM sqlite_master")
	}
	
	
}
