//
//  Query.Schema.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/16/14.
//
//

import Foundation

public extension Query
{
	public struct Master
	{
	}
	
	public struct Schema
	{
		public let	tables:[Table]
		
		public struct Table
		{
			public let	name:Identifier
			public let	key:[Identifier]			///<	Primary key column names.
			public let	columns:[Column]
		}
		public struct Column
		{
			public let	name:Identifier
			public let	nullable:Bool
//			public let	ordering:Ordering		///<	This is related to indexing or PK...
			public let	type:TypeCode
			public let	unique:Bool				///<	Has unique key constraint.
			
			public enum TypeCode : String
			{
				case None			=	""				
				case Integer		=	"INTEGER"
				case Float			=	"FLOAT"
				case Text			=	"TEXT"
				case Blob			=	"BLOB"
			}
			public enum Ordering : String
			{
				case Ascending		=	"ASC"
				case Descending		=	"DESC"
			}
		}
	}
}















public extension Query.Master
{
//	///	Queries all schematic informations from the database.
//	public static func schema() -> Query.Schema
//	{
//	}
}

public extension Query.Schema.Table
{
	public struct Create : QueryExpressive, SubqueryExpressive
	{
		public let	temporary:Bool
		public let	definition:Query.Schema.Table
		
		public func express() -> Query.Expression
		{
			return	Query.express(self)
		}
		
		
		
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			typealias	Column	=	Query.Schema.Column
			
			func resolveColumnCode(c:Column) -> String
			{
				typealias	CDEF	=	Query.Language.Syntax.ColumnDef
				typealias	CC		=	Query.Language.Syntax.ColumnConstraint
				typealias	CCOPT	=	Query.Language.Syntax.ColumnConstraint.Option
				typealias	FX		=	Query.Language.Syntax.ConflictClause
				typealias	FXX		=	Query.Language.Syntax.ConflictClause.Reaction
				
				func resolveColumnDef(c:Column) -> CDEF
				{
					func resolveConstraints(c:Column) -> [CC]
					{
						var	constraints:[CC]	=	[]
						if c.nullable == false
						{
							constraints	+=	[CC(name: nil, option: CCOPT.NotNull(conflict: FX(reaction: nil)))]
						}
						if c.unique == true
						{
							constraints	+=	[CC(name: nil, option: CCOPT.Unique(conflict: FX(reaction: nil)))]
						}
						return	constraints
					}
					
					let	s1	=	c.name.express(uniqueParameterNameGenerator: upng).code
					return	CDEF(name: s1, type: c.type, constraints: resolveConstraints(c))
				}
				
				return	resolveColumnDef(c).description
			}
			
			let	ss	=	definition.columns.map(resolveColumnCode).reduce("", combine: { u, n in return u + n })
			
			return	"CREATE "
				+		(temporary ? "TEMPORARY " : "")
				+		"TABLE "
				+		definition.name.express(uniqueParameterNameGenerator: upng)
				+		"(\(ss))"
		}
	}

	public struct Drop : QueryExpressive, SubqueryExpressive
	{
		public let	name:Query.Identifier
		public let	ifExists:Bool
		
		public func express() -> Query.Expression
		{
			return	Query.express(self)
		}
		
		
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	"DROP TABLE " + (ifExists ? " IF EXISTS " : " ") + name.express(uniqueParameterNameGenerator: upng)
		}
	}
}













