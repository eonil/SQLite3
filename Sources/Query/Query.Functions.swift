//
//  Query.Functions.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/2/14.
//
//

import Foundation

func select(table:String, columns:[String]) -> Query.Select {
	return	select(Query.Identifier(table), Query.ColumnList.Items(names: columns.map {Query.Identifier($0)}), nil)
}
func select(table:Query.Identifier, columns:Query.ColumnList, filter:Query.FilterTree?) -> Query.Select {
	return	Query.Select(table: table, columns: columns, filter: filter)
}
//func insert(table:String, bindings: [String:Value]) -> Query.Select {
//	return	insert(Identifier(table), bindings
//}
//func insert(table:Identifier, bindings: [Query.Binding]) -> Query.Select {
//	
//}
