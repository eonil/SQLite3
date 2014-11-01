//
//  Matrix.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/1/14.
//
//

import Foundation

struct Matrix {
	let	columns:[String]
	let	rows:[Row]
}

struct Row {
	let	keys:[Value]
	let	values:[Value]
}








//struct LazyMatrix {
//	let	s:Statement
//}
//struct LazyRow {
//	let	s:Statement
//}