//
//  Database.Table.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/18/14.
//
//

import Foundation













public extension Database {
	
	///	Provides simple and convenient methods to get results easily on a single table.
	///	`select` series methods returns empty result (array) on error.
	///	The error-handler will be called on error.
	///	All of each methods are protected by transaction.
	///	Transaction will be rollback on any error,
	///	and nothing will be changed.
	public struct Table {
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
		for (c, v) in devaluate(pairs)
		{
			bs.append(Query.Binding(column: c, value: v))
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
		for (c, v) in devaluate(ps)
		{
			bs.append(Query.Binding(column: c, value: v))
		}
		return	bs
	}
	
	func filterTreeWith(samples ss:[(column:Query.Identifier, value:Query.ParameterValueEvaluation)], combinationStyle cs:Query.FilterTree.Node.Combination) -> Query.FilterTree {
		var	ns	=	[] as [Query.FilterTree.Node]
		for (c, v) in ss {
			ns.append(Query.FilterTree.Node.Leaf(operation: Query.FilterTree.Node.Operation.Equal, column: c, value: v))
		}
		let	n	=	Query.FilterTree.Node.Branch(combination: cs, subnodes: ns)
		let	t	=	Query.FilterTree(root: n)
		return	t
	}
	
	func filterTreeWith(samples ss:[String:Value], combinationStyle cs:Query.FilterTree.Node.Combination) -> Query.FilterTree {
		return	filterTreeWith(samples: devaluate(ss), combinationStyle: cs)
	}
}


































public extension Database.Table {
	public func select(rowsWithAllOfColumns cs:[String]) -> (parameters:[Value]) -> [[String:Value]] {
		func resolutionMapping() -> [(column: Query.Identifier, value:Query.ParameterValueEvaluation)] {
			var	m1	=	[] as [(column: Query.Identifier, value:Query.ParameterValueEvaluation)]
			for i in 0..<cs.count {
				let	v1	=	(column: Query.Identifier(name: cs[i]), value: Query.missingParameter)
				m1.append(v1)
			}
			return	m1
		}
		
		let	cs2		=	resolutionMapping()
		let	t		=	filterTreeWith(samples: cs2, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q		=	Query.Select(table: Query.Identifier(name: name), columns: Query.ColumnList.All, filter: t)
		let	x		=	q.express()
		let	stmts	=	database.prepare(code: x.code)	//	Ignore the parameters. New one will be provided.
		
		return	{ (parameters:[Value]) -> [[String:Value]] in
			return	self.database.apply { stmts.execute(parameters: parameters).all() }
		}
	}
}



























private func devaluate(ss:[String:Value]) -> [(column:Query.Identifier, value:Query.ParameterValueEvaluation)] {
	var	m2	=	[] as [(column:Query.Identifier, value:Query.ParameterValueEvaluation)]
	for (k,v) in ss {
		let	v1	=	(column: Query.Identifier(name: k), value: { v } as Query.ParameterValueEvaluation)
		m2.append(v1)
	}
	return	m2
}


