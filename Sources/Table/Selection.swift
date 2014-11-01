//
//  Selection.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/1/14.
//
//

import Foundation







struct Selection {
	unowned let	table:Table
	let	rows:[Record]
	
	subscript(index:Int) -> Record {
		get {
			return	rows[index]
		}
	}
}