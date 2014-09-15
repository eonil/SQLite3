//
//  Query.Basic.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/16/14.
//
//

import Foundation

extension Query
{
	
	
	
	
	
	///	Repesents SELECT statement.
	///
	///		SELECT * FROM "MyTable1"
	///		SELECT "col1", "col2", "col3" FROM "YourTable2"
	///
	struct Select : QueryExpressive
	{
		static func all(of table:Identifier) -> QueryExpressive
		{
			return	Select(table: table, columns: Query.ColumnList.All, filter: nil)
		}
		
		let	table:Identifier
		let	columns:Query.ColumnList
		let	filter:Query.FilterTree?
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	"SELECT "
			+		columns.express(uniqueParameterNameGenerator: upng)
			+		" FROM "
			+		table.express(uniqueParameterNameGenerator: upng)
			+		(filter == nil ? "" : " WHERE ")
			+		filter?.express(uniqueParameterNameGenerator: upng)
		}
	}
	
	///	Represents INSERT statement.
	///
	///		INSERT INTO "MyTable1" ("col1", "col2", "col3") VALUES (@param1, @param2, @param3)
	///
	struct Insert : QueryExpressive
	{
		let	table:Identifier
		let	bindings:[Query.Binding]
		
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
	struct Update : QueryExpressive
	{
		let	table:Identifier
		let	bindings:Query.BindingList
		let	filter:Query.FilterTree?
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	"UPDATE "
			+		table.express(uniqueParameterNameGenerator: upng)
			+		" SET "
			+		bindings.express(uniqueParameterNameGenerator: upng)
			+		" WHERE "
			+		filter?.express(uniqueParameterNameGenerator: upng)
		}
	}
	
	///	Represents DELETE statement.
	///	
	///		DELETE FROM "MyTable1" WHERE "col1"=@param1
	///
	struct Delete : QueryExpressive
	{
		let	table:Identifier
		let	filter:Query.FilterTree
		
		func express(uniqueParameterNameGenerator upng: Query.UniqueParameterNameGenerator) -> Query.Expression
		{
			return	"DELETE FROM "
			+	table.express(uniqueParameterNameGenerator: upng)
			+	" WHERE "
			+	filter.express(uniqueParameterNameGenerator: upng)
		}
	}

}