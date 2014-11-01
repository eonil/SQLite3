//
//  Operators.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/1/14.
//
//

import Foundation


infix operator >> {

}
infix operator >>? {

}
infix operator >>! {

}

func >> <T,U> (value:T, function:T->U) -> U {
	return	function(value)
}
func >>? <T,U> (value:T?, function:T->U) -> U? {
	return	value == nil ? nil : function(value!)
}
//func >>! <T,U> (value:T!, function:T->U) -> U {
//	precondition(value != nil, "Supplied value `T` shouldn't be `nil`.")
//	return	function(value!)
//}