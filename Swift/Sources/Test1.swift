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
		

		run	{
			
				let	db1	=	Database(location: Database.Location.Memory, mutable: true)
				func iter1(row:Row)
				{
					println(row.numberOfFields)
					println(row.nameOfColumn(atIndex: 0))
				}
				func run(tx:Database.Operation)
				{					
					let	t1	=	Query.Schema.Table(name: "MyTable1", key: ["col1"], columns: [Query.Schema.Column(name: "col1", nullable: false, ordering: Query.Schema.Column.Ordering.Ascending, type: Query.Schema.Column.TypeCode.Text, unique: false)])
					
					tx.run(query: Query.Schema.Table.Create(temporary: false, definition: t1))
				}
			
				db1.apply(run)
			
			}

//		run	{
//			
//				let	db1	=	Database(location: Database.Location.Memory)
//				func iter1(row:Row)
//				{
//					println(row.numberOfFields)
//					println(row.nameOfColumn(atIndex: 0))
//				}
//				db1.apply({ x in
//					x.run(code: "SELECT * FROM MyTable;")
//					return
//				})
//			
//			}
		
		
		run{
			let	db1	=	Database(location: Database.Location.Memory, mutable: true)
			func iter1(row:Row)
			{
				println(row.numberOfFields)
				println(row.nameOfColumn(atIndex: 0))
			}
		
			func run(tx:Database.Operation)
			{
				let	t1	=	Query.Schema.Table(name: "MyTable1", key: ["col1"], columns: [Query.Schema.Column(name: "col1", nullable: false, ordering: Query.Schema.Column.Ordering.Ascending, type: Query.Schema.Column.TypeCode.Text, unique: false)])
				tx.run(query: Query.Schema.Table.Create(temporary: false, definition: t1))
				
				let	q1	=	Query.Select(table: "MyTable1", columns: Query.ColumnList.All, filter: nil)
				tx.run(query: q1)
			}
		
			db1.apply(run)
		}
		
		
		run{
			let	db1	=	Database(location: Database.Location.Memory, mutable: true)
			func iter1(row:Row)
			{
				println(row.numberOfFields)
				println(row.nameOfColumn(atIndex: 0))
			}
		
			func run(tx:Database.Operation)
			{
				let	t1	=	Query.Schema.Table(name: "T1", key: ["C1"], columns: [Query.Schema.Column(name: "C1", nullable: false, ordering: Query.Schema.Column.Ordering.Ascending, type: Query.Schema.Column.TypeCode.Text, unique: false)])
				tx.run(query: Query.Schema.Table.Create(temporary: false, definition: t1))
				
				let	q1	=	Query.Insert(table: "T1", bindings: [Query.Binding(column: "C1", value: "text1!")])
				tx.run(query: q1)
				
				let	q2	=	Query.Select(table: "T1", columns: Query.ColumnList.All, filter: nil)
				tx.run(query: q2, success: { (data:GeneratorOf<Row>) -> () in
					for r:Row in data
					{
						println(r[0])
					}
				}, failure: { (message) -> () in
					
				})
			}
		
			db1.apply(run)
		}
		
		
		
		
		
		
		
		
		
		
		
		
	}
}










