//
//  Query.Basic.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/16/14.
//
//

import Foundation

public extension Query
{
	
	
	
	
	///	Repesents SELECT statement.
	///
	///		SELECT * FROM "MyTable1"
	///		SELECT "col1", "col2", "col3" FROM "YourTable2"
	///
	public struct Select : QueryExpressive, SubqueryExpressive
	{
		static func all(of table:Identifier) -> Select
		{
			return	Select(table: table, columns: Query.ColumnList.All, filter: nil)
		}
		
		public let	table:Identifier
		public let	columns:Query.ColumnList
		public let	filter:Query.FilterTree?
		
		public func express() -> Query.Expression
		{
			return	Query.express(self)
		}
		
		
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			let	x1	=	(filter == nil ? Expression.empty : filter!.express(uniqueParameterNameGenerator: upng)) as Expression
			return	"SELECT " as Expression
			+		columns.express(uniqueParameterNameGenerator: upng)
			+		" " as Expression
			+		"FROM " as Expression
			+		table.express(uniqueParameterNameGenerator: upng)
			+		" " as Expression
			+		Expression(code: (filter == nil ? "" : "WHERE "), parameters: [])
			+		x1 as Expression
		}
	}
	
	
	
	
	///	Represents INSERT statement.
	///
	///		INSERT INTO "MyTable1" ("col1", "col2", "col3") VALUES (@param1, @param2, @param3)
	///
	///	http://www.sqlite.org/lang_insert.html
	public struct Insert : QueryExpressive, SubqueryExpressive
	{
		public let	table:Identifier
		public let	bindings:[Query.Binding]
		
		public func express() -> Query.Expression
		{
			return	Query.express(self)
		}
		
		
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			let	ns		=	bindings.map({ (n:Query.Binding) -> Expression in return n.column.express(uniqueParameterNameGenerator: upng) })
			let	ps		=	bindings.map({ (n:Query.Binding) -> AnyObject in return n.value })
			
			let	cols	=	ExpressionList(items: ns).concatenationWith(separator: ", ")						///<	`col1, col2, col3, ...`
			let	params	=	Expression.byGeneratingUniqueParameterNames(using: upng, with: ps)					///<	`@p1, @p2, @p3, ...`
			
			return	"INSERT INTO "
			+		table.express(uniqueParameterNameGenerator: upng)
			+		"("
			+		cols
			+		")"
			+		" VALUES "
			+		"("
			+		params
			+		")"
		}
	}
	
	///	Represents UPDATE statement.
	///
	///		UPDATE "MyTable1" SET "col1"=@param1, "col2"=@param2, "col3"=@param3 WHERE "col4"=@param4
	///
	///	http://www.sqlite.org/lang_update.html
	public struct Update : QueryExpressive, SubqueryExpressive
	{
		public let	table:Identifier
		public let	bindings:[Query.Binding]
		public let	filter:Query.FilterTree?
		
		public func express() -> Query.Expression
		{
			return	Query.express(self)
		}
		
		
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			let	bs2	=	bindings.map({ u in return u.express(uniqueParameterNameGenerator: upng) }) as [Query.Expression]
			let	bs3	=	ExpressionList(items: bs2).concatenationWith(separator: ", ")
			Debug.log(upng())
			Debug.log(bs2[0].code)
			Debug.log(bs2[0].parameters)
			Debug.log(bs3.code)
			return	"UPDATE "
			+		table.express(uniqueParameterNameGenerator: upng)
			+		" SET "
			+		bs3
			+		" WHERE "
			+		filter?.express(uniqueParameterNameGenerator: upng)
		}
	}
	
	///	Represents DELETE statement.
	///	
	///		DELETE FROM "MyTable1" WHERE "col1"=@param1
	///
	public struct Delete : QueryExpressive, SubqueryExpressive
	{
		public let	table:Identifier
		public let	filter:Query.FilterTree
		
		public func express() -> Query.Expression
		{
			return	Query.express(self)
		}
		
		
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	"DELETE FROM "
			+	table.express(uniqueParameterNameGenerator: upng)
			+	" WHERE "
			+	filter.express(uniqueParameterNameGenerator: upng)
		}
	}

}