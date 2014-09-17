////
////  Database.Snapshot.swift
////  EonilSQLite3
////
////  Created by Hoon H. on 9/17/14.
////
////
//
//import Foundation
//
/////	Provides simple and convenient methods to get results easily.
//extension Database
//{
//	public typealias	Snapshot	=	[[String:AnyObject]]
//	
//	///	Returns empty result (array) on error.
//	///	The error-handler will be called on error.
//	///	Transaction will be rollback on any error, 
//	///	and nothing will be changed.
//	public func select(q:Query.Select, error e:ErrorHandler=Default.crash) -> Snapshot
//	{
//		return	snapshot(query: q, error: e)
//	}
//	public func select(table tname:String, withAllOf spairs:[String:AnyObject], error e:ErrorHandler) -> Snapshot
//	{
//		let	t	=	filterTreeWith(samples: spairs, combinationStyle: Query.FilterTree.Node.Combination.And)
//		let	q	=	Query.Select(table: Query.Identifier(name: tname), columns: Query.ColumnList.All, filter: t)
//		return	select(q, error: e)
//	}
//	public func select(table tname:String, withAllOf spairs:[String:AnyObject]) -> Snapshot
//	{
//		return	select(table: tname, withAllOf: spairs, error: Default.crash)
//	}
//	public func select(table tname:String, withAnyOf spairs:[String:AnyObject], error e:ErrorHandler) -> Snapshot
//	{
//		let	t	=	filterTreeWith(samples: spairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
//		let	q	=	Query.Select(table: Query.Identifier(name: tname), columns: Query.ColumnList.All, filter: t)
//		return	select(q, error: e)
//	}
//	public func select(table tname:String, withAnyOf spairs:[String:AnyObject]) -> Snapshot
//	{
//		return	select(table: tname, withAnyOf: spairs, error: Default.crash)
//	}
//	public func select(table tname:String, error e:ErrorHandler) -> Snapshot
//	{
//		let	q	=	Query.Select(table: Query.Identifier(name: tname), columns: Query.ColumnList.All, filter: nil)
//		return	select(q, error: e)
//	}
//	public func select(table tname:String) -> Snapshot
//	{
//		return	select(table: tname, error: Default.crash)
//	}
//
//	
//	
//	
//
//
//	public func insert(q:Query.Insert, error e:ErrorHandler)
//	{
//		snapshot(query: q, error: e)
//	}
//	public func insert(table tname:String, bindings:[String:AnyObject], error e:ErrorHandler)
//	{
//		var	bs:[Query.Binding]	=	[]
//		for (k, v) in bindings
//		{
//			bs.append(Query.Binding(column: Query.Identifier(name: k), value: v))
//		}
//		insert(Query.Insert(table: Query.Identifier(name: tname), bindings: bs), error: e)
//	}
//	public func insert(table tname:String, values:[String:AnyObject])
//	{
//		insert(table: tname, bindings: values, error: Default.crash)
//	}
//	
//	
//	
//	
//	
//	public func update(rowsOfTable tname:String, withReplacements:[String:AnyObject], ifHasAllOf preconditions:[String:AnyObject], error e:ErrorHandler)
//	{
//		var	bs:[Query.Binding]	=	[]
//		for (k, v) in withReplacements
//		{
//			bs.append(Query.Binding(column: Query.Identifier(name: k), value: v))
//		}
//		let	q	=	Query.Update(table: Query.Identifier(name: tname), bindings: bs, filter: nil)
//		snapshot(query: q, error: e)
//	}
//	public func update(rowsOfTable tname:String, withReplacements:[String:AnyObject], ifHasAllOf preconditions:[String:AnyObject])
//	{
//		update(rowsOfTable: tname, withReplacements: withReplacements, ifHasAllOf: preconditions, error: Default.crash)
//	}
//	public func update(rowsOfTable tname:String, withReplacements:[String:AnyObject], hasAnyOf spairs:[String:AnyObject], error e:ErrorHandler)
//	{
//		var	bs:[Query.Binding]	=	[]
//		for (k, v) in withReplacements
//		{
//			bs.append(Query.Binding(column: Query.Identifier(name: k), value: v))
//		}
//		let	q	=	Query.Update(table: Query.Identifier(name: tname), bindings: bs, filter: nil)
//		snapshot(query: q, error: e)
//	}
//	public func update(rowsOfTable tname:String, withReplacements:[String:AnyObject], withAnyOf spairs:[String:AnyObject])
//	{
//		update(rowsOfTable: tname, withReplacements: withReplacements, withAnyOf: spairs, error: Default.crash)
//	}
//	
//	
//	
//	
//	
//	
//	
//	
//	public func delete(q:Query.Delete, error e:ErrorHandler)
//	{
//		snapshot(query: q, error: e)
//	}
//	public func delete(table tname:String, withAllOf spairs:[String:AnyObject], error e:ErrorHandler)
//	{
//		let	t	=	filterTreeWith(samples: spairs, combinationStyle: Query.FilterTree.Node.Combination.And)
//		let	q	=	Query.Delete(table: Query.Identifier(name: tname), filter: t)
//		snapshot(query: q, error: e)
//	}
//	public func delete(table tname:String, withAllOf spairs:[String:AnyObject])
//	{
//		delete(table: tname, withAllOf: spairs, error: Default.crash)
//	}
//	public func delete(table tname:String, withAnyOf spairs:[String:AnyObject], error e:ErrorHandler)
//	{
//		let	t	=	filterTreeWith(samples: spairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
//		let	q	=	Query.Delete(table: Query.Identifier(name: tname), filter: t)
//		snapshot(query: q, error: e)
//	}
//	public func delete(table tname:String, withAnyOf spairs:[String:AnyObject])
//	{
//		delete(table: tname, withAnyOf: spairs, error: Default.crash)
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
//	
//	
//	public func create(table tname:String, column cnames:[String])
//	{
//		create(table: tname, column: cnames, error: Default.crash)
//	}
//	public func create(table tname:String, column cnames:[String], error e:ErrorHandler)
//	{
//		func columnize(name:String) -> Query.Schema.Column
//		{
//			return	Query.Schema.Column(name: Query.Identifier(name: name), nullable: true, type: Query.Schema.Column.TypeCode.None, unique: false)
//		}
//		let	cs	=	cnames.map(columnize)
//		let	def	=	Query.Schema.Table(name: Query.Identifier(name: tname), key: [], columns: cs)
//		let	cmd	=	Query.Schema.Table.Create(temporary: false, definition: def)
//		create(table: cmd, error: e)
//	}
//	public func create(table q:Query.Schema.Table.Create, error e:ErrorHandler=Default.crash)
//	{
//		snapshot(query: q, error: e)
//	}
//	public func drop(table tname:String)
//	{
//		drop(table: tname, error: Default.crash)
//	}
//	public func drop(table tname:String, error e:ErrorHandler)
//	{
//		drop(table: Query.Schema.Table.Drop(name: Query.Identifier(name: tname), ifExists: false), error: e)
//	}
//	public func drop(table q:Query.Schema.Table.Drop, error e:ErrorHandler=Default.crash)
//	{
//		snapshot(query: q, error: e)
//	}
//	
//	
//	
//	
//	func snapshot(query q:SubqueryExpressive, error e:ErrorHandler=Default.crash) -> Snapshot
//	{
//		var	s	=	Snapshot()
//		func transact(operation:Operation) -> Bool
//		{
//			var	ok	=	false
////			func success(data:GeneratorOf<Row>)
////			{
////				var	vs	=	[[String:AnyObject]]()
////				for row in data
////				{
////					var	m	=	[String:AnyObject]()
////					let	c	=	row.numberOfFields
////					for i in 0..<c
////					{
////						if	row.isNullField(atIndex: i) == false
////						{
////							let	n:String	=	row.columnNameOfField(atIndex: i)
////							let	v:AnyObject	=	row[i]
////							
////							m[n]	=	v
////						}
////					}
////					vs	+=	[m]
////				}
////				
////				s	=	vs
////				ok	=	true
////			}
////			func failure(message:String)
////			{
////				e(message: message)
////			}
////			operation.execute(query: q, success: success, failure: failure)
//			return	ok
//		}
//		applyOptionally(transact)
//		return	s
//	}
//	func filterTreeWith(samples ss:[String:AnyObject], combinationStyle cs:Query.FilterTree.Node.Combination) -> Query.FilterTree
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
//}
//
//
//
//
//
//
//
//
