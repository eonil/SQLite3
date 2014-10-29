//
//  Error.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 10/29/14.
//
//

import Foundation


/////	This doesn't work due to a compiler bug.
/////	Use another implementation for a workaround.
//enum Evaluation<V> {
//	case Error(String)
//	case Value(V)
//	
//	var error:String? {
//		get {
//			switch self {
//			case let Error(s):	return	s
//			default:			return	nil
//			}
//		}
//	}
//	var value:V? {
//		get {
//			switch self {
//			case let Value(s):	return	s
//			default:			return	nil
//			}
//		}
//	}
//}


///	TODO: Replace with `enum` based implementation when the compiler ready.
struct Evaluation<V> {
	init(error:String) {
		self.error	=	error
	}
	init(value:V) {
		self.value	=	value
	}
	let error:String?
	let	value:V?
}