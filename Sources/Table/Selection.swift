//
//  Section.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/1/14.
//
//

import Foundation

///	A subset data of a table.
///	This is an one-time-use-only class.
///	You can't reuse this object after you once consumed it.
public struct Selection {
	let	table:Table						///<	Source table.
	let	statement:Statement				///<	Compiled statement program.
	let	execution:Statement.Execution	///<	Execution state.
	
	public func tuples() -> Statement.Execution.TupleView {
		return	Statement.Execution.TupleView(statement)
	}
	public func dictionaries() -> Statement.Execution.DictionaryView {
		return	Statement.Execution.DictionaryView(statement)
	}
}
