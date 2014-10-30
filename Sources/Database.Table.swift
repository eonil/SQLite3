//
//  Database.Table.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/18/14.
//
//

import Foundation













public extension Database
{
	
	///	Provides simple and convenient methods to get results easily on a single table.
	///	`select` series methods returns empty result (array) on error.
	///	The error-handler will be called on error.
	///	All of each methods are protected by transaction.
	///	Transaction will be rollback on any error,
	///	and nothing will be changed.
	public struct Table
	{
		let	database:Database
		let	name:String
	}
}


public extension Database.Table
{
	
	public func select(rowsWithAllOf pairs:[String:Value]) -> [[String:Value]]
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q	=	Query.Select(table: Query.Identifier(name: name), columns: Query.ColumnList.All, filter: t)
		return	snapshot(query: q)
	}
	public func select(rowsWithAnyOf pairs:[String:Value]) -> [[String:Value]]
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
		let	q	=	Query.Select(table: Query.Identifier(name: name), columns: Query.ColumnList.All, filter: t)
		return	snapshot(query: q)
	}
	///	Selects all rows.
	public func select() -> [[String:Value]]
	{
		let	q	=	Query.Select(table: Query.Identifier(name: name), columns: Query.ColumnList.All, filter: nil)
		return	snapshot(query: q)
	}
	
	
	
	
	
	

	public func insert(rowWith pairs:[String:Value])
	{
		var	bs:[Query.Binding]	=	[]
		for (k, v) in pairs
		{
			bs.append(Query.Binding(column: Query.Identifier(name: k), value: v))
		}
		let	q	=	Query.Insert(table: Query.Identifier(name: name), bindings: bs)
		snapshot(query: q)
	}
	
	
	
	
	
	public func update(rowsWithAllOf existingPairs:[String:Value], bySetting newPairs:[String:Value])
	{
		let	t	=	filterTreeWith(samples: existingPairs, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q	=	Query.Update(table: Query.Identifier(name: name), bindings: bindingsOf(paris: newPairs), filter: t)
		snapshot(query: q)
	}
	public func update(rowsWithAnyOf existingPairs:[String:Value], bySetting newPairs:[String:Value])
	{
		let	t	=	filterTreeWith(samples: existingPairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
		let	q	=	Query.Update(table: Query.Identifier(name: name), bindings: bindingsOf(paris: newPairs), filter: t)
		snapshot(query: q)
	}
	
	
	
	
	
	
	
	public func delete(rowsWithAllOf pairs:[String:Value])
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q	=	Query.Delete(table: Query.Identifier(name: name), filter: t)
		snapshot(query: q)
	}
	public func delete(rowsWithAnyOf pairs:[String:Value])
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
		let	q	=	Query.Delete(table: Query.Identifier(name: name), filter: t)
		snapshot(query: q)
	}
	
	
	
	
	
	
		
	
	
	func snapshot(query q:QueryExpressible) -> [[String:Value]]
	{
		return	database.snapshot(query: q.express())
	}
		
	func bindingsOf(paris ps:[String:Value]) -> [Query.Binding]
	{
		var	bs:[Query.Binding]	=	[]
		for (k, v) in ps
		{
			bs.append(Query.Binding(column: Query.Identifier(name: k), value: v))
		}
		return	bs
	}
	
	func filterTreeWith(samples ss:[String:Value], combinationStyle cs:Query.FilterTree.Node.Combination) -> Query.FilterTree
	{
		var	ns:[Query.FilterTree.Node]	=	[]
		for (k, v) in ss
		{
			ns.append(Query.FilterTree.Node.Leaf(operation: Query.FilterTree.Node.Operation.Equal, column: Query.Identifier(name: k), value: v))
		}
		let	n	=	Query.FilterTree.Node.Branch(combination: cs, subnodes: ns)
		let	t	=	Query.FilterTree(root: n)
		return	t
	}
}



