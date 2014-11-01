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
		let	columns:[ColumnInfo]
		
		func allkeyColumnNames() -> [String] {
			return	columns.map {$0.name}
		}
		func keyColumns() -> [ColumnInfo] {
			return	columns.filter {$0.pk}
		}
		func dataColumns() -> [ColumnInfo] {
			return	columns.filter {$0.pk == false}
		}
		
		static func fetch(db:Database, tableName:String) -> TableInfo {
			let	rs	=	db.apply {
				db.run("PRAGMA table_info(\( Query.Identifier(tableName).express().code ))")
			}
			let	cs	=	rs.map {ColumnInfo($0)}
			let	t	=	TableInfo(columns: cs)
			return	t
		}
	}
	
	struct ColumnInfo {
		let	cid:Int64
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




