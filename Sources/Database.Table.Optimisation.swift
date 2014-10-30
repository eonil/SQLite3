//
//  Database.Table.Optimisation.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 10/30/14.
//
//

import Foundation









public extension Database {
}

public extension Database.Table {
//	public func selection(rowsWithAllOfColumns cs:[String]) -> (parameters:[String:Value]) -> [[String:Value]] {
//		var	ps2	=	[:] as [String:Value]
//		func remap() -> [String:Value] {
//			var	m1	=	[:] as [String:Value]
//			for c in cs {
//				m1[c]	=	ps2[c]!
//			}
//			return	m1
//		}
//		
//		let	cs2		=	remap()
//		let	t		=	filterTreeWith(samples: cs2, combinationStyle: Query.FilterTree.Node.Combination.And)
//		let	q		=	Query.Select(table: Query.Identifier(name: name), columns: Query.ColumnList.All, filter: t)
//		let	x		=	q.express()
//		let	stmts	=	database.prepare(code: x.code)
//		
//		return	{ (parameters:[String:Value]) -> [[String:Value]] in
//			ps2	=	parameters
//			return	self.database.apply {stmts.execute(parameters: cs2).all()}
//		}
//	}
//	public func selection(rowsWithAnyOfColumns cs:[String])(parameters ps:[String:Value]) -> [[String:Value]] {
//	}
//	public func selection()() -> [[String:Value]] {
//		let	q	=	Query.Select(table: Query.Identifier(name: name), columns: Query.ColumnList.All, filter: nil)
//		return	snapshot(query: q)
//	}
	
	
	
//	
//	
//	
//
//	public func insert(rowWith pairs:[String:Value]) {
//		var	bs:[Query.Binding]	=	[]
//		for (k, v) in pairs
//		{
//			bs.append(Query.Binding(column: Query.Identifier(name: k), value: v))
//		}
//		let	q	=	Query.Insert(table: Query.Identifier(name: name), bindings: bs)
//		snapshot(query: q)
//	}
//	
//	
//	
//	
//	
//	public func update(rowsWithAllOf existingPairs:[String:Value], bySetting newPairs:[String:Value]) {
//		let	t	=	filterTreeWith(samples: existingPairs, combinationStyle: Query.FilterTree.Node.Combination.And)
//		let	q	=	Query.Update(table: Query.Identifier(name: name), bindings: bindingsOf(paris: newPairs), filter: t)
//		snapshot(query: q)
//	}
//	public func update(rowsWithAnyOf existingPairs:[String:Value], bySetting newPairs:[String:Value]) {
//		let	t	=	filterTreeWith(samples: existingPairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
//		let	q	=	Query.Update(table: Query.Identifier(name: name), bindings: bindingsOf(paris: newPairs), filter: t)
//		snapshot(query: q)
//	}
//	
//	
//	
//	
//	
//	
//	
//	public func delete(rowsWithAllOf pairs:[String:Value])
//	{
//		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.And)
//		let	q	=	Query.Delete(table: Query.Identifier(name: name), filter: t)
//		snapshot(query: q)
//	}
//	public func delete(rowsWithAnyOf pairs:[String:Value])
//	{
//		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
//		let	q	=	Query.Delete(table: Query.Identifier(name: name), filter: t)
//		snapshot(query: q)
//	}
//	
//	
//	
//	
//	
//	
//		
//	
//	
//	func snapshot(query q:QueryExpressible) -> [[String:Value]]
//	{
//		return	database.snapshot(query: q.express())
//	}
//		
//	func bindingsOf(paris ps:[String:Value]) -> [Query.Binding]
//	{
//		var	bs:[Query.Binding]	=	[]
//		for (k, v) in ps
//		{
//			bs.append(Query.Binding(column: Query.Identifier(name: k), value: v))
//		}
//		return	bs
//	}
//	
//	func filterTreeWith(samples ss:[String:Value], combinationStyle cs:Query.FilterTree.Node.Combination) -> Query.FilterTree
//	{
//		var	ns:[Query.FilterTree.Node]	=	[]
//		for (k, v) in ss
//		{
//			ns.append(Query.FilterTree.Node.Leaf(operation: Query.FilterTree.Node.Operation.Equal, column: Query.Identifier(name: k), value: v))
//		}
//		let	n	=	Query.FilterTree.Node.Branch(combination: cs, subnodes: ns)
//		let	t	=	Query.FilterTree(root: n)
//		return	t
//	}
}



