//
//  List.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/9/14.
//
//

import Foundation

///	Creates a sorted set of selected rows.
public class List {
	let	selection:Selection
	let	sortings:Query.SortingList
	
	init(selection:Selection, sortings:Query.SortingList) {
		self.selection	=	selection
		self.sortings	=	sortings
	}
	
	public subscript() -> Page {
		get {
			return	self[0..<Int.max]
		}
	}
	public subscript(range:Range<Int>) -> Page {
		get {
			let	limit	=	distance(range.startIndex, range.endIndex)
			let	offset	=	range.startIndex
			return	Page(list: self, limit: limit, offset: offset)
		}
	}
}

public extension List {
//	public func arrays() -> Statement.Execution.ArrayView {
//		let	q	=	select(Query.Identifier(table.info.name), Query.ColumnList.All, filter)
//		let	e	=	q.express()
//		let	s	=	table.database.compile(e.code)
//		let	x	=	s.execute(e.parameters)
//		return	x.arrays()
//	}
//	public func dictionaries() -> Statement.Execution.DictionaryView {
//		let	q	=	select(Query.Identifier(table.info.name), Query.ColumnList.All, filter)
//		let	e	=	q.express()
//		let	s	=	table.database.compile(e.code)
//		let	x	=	s.execute(e.parameters)
//		return	x.dictionaries()
//	}
}


public struct Page {
	let	list:List
	let	limit:Int
	let	offset:Int
	
	public func arrays() -> Statement.Execution.ArrayView {
		let	q	=	select(Query.Identifier(list.selection.table.name), Query.ColumnList.All, list.selection.filter, list.sortings, limit, offset)
		let	e	=	q.express()
		let	s	=	list.selection.table.database.compile(e.code)
		let	x	=	s.execute(e.parameters)
		return	x.arrays()
	}
	public func dictionaries() -> Statement.Execution.DictionaryView {
		let	q	=	select(Query.Identifier(list.selection.table.name), Query.ColumnList.All, list.selection.filter, list.sortings, limit, offset)
		let	e	=	q.express()
		let	s	=	list.selection.table.database.compile(e.code)
		let	x	=	s.execute(e.parameters)
		return	x.dictionaries()
	}
}