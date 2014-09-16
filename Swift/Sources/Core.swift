//
//  Core.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation

///
///	`Core` layer manages these stuffs in proper Swift semantics.
///	-	type conversion into Swift semantics. 
///	-	error handling (currently, all errors just crashes)
///	-	input/output validation
///	No extra abstractions or lifecycle management. You still need
///	to manage lifecycle yourself manually.
///	Most errors will just crash the execution except a very few 
///	exceptions. Some preflight test code will be provided.
///
struct Core
{
}

extension Core
{
	struct Debug
	{
		static func log(message m:String)
		{
			println(m)
		}
	}
}