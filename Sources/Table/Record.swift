//
//  Record.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 10/31/14.
//
//

import Foundation


///	A record is always connected to a table.
///	You can get column names from `table`.
public struct Record {
	public typealias	Identity	=	[Value]
	public typealias	Content		=	[Value]
	
	private unowned let	table:Table
	
	public let	identity:[Value]
	public let	content:[Value]
	
	public init(table:Table, identity:[Value], content:[Value]) {
		self.table	=	table
		self.identity	=	identity
		self.content	=	content
	}
	
	public subscript(column:String) -> Value? {
		get {
			if let idx = table.info.findDataColumnIndexForName(column) {
				return	content[idx]
			}
			if let idx = table.info.findKeyColumnIndexForName(column) {
				return	identity[idx]
			}
			return	nil
		}
	}
	
}







extension Record: Printable {
	public var description:String {
		get {
			return	"Record(table: \(table), key: \(identity), data: \(content))"
		}
	}
}









