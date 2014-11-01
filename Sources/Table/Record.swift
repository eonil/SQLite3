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
	private unowned let	table:Table
	
	public let	key:[Value]
	public let	value:[Value]
	
	public init(table:Table, key:[Value], value:[Value]) {
		self.table	=	table
		self.key	=	key
		self.value	=	value
	}
	
	public subscript(column:String) -> Value? {
		get {
			if let idx = table.info.findDataColumnIndexForName(column) {
				return	value[idx]
			}
			if let idx = table.info.findKeyColumnIndexForName(column) {
				return	key[idx]
			}
			return	nil
		}
	}
}







extension Record: Printable {
	public var description:String {
		get {
			return	"Record(table: \(table), key: \(key), data: \(value))"
		}
	}
}