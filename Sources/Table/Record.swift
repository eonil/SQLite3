//
//  Record.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 10/31/14.
//
//

import Foundation



public struct Record {
	unowned let	table:Table
//	public let	keys:[Value]
	public let	values:[Value]
	
	public init(table:Table, values:[Value]) {
		self.table	=	table
		self.values	=	values
	}
//	
//	public init(table:Table, keys:[Value], values:[Value]) {
//		self.table	=	table
//		self.keys	=	keys
//		self.values	=	values
//	}
}

