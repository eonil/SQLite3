//
//  Query.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation




///	Abstracts an object which can produce a complete single query statement.
public protocol QueryExpressive
{
	func express() -> Query.Expression
}

///	Abstracts an object which can produce a fragment of a query statement.
protocol SubqueryExpressive
{
	func express(uniqueParameterNameGenerator upng:Query.UniqueParameterNameGenerator) -> Query.Expression
}







///	Safely and easily generate SQL queries.
///
///	
///
public struct Query
{
	
	public typealias	UniqueParameterNameGenerator	=	()->String							///<	Returns a unique name which is prefixed with `@` to build a parameter name.
	public typealias	ParameterNameValueMapping		=	(name:String, value:@autoclosure()->Value)
	public typealias	ParameterNameValueMappings		=	[ParameterNameValueMapping]
	public typealias	Expressive						=	(uniqueParameterNameGenerator:UniqueParameterNameGenerator)->Expression
	
	
	
	

	///	Represents a fragment of a query.
	public struct Expression : StringLiteralConvertible
	{
		public init(stringLiteral value: String) {
			self	=	Expression(code: value, parameters: [])
		}
		public init(extendedGraphemeClusterLiteral value: String) {
			self	=	Expression(code: value, parameters: [])
		}
		public init(unicodeScalarLiteral value: String) {
			self	=	Expression(code: value, parameters: [])
		}
		
		////
		
		let	code:String
		let	parameters:ParameterNameValueMappings	=	[]
		
		init(code:String, parameters:ParameterNameValueMappings) {
			self.code		=	code
			self.parameters	=	parameters
		}
		
		////
		
		static let	empty	=	Expression(code: "", parameters: [])
		
		static func byGeneratingUniqueParameterNames(using upng:UniqueParameterNameGenerator, with values:[Value]) -> Expression		///<	Returned expression's `code` will be zero length string.
		{
			let	a1	=	values.map({ (n:Value) -> ParameterNameValueMapping in return (name: upng(), value: n) })
			let	a2	=	a1.map({ n in return n.name }) as [String]
			let	s3	=	join(", ", a2) as String
			return	Expression(code: s3, parameters: a1)
		}
		static func expressionize<T:SubqueryExpressive>(using upng:UniqueParameterNameGenerator)(element:T) -> Expression
		{
			return	element.express(uniqueParameterNameGenerator: upng)
		}
		static func expressionize<T:SubqueryExpressive>(using upng:UniqueParameterNameGenerator)(elements:[T]) -> ExpressionList
		{
			return	ExpressionList(items: elements.map(expressionize(upng)))
		}
	}
	
	
	
	
	
	struct ExpressionList{
		let	items:[Expression]
		
		func concatenation() -> Expression {
			return	items.reduce(Expression.empty, combine: +)
		}
		func concatenationWith(#separator:String) -> Expression {
			return	concatenationWith(separator: Expression(code: separator, parameters: []))
		}
		func concatenationWith(#separator:Expression) -> Expression {
			func add_with_sep(left:Expression, right:Expression) -> Expression {
				return	left + separator + right
			}
			
			switch items.count {
				case 0:		return	Expression.empty
				case 1:		return	items.first!
				default:	return	items[1..<items.count].reduce(items.first!, combine: add_with_sep)
			}
		}
	}
	
	///	Beware that the number of parameters cannot exceed `Int.max`.
	///	This is Swift layer limitation.
	///	SQLite3 may have extra limits which will be applied separately.
	static func express(subquery:SubqueryExpressive) -> Expression {
		var	pc	=	0
		func upng() -> String {
			pc++
			return	"@param\(pc)"
		}
		return	subquery.express(uniqueParameterNameGenerator: upng)
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	///	Represents names such as table or column.
	public struct Identifier : SubqueryExpressive, StringLiteralConvertible, Printable
	{
		public let	name:String
		
		public init(name:String)
		{
			precondition(find(name, "\"") == nil, "Identifiers which contains double-quote(\") are not currently supported by Swift layer.")
			
			self.name	=	name
		}
		
		public init(stringLiteral value: String) {
			self	=	Identifier(name: value)
		}
		public init(extendedGraphemeClusterLiteral value: String) {
			self	=	Identifier(name: value)
		}
		public init(unicodeScalarLiteral value: String) {
			self	=	Identifier(name: value)
		}
		
		
		public var description:String
		{
			get
			{
				let		x1	=	"\"\(name)\""
				return	x1
			}
		}
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	Expression(code: description, parameters: [])
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
	
	public enum ColumnList : SubqueryExpressive
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
	public struct Binding : SubqueryExpressive
	{
		public let	column:Identifier
		public let	value:Value
		
		///	Makes `col1 = @param1` style expression.
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			let	n1	=	upng()
			return	column.express(uniqueParameterNameGenerator: upng)
				+	"="
				+	Expression(code: n1, parameters: [ParameterNameValueMapping(name: n1, value: value)])
		}
	}
//	public struct BindingList : SubqueryExpressive
//	{
//		public let	items:[Binding]
//		
//		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
//		{
//			return	Expression.expressionize(using: upng)(elements: items).concatenation()
//		}
//	}
	
	public struct FilterTree : SubqueryExpressive
	{
		public let	root:Node
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	root.express(uniqueParameterNameGenerator: upng)
		}
		
		public enum Node : SubqueryExpressive
		{
			public enum Operation : SubqueryExpressive
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

			public enum Combination : SubqueryExpressive
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
			
			case Leaf(operation:Operation, column:Identifier, value:Value)
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


