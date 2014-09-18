//
//  Test1.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/16/14.
//
//

import Foundation

public struct Test1
{
	public static func test1()
	{
		func log<T>(object:@autoclosure()->T)
		{
			println(object())
		}
		func shouldBe(condition:Bool)
		{
			assert(condition)
		}
		
		func run(block:() -> ())
		{
			block()
		}
		
		typealias	Q	=	Query
		
		typealias	F	=	Q.FilterTree.Node
		typealias	FT	=	Q.FilterTree
		
		typealias	CL	=	Q.ColumnList
		
		
//		class
//		counter
//		{
//			var	number	=	0
//		}
		
		var	pc		=	0
		let	upng	=	{ () -> String in return "@param\(pc++)" }
		
		func columns(names:[Q.Identifier]) -> Q.ColumnList
		{
			return	Q.ColumnList.Items(names: names)
		}
		
		run	{
			
			let	q	=	Query.Select.all(of: "MyTable1")
			let	s	=	q.express(uniqueParameterNameGenerator: upng)
			println(s.code, s.parameters)
			
			}
		
		
		run	{
			
			let	f1	=	F.Leaf(operation: Query.FilterTree.Node.Operation.Equal, column: "col1", value: 42)
			let	s	=	f1.express(uniqueParameterNameGenerator: upng)
			println(s.code, s.parameters)
			
			}
		
		run	{
			
			let	f1	=	F.Leaf(operation: Query.FilterTree.Node.Operation.Equal, column: "col1", value: 42)
			let	q	=	Query.Select(table: "MyTable3", columns: columns(["col1"]), filter: Q.FilterTree(root: f1))
			let	s	=	q.express(uniqueParameterNameGenerator: upng)
			println(s.code, s.parameters)
			
			}
		
		run	{
			
			let	f1	=	"col1" == 42
			let	q	=	Query.Select(table: "MyTable3", columns: columns(["col1"]), filter: Q.FilterTree(root: f1))
			let	s	=	q.express(uniqueParameterNameGenerator: upng)
			println(s.code, s.parameters)
			
			}
		
		run	{
			
			let	f1:Q.FilterTree.Node	=	"col1" == 42
			let	f2:Q.FilterTree.Node	=	"col2" != 45
			let	f3:Q.FilterTree.Node	=	"col4" < 2324
			let	f4	=	f1 & f2
			let	f5	=	f4 | f3
			let	q	=	Query.Select(table: "MyTable3", columns: columns(["col1"]), filter: Q.FilterTree(root: f5))
			let	s	=	q.express(uniqueParameterNameGenerator: upng)
			println(s.code, s.parameters)
			
			}
		
//		run	{
//			
//			let	db1	=	Database(location: Database.Location.Memory)
//			db1.apply({ x in
//				x.run(code: "SELECT * FROM MyTable;")
//				return
//			})
//			
//		}
		
		

		
		
		
		run{
			let	db1	=	Database(location: Database.Location.Memory, mutable: true)
			db1.schema().create(table: "T1", column: ["c1"])
			
			let	t1	=	db1.table(name: "T1")
			t1.insert(rowWith: ["c1":"V1"])
			
			let	rs1	=	t1.select()
			shouldBe(rs1.count == 1)
			shouldBe(rs1[0]["c1"]! as String == "V1")
			
			t1.update(rowsWithAllOf: ["c1":"V1"], bySetting: ["c1":"W2"])
			
			let	rs2	=	t1.select()
			shouldBe(rs2.count == 1)
			shouldBe(rs2[0]["c1"]! as String == "W2")
			
			t1.delete(rowsWithAllOf: ["c1":"W2"])
			
			let	rs3	=	t1.select()
			shouldBe(rs3.count == 0)
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		run	{
			let	db1	=	Database(location: Database.Location.Memory, mutable: true)
			db1.schema().create(table: "T1", column: ["c1"])
		
			let	k	=	db1.schema().allRowsOfRawMasterTable()
			println(k)
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		run	{
			
			let	db1	=	Database(location: Database.Location.Memory, mutable: true)
			func iter1(row:Row)
			{
				println(row.numberOfFields)
				println(row.columnNameOfField(atIndex: 0))
			}
			func run(tx:Database.Operation)
			{					
				let	t1	=	Query.Schema.Table(name: "MyTable1", key: ["col1"], columns: [Query.Schema.Column(name: "col1", nullable: false, type: Query.Schema.Column.TypeCode.Text, unique: false)])
				
				tx.execute(query: Query.Schema.Table.Create(temporary: false, definition: t1))
			}

			db1.apply(run)
			
			
		}

		run{
			let	db1	=	Database(location: Database.Location.Memory, mutable: true)
			func iter1(row:Row)
			{
				println(row.numberOfFields)
				println(row.columnNameOfField(atIndex: 0))
			}
		
			func run(tx:Database.Operation)
			{
				let	t1	=	Query.Schema.Table(name: "MyTable1", key: ["col1"], columns: [Query.Schema.Column(name: "col1", nullable: false, type: Query.Schema.Column.TypeCode.Text, unique: false)])
				tx.execute(query: Query.Schema.Table.Create(temporary: false, definition: t1))
				
				let	q1	=	Query.Select(table: "MyTable1", columns: Query.ColumnList.All, filter: nil)
				tx.execute(query: q1)
			}
		
			db1.apply(run)
		}
		
		shouldBe(Core.LeakDetector.theDetector.countAllInstances() == 0)
		
		run{
			let	db1	=	Database(location: Database.Location.Memory, mutable: true)
			func iter1(row:Row)
			{
				println(row.numberOfFields)
				println(row.columnNameOfField(atIndex: 0))
			}
		
			func run(tx:Database.Operation)
			{
				let	t1	=	Query.Schema.Table(name: "T1", key: ["C1"], columns: [Query.Schema.Column(name: "C1", nullable: false, type: Query.Schema.Column.TypeCode.Text, unique: false)])
				tx.execute(query: Query.Schema.Table.Create(temporary: false, definition: t1))
				
				let	q1	=	Query.Insert(table: "T1", bindings: [Query.Binding(column: "C1", value: "text1!")])
				tx.execute(query: q1)
				
				let	q2	=	Query.Select(table: "T1", columns: Query.ColumnList.All, filter: nil)
				tx.execute(query: q2, success: { (data:GeneratorOf<Row>) -> () in
					for r:Row in data
					{
						println(r[0])
					}
				}, failure: { (message) -> () in
				})
			}
		
			db1.apply(run)
			shouldBe(Core.LeakDetector.theDetector.countAllInstances() == 1)
		}
		
		shouldBe(Core.LeakDetector.theDetector.countAllInstances() == 0)
		
		
		
		
		
		
		
		
		
		
		
	}
}










