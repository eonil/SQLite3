//
//  Section.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/1/14.
//
//

import Foundation


///	A local copy of subset data of server tables.
public struct Section {
	unowned let	table:Table
	
	let	rows:[Record]
	
	init(table:Table, rows:[Record]) {
		self.table	=	table
		self.rows	=	rows
	}
	init(table:Table, filter:Query.FilterTree) {
		self.table	=	table
		
		let	kcs	=	table.info.keyColumnNames()
		let	dcs	=	table.info.dataColumnNames()
		
		let	cs	=	(kcs + dcs).map {Query.Identifier($0)}
		let	q	=	Query.Select(table: Query.Identifier(table.info.name), columns: Query.ColumnList.Items(names: cs), filter: filter)
		let	e	=	q.express()

		let	s	=	table.info.database.compile(e.code)
		let	x	=	s.execute(e.parameters)
		
		self.rows	=	x.allRowValues().map { (fields:[Value]) in
			let	ks	=	[Value](fields[0..<kcs.count])
			let	ds	=	[Value](fields[kcs.count..<cs.count])
			return	Record(table: table, identity: ks, content: ds)
		}
	}
	
	public var count:Int {
		get {
			return	rows.count
		}
	}
	
	public subscript(index:Int) -> Record {
		get {
			return	rows[index]
		}
	}
	
	public subscript(range:Range<Int>) -> Section {
		get {
			return	Section(table: table, rows: [Record](rows[range]))
		}
	}
}