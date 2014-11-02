//
//  Program.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/2/14.
//
//

import Foundation

final class Program {
	let	statement:Statement
	
	init(_ statement:Statement) {
		self.statement	=	statement
	}
	
	func execute() -> Execution {
		return	Execution()
	}
}

final class Execution {
	
}