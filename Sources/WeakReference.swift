//
//  WeakReference.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 10/30/14.
//
//

import Foundation

///	TODO:	Limit `T` only to reference types. I don't know how yet.
struct WeakReference<T> {
	let	value:T?			///	Becomes `nil` when the value deinitialised.
	
	init(_ v:T) {
		value	=	v
	}
}