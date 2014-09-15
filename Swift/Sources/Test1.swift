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
		
		

//		func t2()
//		{
//			let	f1	=	F.Leaf(operation: Query.FilterTree.Node.Operation.Equal, column: "col1", value: "VAL1")
//			
//			var	c	=	0
//			let	q	=	Query.Select(table: $("MyTable2"), columns: CL.Items(names: [$("col1"), $("col2")]), filter: Query.FilterTree(root: f1))
//			let	s	=	q.express { () -> String in return "\(c++)" }.code
//			println(s)
//		}
//		t2()

		
	}
}










