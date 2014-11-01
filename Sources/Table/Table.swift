//
//  Table.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 10/31/14.
//
//

import Foundation







///	Provides simple and convenient methods to get results easily on a single table.
///
///	Table object caches metadata. If you alter schema of a table, you have to make a 
///	new table object. Querying on altered table using old table object can cause
///	various problems.
public class Table {
	unowned let	database:Database
	let			name:String
	
	init(database:Database, table:String) {
		self.database		=	database
		self.name			=	table
		
		self.database.notifyBornOfTableForName(self.name)
	}
	deinit {
		self.database.notifyDeathOfTableForName(self.name)
	}
	
	///	0 based indexes.
	var keyColumnIndexes:[Int] {
		get {
			return	_kidxs
		}
	}
	///	0 based indexes.
	var dataColumnIndexes:[Int] {
		get {
			return	_didxs
		}
	}
	var keyColumnNames:[String] {
		get {
			return	_kcns
		}
	}
	var dataColumnNames:[String] {
		get {
			return	_dcns
		}
	}
	
	private lazy var _kidxs:[Int]	=	Internals.TableInfo.fetch(self.database, tableName: self.name).keyColumns().map {Int($0.cid)}
	private lazy var _didxs:[Int]	=	Internals.TableInfo.fetch(self.database, tableName: self.name).dataColumns().map {Int($0.cid)}
	
	private lazy var _kcns:[String]	=	Internals.TableInfo.fetch(self.database, tableName: self.name).keyColumns().map {$0.name}
	private lazy var _dcns:[String]	=	Internals.TableInfo.fetch(self.database, tableName: self.name).dataColumns().map {$0.name}
}






extension Table: SequenceType {

	public func generate() -> GeneratorOf<Record> {
		let	q	=	Query.Select(table: Query.Identifier(self.name), columns: Query.ColumnList.All, filter: nil)
		let	ss	=	database.prepare(q.express().code)
		assert(ss.items.count == 1)
		let	s	=	ss.items[0]
		
		func next() -> Record? {
			if s.step() {
				let	r	=	s.row()
				let	kvs	=	keyColumnIndexes.map {r[$0]}
				let	dvs	=	dataColumnIndexes.map {r[$0]}
				return	Record(table: self, keys: kvs, data: dvs)
			} else {
				return	nil
			}
		}
		return	GeneratorOf<Record>(next)
	}
	
	///	Selects all rows.
	public func all() -> [[String:Value]] {
		let	q	=	Query.Select(table: Query.Identifier(self.name), columns: Query.ColumnList.All, filter: nil)
		return	snapshot(query: q)
	}
	
	public var count:Int {
		get {
			let	rs	=	database.prepare("SELECT count(*) FROM \(Query.Identifier(self.name).express().code)").execute(parameters: []).all()
			assert(rs.count == 0)
			assert(rs[0].count == 1)
			let	r	=	rs[0]
			let	v	=	r[r.startIndex]
			return	Int(v.1.integer!)
		}
	}

	
	///	:id:	Key colum values. Must be ordered correctly.
	public subscript(id:[Value]) -> Record? {
		get {
			let	bs	=	combine(keyColumnNames, id)
			let	dcs	=	dataColumnNames.map {Query.Identifier($0)}
			let	t	=	filterTreeWith(samples: bs, combinationStyle: Query.FilterTree.Node.Combination.And)
			let	q	=	Query.Select(table: Query.Identifier(self.name), columns: Query.ColumnList.Items(names: dcs), filter: t)
			switch q.columns {
			case let Query.ColumnList.All:		println("ALL")
			case let Query.ColumnList.Items(s):	println(s)
			}
			println(q.columns)
			let	fs	=	database.apply {
				let	x	=	self.database.prepare(q.express().code).execute(parameters: id)
				let r = x.next()
				assert(r != nil)
				let	fs	=	scanAllFieldValues(r!)
				let r2 = x.next()
				assert(r2 == nil)
				return	fs
			} as [Value]
			return	Record(table: self, keys: id, data: fs)
		}
		set(v) {
			let	kcns	=	keyColumnNames
			let	dcns	=	dataColumnNames
			
			database.apply {
				
				let	bs	=	combine(kcns, id)
				let	q	=	Query.Delete(table: Query.Identifier(self.name), filter: self.filterTreeWith(samples: bs, combinationStyle: Query.FilterTree.Node.Combination.And))
				let	rs	=	self.snapshot(query: q)
				assert(rs.count == 0)
				
				////
				
				if let v2 = v {
					precondition(v!.table === self, "You're setting a record from another table object. Don't.")
					
					let	kbs	=	Query.Binding.bind(kcns, values: id)
					let	dbs	=	Query.Binding.bind(dcns, values: v2.data)
					let	q	=	Query.Insert(table: Query.Identifier(self.name), bindings: kbs+dbs)
					let	rs	=	self.snapshot(query: q)
					assert(rs.count == 0)
					assert(self[id] != nil)
				} else {
					assert(self[id] == nil)
				}

			}
			
		}
	}
	
	///	:id:	Key column value.
	public subscript(id:Value) -> Record? {
		get {
			return	self[[id]]
		}
		set(v) {
			self[[id]]	=	v
		}
	}
	public subscript(id:Int) -> Record? {
		get {
			return	self[Value(Int64(id))]
		}
		set(v) {
			self[Value(Int64(id))]	=	v
		}
	}
	public subscript(id:Int64) -> Record? {
		get {
			return	self[Value(id)]
		}
		set(v) {
			self[Value(id)]	=	v
		}
	}
	public subscript(id:String) -> Record? {
		get {
			return	self[Value(id)]
		}
		set(v) {
			self[Value(id)]	=	v
		}
	}
}














extension Table {
	
	public func select(rowsWithAllOf pairs:[String:Value]) -> [[String:Value]] {
//		let	ss	=	splitPairs(pairs)
//		return	cacheableSelect(rowsWithAllOfColumns: ss.keys)(parameters: ss.values)
		
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q	=	Query.Select(table: Query.Identifier(name), columns: Query.ColumnList.All, filter: t)
		return	snapshot(query: q)
	}
	public func select(rowsWithAnyOf pairs:[String:Value]) -> [[String:Value]] {
//		let	ss	=	splitPairs(pairs)
//		return	cacheableSelect(rowsWithAnyOfColumns: ss.keys)(parameters: ss.values)
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
		let	q	=	Query.Select(table: Query.Identifier(name), columns: Query.ColumnList.All, filter: t)
		return	snapshot(query: q)
	}
	///	Selects all rows.
	public func select() -> [[String:Value]] {
		let	q	=	Query.Select(table: Query.Identifier(name), columns: Query.ColumnList.All, filter: nil)
		return	snapshot(query: q)
	}
	
	
	
	
	
	

	public func insert(rowWith pairs:[String:Value]) {
		var	bs:[Query.Binding]	=	[]
		for (c, v) in devaluate(pairs)
		{
			bs.append(Query.Binding(column: c, value: v))
		}
		let	q	=	Query.Insert(table: Query.Identifier(name), bindings: bs)
		snapshot(query: q)
	}
	///	Performs multiple inserts.
	///	Columns can different for all each rows.
	///	So this performs slow insert. If you have rows for all same columns,
	///	consider using `insertion` method
	///	for better performance using prepared statement.
	public func insert(rows:[[String:Value]]) {
		for r in rows {
			insert(rowWith: r)
		}
	}
	
	
	
	
	
	
	
	public func update(rowsWithAllOf existingPairs:[String:Value], bySetting newPairs:[String:Value])
	{
		let	t	=	filterTreeWith(samples: existingPairs, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q	=	Query.Update(table: Query.Identifier(name), bindings: bindingsOf(paris: newPairs), filter: t)
		snapshot(query: q)
	}
	public func update(rowsWithAnyOf existingPairs:[String:Value], bySetting newPairs:[String:Value])
	{
		let	t	=	filterTreeWith(samples: existingPairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
		let	q	=	Query.Update(table: Query.Identifier(name), bindings: bindingsOf(paris: newPairs), filter: t)
		snapshot(query: q)
	}
	
	
	
	
	
	
	
	public func delete(rowsWithAllOf pairs:[String:Value])
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.And)
		let	q	=	Query.Delete(table: Query.Identifier(name), filter: t)
		snapshot(query: q)
	}
	public func delete(rowsWithAnyOf pairs:[String:Value])
	{
		let	t	=	filterTreeWith(samples: pairs, combinationStyle: Query.FilterTree.Node.Combination.Or)
		let	q	=	Query.Delete(table: Query.Identifier(name), filter: t)
		snapshot(query: q)
	}
	
	
	
	
	
	
		
	
	
	func snapshot(query q:QueryExpressible) -> [[String:Value]] {
		return
			database.apply {
				return	q >> self.database.run
			}
	}
		
	func bindingsOf(paris ps:[String:Value]) -> [Query.Binding] {
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


































public extension Table {
	private func selection(mode m:Query.FilterTree.Node.Combination, filterColumns cs:[String]) -> (constraintValues:[Value]) -> [[String:Value]] {
		let	cs2		=	parameterMappings(cs)
		let	t		=	filterTreeWith(samples: cs2, combinationStyle: m)
		let	q		=	Query.Select(table: Query.Identifier(name), columns: Query.ColumnList.All, filter: t)
		let	x		=	q.express()
		let	stmts	=	database.prepare(x.code)	//	Ignore the parameters. New one will be provided.
		let	cc		=	cs.count
		
		return	{ (parameters:[Value]) -> [[String:Value]] in
			precondition(cc == parameters.count, "Parameter count doesn't match.")
			return	self.database.apply {
				stmts.execute(parameters: parameters).all()
			}
		}
	}
	public func selection(valuesInColumns cs:[String]) -> (equalsTo:[Value]) -> [[String:Value]] {
		return	selection(mode: Query.FilterTree.Node.Combination.And, filterColumns: cs)
	}

	///	Optimised batched inserts.
	///	This uses prepared statement.
	///
	///	:columns:	Column names for insertion.
	///	:values:	A table of values for columns and rows to be inserted.
	public func insertion(columns cs:[String]) -> (values:[[Value]]) -> () {
		let	cs2		=	parameterMappings(cs)
		let	bs		=	cs2.map { Query.Binding($0) }
		let	q		=	Query.Insert(table: Query.Identifier(self.name), bindings: bs)
		let	x		=	q.express()
		let	stmts	=	database.prepare(x.code)	//	Ignore the parameters. New one will be provided.
		let	cc		=	cs.count
		
		return	{ (vss:[[Value]])->() in
			self.database.apply {
				precondition(stmts.items.count == 1)
				let	stmt1	=	stmts.items[0]
				for vs1 in vss {
					precondition(cc == vs1.count, "Parameter count doesn't match.")
					stmt1.bind2(parameters: vs1)
				}
			}
		}
	}
//
//	public func update(destinationColumns cs:[String], filterColumns:[String]) -> ((sourceValues:[[Value]], constraintValues:[Value])]) -> () {
//		
//	}
	
	
	
}


private func parameterMappings(cs:[String]) -> [(column: Query.Identifier, value:Query.ParameterValueEvaluation)] {
	var	m1	=	[] as [(column: Query.Identifier, value:Query.ParameterValueEvaluation)]
	for i in 0..<cs.count {
		let	v1	=	(column: Query.Identifier(cs[i]), value: Query.missingParameter)
		m1.append(v1)
	}
	return	m1
}

private func devaluate(ss:[String:Value]) -> [(column:Query.Identifier, value:Query.ParameterValueEvaluation)] {
	var	m2	=	[] as [(column:Query.Identifier, value:Query.ParameterValueEvaluation)]
	for (k,v) in ss {
		let	v1	=	(column: Query.Identifier(k), value: { v } as Query.ParameterValueEvaluation)
		m2.append(v1)
	}
	return	m2
}

private func splitPairs <K,V> (dict1:[K:V]) -> (keys:[K], values:[V]) {
	let	ns	=	[K](dict1.keys)
	let	vs	=	[V](dict1.values)
	return	(ns,vs)
}

private func scanAllFieldValues(r:Row) -> [Value] {
	var	fs	=	[] as [Value]
	for i in 0..<r.numberOfFields {
		fs.append(r[i])
	}
	return	fs
}











































