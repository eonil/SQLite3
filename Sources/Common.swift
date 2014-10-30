//
//  Common.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 10/31/14.
//
//

import Foundation



func combine <K,V> (keys:[K], values:[V]) -> [K:V] {
	precondition(keys.count == values.count)
	
	var	d	=	[:] as [K:V]
	for i in 0..<keys.count {
		d[keys[i]]	=	values[i]
	}
	return	d
}