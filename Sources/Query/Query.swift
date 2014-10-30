//
//  Query.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation




///	Abstracts an object which can produce a fragment of a query statement.
public protocol QueryExpressible {
	func express() -> Query.Expression
}








///	Safely and easily generate SQL queries.
public struct Query {
	
	public typealias	UniqueParameterNameGenerator	=	()->String							///<	Returns a unique name which is prefixed with `@` to build a parameter name.
	public typealias	ParameterNameValueMapping		=	(name:String, value:@autoclosure()->Value)
	public typealias	ParameterNameValueMappings		=	[ParameterNameValueMapping]
	public typealias	Expressible						=	(uniqueParameterNameGenerator:UniqueParameterNameGenerator)->Expression
	
	
	
	

	///	Represents a fragment of a query.
	public struct Expression : StringLiteralConvertible {
		let	code									=	""
		let	parameters:ParameterNameValueMappings	=	[]

		init(_ code:String) {
			self.init(code: code, parameters: [])
		}
		init(code:String, parameters:ParameterNameValueMappings) {
			self.code		=	code
			self.parameters	=	parameters
		}
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
		
		static let	empty	=	Expression(code: "", parameters: [])
		
		///	Returned expression's `code` will be zero length string.
		static func byGeneratingUniqueParameterNames(values:[Value]) -> Expression {
			let	a1	=	values.map({ (n:Value) -> ParameterNameValueMapping in return (name: "?", value: n) })
			let	a2	=	a1.map({ n in return n.name }) as [String]
			let	s3	=	join(", ", a2) as String
			return	Expression(code: s3, parameters: a1)
		}
		static func expressionize<T:QueryExpressible>(#element:T) -> Expression
		{
			return	element.express()
		}
		static func expressionize<T:QueryExpressible>(#elements:[T]) -> ExpressionList
		{
//			return	ExpressionList(items: elements.map(T.express)
			return	ExpressionList(items: elements.map(expressionize))
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
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	///	Represents names such as table or column.
	public struct Identifier : QueryExpressible, StringLiteralConvertible, Printable
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
		
		public func express() -> Query.Expression
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
	
	public enum ColumnList : QueryExpressible
	{
		case All
		case Items(names:[Identifier])
		
		public func express() -> Query.Expression
		{
			switch self
			{
				case let All:
					return	Expression(code: "*", parameters: [])
				
				case let Items(names: names):
					return	Expression.expressionize(elements: names).concatenation()
			}
		}
	}
	
	///	Only for value setting expression.
	public struct Binding : QueryExpressible
	{
		public let	column:Identifier
		public let	value:Value
		
		///	Makes `col1 = @param1` style expression.
		public func express() -> Query.Expression
		{
			return	column.express()
				+	"="
				+	Expression(code: "?", parameters: [ParameterNameValueMapping(name: "?", value: value)])
		}
	}
//	public struct BindingList : SubqueryExpressible
//	{
//		public let	items:[Binding]
//		
//		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
//		{
//			return	Expression.expressionize(using: upng)(elements: items).concatenation()
//		}
//	}
	
	public struct FilterTree : QueryExpressible
	{
		public let	root:Node
		
		public func express() -> Query.Expression
		{
			return	root.express()
		}
		
		public enum Node : QueryExpressible
		{
			public enum Operation : QueryExpressible
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
				
				public func express() -> Query.Expression
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

			public enum Combination : QueryExpressible
			{
				case And
				case Or
				
				public func express() -> Query.Expression
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
			
			public func express() -> Query.Expression
			{
				switch self
				{
					case let Leaf(operation: op, column: col, value: val):
						return	col.express()
						+		op.express()
						+		Expression(code: "?", parameters: [("?", val)])
					
					case let Branch(combination: comb, subnodes: ns):
						let	x1	=	" " + comb.express() + " "
						return	Expression.expressionize(elements: ns).concatenationWith(separator: x1)
				}
			}
		}
		
	}
	
	
	
	
	
	
	
		
}


