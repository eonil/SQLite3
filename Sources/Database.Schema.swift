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





public extension Database.Schema {
	public func namesOfAllTables() -> [String] {
		let	x	=	database.prepare("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;").execute()
		let	d	=	x.allRowsAsDictionaries()
		return	d.map {$0["name"]!.text!}
	}
	
	public func table(of name:String) -> Schema.Table {
		let	p	=	Query.Language.Syntax.Pragma(database: nil, name: "table_info", argument: Query.Language.Syntax.Pragma.Argument.Call(value: name))
		let	c	=	p.description
		let	d	=	database.prepare(c).execute().allRowsAsDictionaries()
		
		Debug.log(d)
		
		return	Schema.Table(name: "?", key: [], columns: [])
	}
	
	
	public func create(table q:Query.Schema.Table.Create) {
		database.apply { self.database.run(q) }
	}
	public func create(#tableName:String, keyColumnNames:[String], dataColumnNames:[String]) {
		let	kcs	=	keyColumnNames.map {Schema.Column(name: $0, nullable: false, type: Schema.Column.TypeCode.None, unique: true, index: nil)}
		let	dcs	=	dataColumnNames.map {Schema.Column(name: $0, nullable: true, type: Schema.Column.TypeCode.None, unique: false, index: nil)}
		let	def	=	Schema.Table(name: tableName, key: keyColumnNames, columns: kcs+dcs)
		let	cmd	=	Query.Schema.Table.Create(temporary: false, definition: def)
		database.apply { self.database.run(cmd) }
	}
	public func create(#tableName:String, keyColumnName:String, dataColumnNames:[String]) {
		create(tableName: tableName, keyColumnNames: [keyColumnName], dataColumnNames: dataColumnNames)
	}
	public func create(#tableName:String, dataColumnNames:[String]) {
		create(tableName: tableName, keyColumnNames: [], dataColumnNames: dataColumnNames)
	}
	
	
	
	
	
	
	public func drop(table q:Query.Schema.Table.Drop) {
		func tx() {
			database.run(q.express())
		}
		database.apply(tx)
	}
	public func drop(table tname:String) {
		drop(table: Query.Schema.Table.Drop(name: Query.Identifier(tname), ifExists: false))
	}


	
	
	
	
	
	
	
	
	func allRowsOfRawMasterTable() -> [[String:Value]] {
		return	database.apply { self.database.run("SELECT * FROM sqlite_master") }
	}
	
	
}
