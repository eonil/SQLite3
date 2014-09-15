//
//  Query.Schema.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/16/14.
//
//

import Foundation

extension Query
{
	
	struct Table
	{
		let	name:Identifier
	}
	struct Colume
	{
		let	name:Identifier
		let	primaryKey:Bool
	}
	
	
	
	
	
	
	
	struct CreateTable
	{
		let	name:Identifier
		let	columns:[Identifier]
	}
	
	struct DropTable
	{
		let	name:Identifier
	}
	
	
}