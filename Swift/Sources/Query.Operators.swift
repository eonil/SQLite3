//
//  Query.Operators.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/16/14.
//
//

import Foundation


func +(left:Query.Expression, right:Query.Expression) -> Query.Expression
{
	return	Query.Expression(code: left.code + right.code, parameters: left.parameters + right.parameters)
}
func +(left:Query.Expression, right:Query.Expression?) -> Query.Expression
{
	return	right == nil ? left : (left + right!)
}
func +(left:Query.Expression, right:String) -> Query.Expression
{
	return	left + Query.Expression(code: right, parameters: [])
}
func +(left:String, right:Query.Expression) -> Query.Expression
{
	return	Query.Expression(code: left, parameters: []) + right
}


func &(left:Query.FilterTree.Node, right:Query.FilterTree.Node) -> Query.FilterTree.Node
{
	return	Query.FilterTree.Node.Branch(combination: Query.FilterTree.Node.Combination.And, subnodes: [left, right])
}
func |(left:Query.FilterTree.Node, right:Query.FilterTree.Node) -> Query.FilterTree.Node
{
	return	Query.FilterTree.Node.Branch(combination: Query.FilterTree.Node.Combination.Or, subnodes: [left, right])
}

func ==(left:Query.Identifier, right:AnyObject) -> Query.FilterTree.Node
{
	return	Query.FilterTree.Node.Leaf(operation: Query.FilterTree.Node.Operation.Equal, column: left, value: right)
}
func !=(left:Query.Identifier, right:AnyObject) -> Query.FilterTree.Node
{
	return	Query.FilterTree.Node.Leaf(operation: Query.FilterTree.Node.Operation.NotEqual, column: left, value: right)
}
func <(left:Query.Identifier, right:AnyObject) -> Query.FilterTree.Node
{
	return	Query.FilterTree.Node.Leaf(operation: Query.FilterTree.Node.Operation.LessThan, column: left, value: right)
}
func >(left:Query.Identifier, right:AnyObject) -> Query.FilterTree.Node
{
	return	Query.FilterTree.Node.Leaf(operation: Query.FilterTree.Node.Operation.GreaterThan, column: left, value: right)
}
func <=(left:Query.Identifier, right:AnyObject) -> Query.FilterTree.Node
{
	return	Query.FilterTree.Node.Leaf(operation: Query.FilterTree.Node.Operation.EqualOrLessThan, column: left, value: right)
}
func >=(left:Query.Identifier, right:AnyObject) -> Query.FilterTree.Node
{
	return	Query.FilterTree.Node.Leaf(operation: Query.FilterTree.Node.Operation.EqualOrGreaterThan, column: left, value: right)
}


