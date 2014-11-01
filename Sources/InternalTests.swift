//
//  Test1.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/16/14.
//
//

import Foundation

public struct Test1 {
	
	static func run(block:() -> ()) {
		block()
	}
	
	static func run(name:String, block:() -> ()) {
		block()
	}
	
	public static func test1() {
		func log<T>(object:@autoclosure()->T) {
			println(object())
		}
		
		
		typealias	Q	=	Query
		
		typealias	F	=	Q.FilterTree.Node
		typealias	FT	=	Q.FilterTree
		
		typealias	CL	=	Q.ColumnList
		
		
		
		
		
		
		
		var	pc		=	0
		let	upng	=	{ () -> String in return "@param\(pc++)" }
		
		func columns(names:[Q.Identifier]) -> Q.ColumnList
		{
			return	Q.ColumnList.Items(names: names)
		}
		
		run	{
			
			let	q	=	Query.Select.all(of: "MyTable1")
			let	s	=	q.express()
			println(s.code, s.parameters)
			
			}
		
		run	{
			
			let	f1	=	F.Leaf(operation: Query.FilterTree.Node.Operation.Equal, column: "col1", value: { 42 })
			let	s	=	f1.express()
			println(s.code, s.parameters)
			
			}
		
		run	{
			
			let	f1	=	F.Leaf(operation: Query.FilterTree.Node.Operation.Equal, column: "col1", value: { 42 })
			let	q	=	Query.Select(table: "MyTable3", columns: columns(["col1"]), filter: Q.FilterTree(root: f1))
			let	s	=	q.express()
			println(s.code, s.parameters)
			
			}
		
//		run	{
//			let	f1	=	("col1" as Q.Identifier) == (42 as Value)
//			let	q	=	Query.Select(table: "MyTable3", columns: columns(["col1"]), filter: Q.FilterTree(root: f1))
//			let	s	=	q.express()
//			println(s.code, s.parameters)
//			
//			}
//		
//		run	{
//			let	f1	=	("col1" == 42) as Q.FilterTree.Node
//			let	q	=	Query.Select(table: "MyTable3", columns: columns(["col1"]), filter: Q.FilterTree(root: f1))
//			let	s	=	q.express()
//			println(s.code, s.parameters)
//			
//		}
//		
//		run	{
//			
//			let	f1:Q.FilterTree.Node	=	"col1" == 42
//			let	f2:Q.FilterTree.Node	=	"col2" != 45
//			let	f3:Q.FilterTree.Node	=	"col4" < 2324
//			let	f4	=	f1 & f2
//			let	f5	=	f4 | f3
//			let	q	=	Query.Select(table: "MyTable3", columns: columns(["col1"]), filter: Q.FilterTree(root: f5))
//			let	s	=	q.express()
//			println(s.code, s.parameters)
//			
//		}
		

		
		
		
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.apply {
				println("DDD")
			}
		}
		
		
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.apply {
				let	s	=	db1.prepare("SELECT \"AAA\";")
				s.step()
				//	Unfinished statement.
			}
		}
		
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.apply {
				let	s	=	db1.prepare("SELECT \"AAA\";")
				s.step()
				s.step()
			}
		}
		

		
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.apply {
				let	s	=	db1.prepare("SELECT \"AAA\";")
				s.step()
				assert(s.numberOfFields == 1)
				println(s.columnNameAtIndex(0))
				assert(s[0] == "AAA")
				s.step()
				assert(s.numberOfFields == 0)
			}
		}
		
		println(Core.LeakDetector.theDetector.countAllInstances())
		assert(Core.LeakDetector.theDetector.countAllInstances() == 0)
		
		
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.schema().create(tableName: "T1", dataColumnNames: ["c1"])
			db1.apply { () -> () in
				let	s	=	db1.prepare("SELECT name FROM sqlite_master;")
				println(s.numberOfFields)
				assert(s.numberOfFields == 0)
				
				s.step()
				println(s.numberOfFields)
				println(s.columnNameAtIndex(0))
				println(s[0])
				assert(s.numberOfFields == 1)
				assert(s.columnNameAtIndex(0) == "name")
				assert(s[0] == "T1")
				s.step()
				
				assert(s.numberOfFields == 0)
			}
			
		}
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.apply {
				let	s	=	db1.prepare("SELECT \"AAA\";")
				
				s.step()
				println(s.numberOfFields)
				println(s.columnNameAtIndex(0))
				println(s[0])
				assert(s.numberOfFields == 1)
				assert(s[0] == "AAA")
				
				s.step()
			}
		}
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.apply {
				let	rs1	=	db1.prepare("SELECT \"AAA\";").execute(parameters: []).allRowsAsDictionaries()
				println(rs1)
				assert(rs1.count == 1)
			}
		}
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.schema().create(tableName: "T1", dataColumnNames: ["c1"])
			db1.apply {
				let	s	=	db1.prepare("SELECT name FROM sqlite_master;")
				
				s.step()
				
				println(s.numberOfFields)
				println(s.columnNameAtIndex(0))
				println(s[0])
				assert(s.numberOfFields == 1)
				assert(s.columnNameAtIndex(0) == "name")
				assert(s[0] == "T1")
			}
		}
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.schema().create(tableName: "T1", dataColumnNames: ["c1"])
			db1.apply {
				let	s	=	db1.prepare("SELECT name FROM sqlite_master;")
				println(s.numberOfFields)
				assert(s.numberOfFields == 0)
				
				s.step()
				println(s.numberOfFields)
				println(s.columnNameAtIndex(0))
				println(s[0])
				assert(s.numberOfFields == 1)
				assert(s.columnNameAtIndex(0) == "name")
				assert(s[0] == "T1")
				s.step()
				
				assert(s.numberOfFields == 0)
			}
		}
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.schema().create(tableName: "T1", dataColumnNames: ["c1"])
			db1.apply { () -> () in
				let	rs	=	db1.prepare("SELECT name FROM sqlite_master;").execute(parameters: []).allRowsAsDictionaries()
				for r in rs {
					println(r)
					assert(r["name"]! == "T1")
				}
			}
		}
		
		
		
		
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.schema().create(tableName: "T1", dataColumnNames: ["c1"])
			
			db1.apply { () -> () in
				db1.run("INSERT INTO T1 (c1) VALUES (123);")
				db1.run("INSERT INTO T1 (c1) VALUES (\"BBB\");")
				db1.run("INSERT INTO T1 (c1) VALUES (456.789);")
				
				let	rs	=	db1.run("SELECT * FROM T1;")
				println(rs)
				assert(rs[0]["c1"]! == 123)
				assert(rs[1]["c1"]! == "BBB")
				assert(rs[2]["c1"]! == 456.789)
			}
		}
		

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		run	{
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.schema().create(tableName: "T1", dataColumnNames: ["c1"])
		
			let	k	=	db1.schema().allRowsOfRawMasterTable()
			println(k)
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		run	{
			
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			func run() {
				let	t1	=	Schema.Table(name: "T1", key: ["c1"], columns: [Schema.Column(name: "c1", nullable: false, type: Schema.Column.TypeCode.Text, unique: false, index: nil)])
				db1.run(Query.Schema.Table.Create(temporary: false, definition: t1))
			}
			db1.apply(run)
		}
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.apply {
				let	t1	=	Schema.Table(name: "T1", key: ["c1"], columns: [Schema.Column(name: "c1", nullable: false, type: Schema.Column.TypeCode.Text, unique: false, index: nil)])
				db1.run(Query.Schema.Table.Create(temporary: false, definition: t1))
				
				let	q1	=	Query.Select(table: "T1", columns: Query.ColumnList.All, filter: nil)
				db1.run(q1)
			}
		}
		
		assert(Core.LeakDetector.theDetector.countAllInstances() == 0)
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			func run() {
				let	t1	=	Schema.Table(name: "T1", key: ["c1"], columns: [Schema.Column(name: "c1", nullable: false, type: Schema.Column.TypeCode.Text, unique: false, index: nil)])
				db1.run(Query.Schema.Table.Create(temporary: false, definition: t1))
				
				let	q1	=	Query.Insert(table: "T1", bindings: [Query.Binding(column: "C1", value: { "text1!" })])
				db1.run(q1)
				
				let	q2	=	Query.Select(table: "T1", columns: Query.ColumnList.All, filter: nil)
				for (_, r) in enumerate(db1.run(q2)) {
					println(r)
				}
			}
			db1.apply(run)
			assert(Core.LeakDetector.theDetector.countAllInstances() > 0)
		}
		
		assert(Core.LeakDetector.theDetector.countAllInstances() == 0)
		
		
		
		
		
		
		
//		run {
//			let	db1	=	Database(location: Database.Location.Memory, editable: true)
//			db1.schema().create(tableName: "T1", dataColumnNames: ["c1"])
//			
//			let	t1	=	db1.table(name: "T1")
//			t1.insert(rowWith: ["c1":"V1"])
//			
//			let	rs1	=	t1.select()
//			assert(rs1.count == 1)
//			assert(rs1[0]["c1"]!.text! == "V1")
//			
//			t1.update(rowsWithAllOf: ["c1":"V1"], bySetting: ["c1":"W2"])
//			
//			let	rs2	=	t1.select()
//			assert(rs2.count == 1)
//			assert(rs2[0]["c1"]!.text! == "W2")
//			
//			t1.delete(rowsWithAllOf: ["c1":"W2"])
//			
//			let	rs3	=	t1.select()
//			assert(rs3.count == 0)
//		}
		
		
		
		
		
		
		
		
		
		
		
		
		run {
			let	db1	=	Database(location: Database.Location.Memory, editable: true)
			db1.schema().create(tableName: "T1", keyColumnNames: ["k1"], dataColumnNames: ["c1", "c2", "c3"])
			
			let	t1	=	db1.table(name: "T1")			
			t1[111]	=	["AAA", "BBB", "CCC"]
			
			let	v2	=	t1[111]!
			println(v2)
			assert(v2.count == 3)
			assert(v2[0] == Value.Text("AAA"))
			assert(v2[1] == Value.Text("BBB"))
			assert(v2[2] == Value.Text("CCC"))
		}
		
		
		
		
		
		
		
		
//		run("prohibitionAlteringTableWhileTableObjectAlive") {
//			let	db1	=	Database(location: Database.Location.Memory, editable: true)
//			db1.schema().create(tableName: "T1", keyColumnNames: ["k1"], dataColumnNames: ["c1", "c2", "c3"])
//			
//			self.run {
//				let	t1	=	db1.table(name: "T1")
//			}
//			
//			db1.apply {
//				db1.run("ALTER TABLE T1 RENAME TO T2;")
//			}
//			
//			//			t1[[Value.Integer(111)]]	=	Record(table: t1, keys: [Value.Integer(111)], data: ["AAA", "BBB", "CCC"])
//			//			println(t1[111])
//		}
		
		
		
		
	}
}










