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
		public typealias	ErrorHandler	=	Database.FailureHandler
		
		let	database:Database
		let	name:String
		
		let	defaultErrorHandler:ErrorHandler
	}
}


public extension Database.Table
{
	
	public func select(rowsWithAllOf pairs:[String:AnyObject], error handler:ErrorHandler) -> [[String:AnyObject]]
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q	=	Query.Select(table: Query.Identifier(name: name), columns: Query.ColumnList.All, filter: t)
		return	snapshot(query: q, error: handler)
	}
	public func select(rowsWithAllOf pairs:[String:AnyObject]) -> [[String:AnyObject]]
	{
		return	select(rowsWithAllOf: pairs, error: defaultErrorHandler)
	}
	public func select(rowsWithAnyOf pairs:[String:AnyObject], error handler:ErrorHandler) -> [[String:AnyObject]]
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
		let	q	=	Query.Select(table: Query.Identifier(name: name), columns: Query.ColumnList.All, filter: t)
		return	snapshot(query: q, error: handler)
	}
	public func select(rowsWithAnyOf pairs:[String:AnyObject]) -> [[String:AnyObject]]
	{
		return	select(rowsWithAnyOf: pairs, error: defaultErrorHandler)
	}
	///	Selects all rows.
	public func select(error handler:ErrorHandler) -> [[String:AnyObject]]
	{
		let	q	=	Query.Select(table: Query.Identifier(name: name), columns: Query.ColumnList.All, filter: nil)
		return	snapshot(query: q, error: handler)
	}
	public func select() -> [[String:AnyObject]]
	{
		return	select(error: defaultErrorHandler)
	}
	
	
	
	
	
	

	public func insert(rowWith pairs:[String:AnyObject], error handler:ErrorHandler)
	{
		var	bs:[Query.Binding]	=	[]
		for (k, v) in pairs
		{
			bs.append(Query.Binding(column: Query.Identifier(name: k), value: v))
		}
		let	q	=	Query.Insert(table: Query.Identifier(name: name), bindings: bs)
		snapshot(query: q, error: handler)
	}
	public func insert(rowWith pairs:[String:AnyObject])
	{
		insert(rowWith: pairs, error: defaultErrorHandler)
	}
	
	
	
	
	
	public func update(rowsWithAllOf existingPairs:[String:AnyObject], bySetting newPairs:[String:AnyObject], error handler:ErrorHandler)
	{
		let	t	=	filterTreeWith(samples: existingPairs, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q	=	Query.Update(table: Query.Identifier(name: name), bindings: bindingsOf(paris: newPairs), filter: t)
		snapshot(query: q, error: handler)
	}
	public func update(rowsWithAllOf existingPairs:[String:AnyObject], bySetting newPairs:[String:AnyObject])
	{
		update(rowsWithAllOf: existingPairs, bySetting: newPairs, error: defaultErrorHandler)
	}
	public func update(rowsWithAnyOf existingPairs:[String:AnyObject], bySetting newPairs:[String:AnyObject], error handler:ErrorHandler)
	{
		let	t	=	filterTreeWith(samples: existingPairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
		let	q	=	Query.Update(table: Query.Identifier(name: name), bindings: bindingsOf(paris: newPairs), filter: t)
		snapshot(query: q, error: handler)
	}
	public func update(rowsWithAnyOf existingPairs:[String:AnyObject], bySetting newPairs:[String:AnyObject])
	{
		update(rowsWithAnyOf: existingPairs, bySetting: newPairs, error: defaultErrorHandler)
	}
	
	
	
	
	
	
	
	
	public func delete(rowsWithAllOf pairs:[String:AnyObject], error handler:ErrorHandler)
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q	=	Query.Delete(table: Query.Identifier(name: name), filter: t)
		snapshot(query: q, error: handler)
	}
	public func delete(rowsWithAllOf pairs:[String:AnyObject])
	{
		delete(rowsWithAllOf: pairs, error: defaultErrorHandler)
	}
	public func delete(rowsWithAnyOf pairs:[String:AnyObject], error handler:ErrorHandler)
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
		let	q	=	Query.Delete(table: Query.Identifier(name: name), filter: t)
		snapshot(query: q, error: handler)
	}
	public func delete(rowsWithAnyOf pairs:[String:AnyObject])
	{
		delete(rowsWithAnyOf: pairs, error: defaultErrorHandler)
	}
	
	
	
	
	
	
		
	
	
	func snapshot(query q:QueryExpressive, error handler:ErrorHandler) -> [[String:AnyObject]]
	{
		return	database.snapshot(query: q.express(), error: handler)
	}
		
	func bindingsOf(paris ps:[String:AnyObject]) -> [Query.Binding]
	{
		var	bs:[Query.Binding]	=	[]
		for (k, v) in ps
		{
			bs.append(Query.Binding(column: Query.Identifier(name: k), value: v))
		}
		return	bs
	}
	
	func filterTreeWith(samples ss:[String:AnyObject], combinationStyle cs:Query.FilterTree.Node.Combination) -> Query.FilterTree
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



