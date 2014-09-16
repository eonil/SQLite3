//
//  Query.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation







///	A marker protocol to mark a qeury object runnable.
public protocol QueryRunnable
{
}

///	Abstracts single query statement.
protocol QueryExpressive
{
	func express(uniqueParameterNameGenerator upng:Query.UniqueParameterNameGenerator) -> Query.Expression
}







///	Safely and easily generate SQL queries.
///
///	
///
public struct Query
{
	
	public typealias	UniqueParameterNameGenerator	=	() -> String
	public typealias	ParameterNameValueMapping		=	(name:String, value:AnyObject)
	public typealias	ParameterNameValueMappings		=	[ParameterNameValueMapping]
	public typealias	Expressive						=	(uniqueParameterNameGenerator:UniqueParameterNameGenerator) -> Expression
	
	
	
	

	///	Represents a fragment of a query.
	public struct Expression : StringLiteralConvertible
	{
		let	code:String
		let	parameters:ParameterNameValueMappings	=	[]
		
		
		
		static let	empty	=	Expression(code: "", parameters: [])
		
		static func byGeneratingUniqueParameterNames(using upng:UniqueParameterNameGenerator, with values:[AnyObject]) -> Expression		///<	Returned expression's `code` will be zero length string.
		{
			let	a1	=	values.map({ (n:AnyObject) -> ParameterNameValueMapping in return (name: upng(), value: n) })
			let	a2	=	a1.map({ n in return n.name }) as [String]
			let	s3	=	join(", ", a2) as String
			return	Expression(code: s3, parameters: a1)
		}
		static func expressionize<T:QueryExpressive>(using upng:UniqueParameterNameGenerator)(element:T) -> Expression
		{
			return	element.express(uniqueParameterNameGenerator: upng)
		}
		static func expressionize<T:QueryExpressive>(using upng:UniqueParameterNameGenerator)(elements:[T]) -> ExpressionList
		{
			return	ExpressionList(items: elements.map(expressionize(upng)))
		}
		
		
		
		public static func convertFromStringLiteral(value: String) -> Expression
		{
			return	Expression(code: value, parameters: [])
		}
		
		public static func convertFromExtendedGraphemeClusterLiteral(value: String) -> Expression
		{
			return	Expression(code: value, parameters: [])
		}
	}
	struct ExpressionList
	{
		let	items:[Expression]
		
		func concatenation() -> Expression
		{
			return	items.reduce(Expression.empty, combine: +)
		}
		func concatenationWith(#separator:String) -> Expression
		{
			return	concatenationWith(separator: Expression(code: separator, parameters: []))
		}
		func concatenationWith(#separator:Expression) -> Expression
		{
			func add_with_sep(left:Expression, right:Expression) -> Expression
			{
				return	left + separator + right
			}
			
			switch items.count {
				case 0:		return	Expression.empty
				case 1:		return	items.first!
				default:	return	items[1..<items.count].reduce(items.first!, combine: add_with_sep)
			}
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	///	Represents names such as table or column.
	public struct Identifier : QueryExpressive, StringLiteralConvertible
	{
		public let	name:String
		
		public init(name:String)
		{
			precondition(find(name, "\"") == nil, "Identifier containing double-quote(\") is not currently supported by Swift layer.")
			
			self.name	=	name
		}
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			let	x1	=	"\"\(name)\""
			return	Expression(code: x1, parameters: [])
		}

		public static func convertFromStringLiteral(value: String) -> Identifier
		{
			return	Identifier(name: value)
		}
		
		public static func convertFromExtendedGraphemeClusterLiteral(value: String) -> Identifier
		{
			return	Identifier(name: value)
		}
	}
	
	public enum ColumnList : QueryExpressive
	{
		case All
		case Items(names:[Identifier])
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			switch self
			{
				case let All:
					return	Expression(code: "*", parameters: [])
				
				case let Items(names: names):
					return	Expression.expressionize(using: upng)(elements: names).concatenation()
			}
		}
	}
	
	///	Only for value setting expression.
	public struct Binding : QueryExpressive
	{
		public let	column:Identifier
		public let	value:AnyObject
		
		///	Makes `col1 = @param1` style expression.
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	column.express(uniqueParameterNameGenerator: upng)
				+	"="
				+	Expression(code: "", parameters: [ParameterNameValueMapping(name: upng(), value: value)])
		}
	}
	public struct BindingList : QueryExpressive
	{
		public let	items:[Binding]
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	Expression.expressionize(using: upng)(elements: items).concatenation()
		}
	}
	
	public struct FilterTree : QueryExpressive
	{
		public let	root:Node
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	root.express(uniqueParameterNameGenerator: upng)
		}
		
		public enum Node : QueryExpressive
		{
			public enum Operation : QueryExpressive
			{
				case Equal
				case NotEqual
				case LessThan
				case GreaterThan
				case EqualOrLessThan
				case EqualOrGreaterThan
//				case Between
//				case Like
//				case In
				
				func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
				{
					switch self
					{
						case .Equal:				return	Expression(code: "=", parameters: [])
						case .NotEqual:				return	Expression(code: "<>", parameters: [])
						case .LessThan:				return	Expression(code: "<", parameters: [])
						case .GreaterThan:			return	Expression(code: ">", parameters: [])
						case .EqualOrLessThan:		return	Expression(code: "<=", parameters: [])
						case .EqualOrGreaterThan:	return	Expression(code: ">=", parameters: [])
					}
				}
			}

			public enum Combination : QueryExpressive
			{
				case And
				case Or
				
				func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
				{
					switch self
					{
						case .And:	return	Expression(code: "AND", parameters: [])
						case .Or:	return	Expression(code: "OR", parameters: [])
					}
				}
			}
			
			case Leaf(operation:Operation, column:Identifier, value:AnyObject)
			case Branch(combination:Combination, subnodes:[Node])
			
			func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
			{
				switch self
				{
					case let Leaf(operation: op, column: col, value: val):
						let	pn	=	upng()
						return	col.express(uniqueParameterNameGenerator: upng)
						+		op.express(uniqueParameterNameGenerator: upng)
						+		Expression(code: pn, parameters: [(pn, val)])
					
					case let Branch(combination: comb, subnodes: ns):
						let	x1	=	" " + comb.express(uniqueParameterNameGenerator: upng) + " "
						return	Expression.expressionize(using: upng)(elements: ns).concatenationWith(separator: x1)
				}
			}
		}
		
	}
	
	
	
	
	
	
	
		
}


