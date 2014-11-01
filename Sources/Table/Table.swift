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
///
///	Table is treated something like a dictionary with PK column (identity) and the
///	other columns (content).
public class Table {
	public typealias	Identity	=	Record.Identity
	public typealias	Content		=	Record.Content

	let	info:Internals.TableInfo
	
	let	selectRow:(identity:Identity)->Content?				///<	:returns:	data fields.
	let	insertRow:(identity:Identity,content:Content)->()		///<	:values:	data fields.
	let	deleteRow:(identity:Identity)->()
	
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
		private static func makeSelectRowCommand(table:Internals.TableInfo) -> (identity:Identity)->Content? {
			return	{ (identity:Identity)->Content? in
				let	bs	=	combine(table.keyColumnNames(), [identity])
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
					let	rs	=	s.execute([identity]).allRowValues()
					precondition(rs.count <= 1)
					return	rs.count == 0 ? nil : rs[0]
				}
			}
		}
		
		private static func makeInsertRowCommand(table:Internals.TableInfo) -> (identity:Identity, content:Content)->() {
			let	kcns	=	table.keyColumnNames()
			let	dcns	=	table.dataColumnNames()
			return	{ (identity:Identity, content:Content)->() in
				
				table.database.apply {
					let	kbs	=	Query.Binding.bind(kcns, values: [identity])
					let	dbs	=	Query.Binding.bind(dcns, values: content)
					let	q	=	Query.Insert(table: Query.Identifier(table.name), bindings: kbs+dbs)
					let	rs	=	table.database.run(q)
					assert(rs.count == 0)
				}
			}
		}
		private static func makeDeleteRowCommand(table:Internals.TableInfo) -> (identity:Identity)->() {
			let	kcns	=	table.keyColumnNames()
			let	dcns	=	table.dataColumnNames()
			return	{ (identity:Identity)->() in
				table.database.apply {
					let	bs	=	combine(kcns, [identity])
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

	public func generate() -> GeneratorOf<(Identity,Content)> {
		let	q	=	Query.Select(table: Query.Identifier(info.name), columns: Query.ColumnList.All, filter: nil)
		let	s	=	info.database.prepare(q.express().code)

		func next() -> (Identity,Content)? {
			if s.step() {
				let	r	=	s
				let	kvs	=	info.keyColumnIndexes().map {r[$0]}
				let	dvs	=	info.dataColumnIndexes().map {r[$0]}
				assert(kvs.count == 1)
				return	(kvs[0], dvs)
			} else {
				return	nil
			}
		}
		return	GeneratorOf<(Identity,Content)>(next)
		
		
//		func next() -> Record? {
//			if s.step() {
//				let	r	=	s
//				let	kvs	=	info.keyColumnIndexes().map {r[$0]}
//				let	dvs	=	info.dataColumnIndexes().map {r[$0]}
//				assert(kvs.count == 1)
//				return	Record(table: self, identity: kvs[0], content: dvs)
//			} else {
//				return	nil
//			}
//		}
//		return	GeneratorOf<Record>(next)
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

	
//	///	:id:	Key colum values. Must be ordered correctly.
//	public subscript(identity:Identity) -> Record? {
//		get {
//			let	fs	=	self.selectRow(identity: identity)
//			return	fs == nil ? nil : Record(table: self, identity: identity, content: fs!)
//		}
//		set(v) {
//			self.deleteRow(identity: identity)
//			if let v2 = v {
//				self.insertRow(identity: identity, content: v2.content)
//			}
//		}
//	}
	
	public subscript(identity:Value) -> Content? {
		get {
			return	self.selectRow(identity: identity)
		}
		set(v) {
			self.deleteRow(identity: identity)
			if let v2 = v {
				self.insertRow(identity: identity, content: v2)
			}
		}
	}
	
	public subscript(identity:Int) -> Content? {
		get {
			return	self[Value(Int64(identity))]
		}
		set(v) {
			self[Value(Int64(identity))]	=	v
		}
	}
	public subscript(identity:Int64) -> Content? {
		get {
			return	self[Value(identity)]
		}
		set(v) {
			self[Value(identity)]	=	v
		}
	}
	public subscript(identity:String) -> Content? {
		get {
			return	self[Value(identity)]
		}
		set(v) {
			self[Value(identity)]	=	v
		}
	}
	
	
	public var keys:GeneratorOf<Identity> {
		get {
			var	g	=	generate()
			return	GeneratorOf<Identity> {g.next()?.0}
		}
	}
	public var values:GeneratorOf<Content> {
		get {
			var	g	=	generate()
			return	GeneratorOf<Content> {g.next()?.1}
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




extension Table {
	public var dictionaryView:DictionaryView {
		get {
			return	DictionaryView(table: self)
		}
	}
}
























