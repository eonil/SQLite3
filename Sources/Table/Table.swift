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
	let	info:Internals.TableInfo
	
	let	selectRow:(keys:[Value])->[Value]?				///<	:returns:	data fields.
	let	insertRow:(keys:[Value],values:[Value])->()		///<	:values:	data fields.
	let	deleteRow:(keys:[Value])->()
	
	init(database:Database, name:String) {
		info	=	Internals.TableInfo.fetch(database, tableName: name)
		
		self.selectRow		=	CommandMaker.makeSelectRowCommand(info)
		self.insertRow		=	CommandMaker.makeInsertRowCommand(info)
		self.deleteRow		=	CommandMaker.makeDeleteRowCommand(info)
		
		self.info.database.notifyBornOfTableForName(info.name)
	}
	deinit {
		self.info.database.notifyDeathOfTableForName(info.name)
	}
}





extension Table {
	struct CommandMaker {
		private static func makeSelectRowCommand(table:Internals.TableInfo) -> (keys:[Value])->[Value]? {
			return	{ (keys:[Value])->[Value]? in
				let	bs	=	combine(table.keyColumnNames(), keys)
				let	dcs	=	table.dataColumnNames().map {Query.Identifier($0)}
				let	t	=	Query.FilterTree.allOfEqualColumnValues(bs)
				let	q	=	Query.Select(table: Query.Identifier(table.name), columns: Query.ColumnList.Items(names: dcs), filter: t)
				switch q.columns {
				case let Query.ColumnList.All:		println("ALL")
				case let Query.ColumnList.Items(s):	println(s)
				}
				println(q.columns)
				
				let	s	=	table.database.prepare(q.express().code)
				
				return	table.database.apply {
					let	rs	=	s.execute(keys).allRowValues()
					precondition(rs.count <= 1)
					return	rs.count == 0 ? nil : rs[0]
				}
			}
		}
		
		private static func makeInsertRowCommand(table:Internals.TableInfo) -> (keys:[Value], values:[Value])->() {
			let	kcns	=	table.keyColumnNames()
			let	dcns	=	table.dataColumnNames()
			return	{ (keys:[Value], values:[Value])->() in
				
				table.database.apply {
					let	kbs	=	Query.Binding.bind(kcns, values: keys)
					let	dbs	=	Query.Binding.bind(dcns, values: values)
					let	q	=	Query.Insert(table: Query.Identifier(table.name), bindings: kbs+dbs)
					let	rs	=	table.database.run(q)
					assert(rs.count == 0)
				}
			}
		}
		private static func makeDeleteRowCommand(table:Internals.TableInfo) -> (keys:[Value])->() {
			let	kcns	=	table.keyColumnNames()
			let	dcns	=	table.dataColumnNames()
			return	{ (keys:[Value])->() in
				table.database.apply {
					let	bs	=	combine(kcns, keys)
					let	f	=	Query.FilterTree.allOfEqualColumnValues(bs)
					let	q	=	Query.Delete(table: Query.Identifier(table.name), filter: f)
					let	rs	=	table.database.run(q)
					assert(rs.count == 0)
				}
			}
		}
	}
	
}






















extension Table: SequenceType {

	public func generate() -> GeneratorOf<Record> {
		let	q	=	Query.Select(table: Query.Identifier(info.name), columns: Query.ColumnList.All, filter: nil)
		let	s	=	info.database.prepare(q.express().code)
		
		func next() -> Record? {
			if s.step() {
				let	r	=	s
				let	kvs	=	info.keyColumnIndexes().map {r[$0]}
				let	dvs	=	info.dataColumnIndexes().map {r[$0]}
				return	Record(table: self, key: kvs, value: dvs)
			} else {
				return	nil
			}
		}
		return	GeneratorOf<Record>(next)
	}
	
//	///	Selects all rows.
//	public func all() -> [[String:Value]] {
//		let	q	=	Query.Select(table: Query.Identifier(info.name), columns: Query.ColumnList.All, filter: nil)
//		return	snapshot(query: q)
//	}
}











extension Table {

	public var count:Int {
		get {
			let	rs	=	info.database.prepare("SELECT count(*) FROM \(Query.Identifier(info.name).express().code)").execute().allRowsAsDictionaries()
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
			let	fs	=	self.selectRow(keys: id)
			return	fs == nil ? nil : Record(table: self, key: id, value: fs!)
		}
		set(v) {
			self.deleteRow(keys: id)
			if let v2 = v {
				self.insertRow(keys: id, values: v2.value)
			}
		}
	}
	
	public subscript(id:Value) -> [Value]? {
		get {
			return	self.selectRow(keys: [id])
		}
		set(v) {
			self.deleteRow(keys: [id])
			if let v2 = v {
				self.insertRow(keys: [id], values: v2)
			}
		}
	}
	
	public subscript(id:Int) -> [Value]? {
		get {
			return	self[Value(Int64(id))]
		}
		set(v) {
			self[Value(Int64(id))]	=	v
		}
	}
	public subscript(id:Int64) -> [Value]? {
		get {
			return	self[Value(id)]
		}
		set(v) {
			self[Value(id)]	=	v
		}
	}
	public subscript(id:String) -> [Value]? {
		get {
			return	self[Value(id)]
		}
		set(v) {
			self[Value(id)]	=	v
		}
	}
	
	
	public var keys:GeneratorOf<[Value]> {
		get {
			var	g	=	generate()
			return	GeneratorOf<[Value]> {g.next()?.key}
		}
	}
	public var values:GeneratorOf<[Value]> {
		get {
			var	g	=	generate()
			return	GeneratorOf<[Value]> {g.next()?.value}
		}
	}

}









///	MARK:
///	MARK:	Filtering
extension Table {

	public func filter(f:Query.FilterTree) -> Section {
		return	Section(table: self, filter: f)
	}
	
//	public func section(f:Query.FilterTree) -> Section {
//		return	Section(table: self, filter: f)
//	}
	
}





























