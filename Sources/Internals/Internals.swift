//
//  Internals.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 10/31/14.
//
//

import Foundation

struct Internals {
}

///	Dirty stuffs for quick implementation.
extension Internals {
	
	struct TableInfo {
		unowned let	database:Database
		
		let	name:String
		let	allColumns:[ColumnInfo]
		
		private init(database:Database, name:String) {
			let	rs	=	database.apply {
				database.run("PRAGMA table_info(\( Query.Identifier(name).express().code ))")
			}
			let	cs	=	rs.map {ColumnInfo($0)}
			
			self.database		=	database
			self.name			=	name
			self.allColumns		=	cs
			
			if Debug.mode {
				for i in 0..<cs.count {
					assert(IntMax(allColumns[i].cid) == IntMax(i))
				}
			}
		}
		
		func keyColumns() -> [ColumnInfo] {
			return	allColumns.filter {$0.pk}
		}
		func dataColumns() -> [ColumnInfo] {
			return	allColumns.filter {$0.pk == false}
		}
		
		func keyColumnNames() -> [String] {
			return	keyColumns().map {$0.name}
		}
		func dataColumnNames() -> [String] {
			return	dataColumns().map {$0.name}
		}
		func keyColumnIndexes() -> [Int] {
			return	keyColumns().map {Int($0.cid)}
		}
		func dataColumnIndexes() -> [Int] {
			return	dataColumns().map {Int($0.cid)}
		}
		
		func findKeyColumnIndexForName(name:String) -> Int? {
			return	find(keyColumnNames(), name)
		}
		func findDataColumnIndexForName(name:String) -> Int? {
			return	find(dataColumnNames(), name)
		}
		
		////
		
		static func fetch(db:Database, tableName:String) -> TableInfo {
			return	TableInfo(database: db, name: tableName)
		}
	}
	
	struct ColumnInfo {
		let	cid:Int64				///<	Column index.
		let	name:String
		let	type:String?
		let	notNull:Bool			///<	`notnull` column.
		let	defaultValue:Value?		///<	`dflt_value` column.
		let	pk:Bool
		
		init(_ r:[String:Value]) {
			cid		=	r["cid"]!.integer!
			name	=	r["name"]!.text!
			type	=	r["type"]!.text!
			notNull	=	r["notnull"]!.integer! == 1
			defaultValue	=	r["dflt_value"]
			pk		=	r["pk"]!.integer! == 1
		}
	}

}




