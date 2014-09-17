//
//  Debug.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/17/14.
//
//

import Foundation

struct Debug
{
	#if	DEBUG
	static let	mode:Bool	=	true
	#else
	static let	mode:Bool	=	false
	#endif
	
	static func log(object:@autoclosure()->Any)
	{
		_log(object())
	}
	
	private static func _log(object:@autoclosure()->Any)
	{
		if mode
		{
			println(object())
		}
	}
}