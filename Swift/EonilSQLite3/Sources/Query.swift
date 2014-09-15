//
//  Query.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation



protocol
QueryExpressive
{
	func express(uniqueParameterNameGenerator upng:Query.UniqueParameterNameGenerator) -> Query.Expression
}

struct Query
{
	
	typealias	UniqueParameterNameGenerator	=	() -> String
	typealias	ParameterNameValueMapping		=	(name:String, value:AnyObject)
	typealias	ParameterNameValueMappings		=	[ParameterNameValueMapping]
	typealias	Expressive						=	(uniqueParameterNameGenerator:UniqueParameterNameGenerator) -> Expression
	
	
	
	

	///	Represents a fragment of a query.
	struct
	Expression : StringLiteralConvertible
	{
		let	code:String
		let	parameters:ParameterNameValueMappings	=	[]
		
		
		
		static let	empty	=	Expression(code: "", parameters: [])
		
		static func byGeneratingUniqueParameterNames(using upng:UniqueParameterNameGenerator, with values:[AnyObject]) -> Expression		///<	Returned expression's `code` will be zero length string.
		{
			let	a1	=	values.map({ (n:AnyObject) -> ParameterNameValueMapping in return (name: upng(), value: n) })
			return	Expression(code: "", parameters: a1)
		}
		static func expressionize<T:QueryExpressive>(using upng:UniqueParameterNameGenerator)(element:T) -> Expression
		{
			return	element.express(uniqueParameterNameGenerator: upng)
		}
		static func expressionize<T:QueryExpressive>(using upng:UniqueParameterNameGenerator)(elements:[T]) -> ExpressionList
		{
			return	ExpressionList(items: elements.map(expressionize(upng)))
		}
		
		
		
		static func convertFromStringLiteral(value: String) -> Expression
		{
			return	Expression(code: value, parameters: [])
		}
		
		static func convertFromExtendedGraphemeClusterLiteral(value: String) -> Expression
		{
			return	Expression(code: value, parameters: [])
		}
	}
	struct
	ExpressionList
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
			return	items.reduce(Expression.empty, combine: add_with_sep)
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	///	Represents names such as table or column.
	struct Identifier : QueryExpressive, StringLiteralConvertible
	{
		let	name:String
		
		init(name:String)
		{
			precondition(find(name, "\"") == nil, "Identifier containing double-quote(\") is not currently supported by Swift layer.")
			
			self.name	=	name
		}
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			let	x1	=	"\"\(name)\""
			return	Expression(code: x1, parameters: [])
		}

		static func convertFromStringLiteral(value: String) -> Identifier
		{
			return	Identifier(name: value)
		}
		
		static func convertFromExtendedGraphemeClusterLiteral(value: String) -> Identifier
		{
			return	Identifier(name: value)
		}
	}
	
	enum
	ColumnList : QueryExpressive
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
	struct Binding : QueryExpressive
	{
		let	column:Identifier
		let	value:AnyObject
		
		///	Makes `col1 = @param1` style expression.
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	column.express(uniqueParameterNameGenerator: upng)
				+	"="
				+	Expression(code: "", parameters: [ParameterNameValueMapping(name: upng(), value: value)])
		}
	}
	struct BindingList : QueryExpressive
	{
		let	items:[Binding]
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	Expression.expressionize(using: upng)(elements: items).concatenation()
		}
	}
	
	struct
	FilterTree : QueryExpressive
	{
		let	root:Node
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	root.express(uniqueParameterNameGenerator: upng)
		}
		
		enum Node : QueryExpressive
		{
			enum Operation : QueryExpressive
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

			enum Combination : QueryExpressive
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


