//
//  Schema.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/18/14.
//
//

import Foundation

public struct Schema
{
	public let	tables:[Table]
	
	public struct Table
	{
		public let	name:String
		public let	key:[String]			///<	Primary key column names.
		public let	columns:[Column]
	}
	public struct Column
	{
		public let	name:String
		public let	nullable:Bool
//		public let	ordering:Ordering		///<	This is related to indexing or PK...
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


