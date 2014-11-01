//
//  Record.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 10/31/14.
//
//

import Foundation


///	You can get column names from `table`.
public struct Record {
	unowned let	table:Table
	public let	keys:[Value]
	public let	data:[Value]
	
	public init(table:Table, keys:[Value], data:[Value]) {
		self.table	=	table
		self.keys	=	keys
		self.data	=	data
	}
	
//	public subscript(column:String) -> Value? {
//		get {
//		}
//	}
}

