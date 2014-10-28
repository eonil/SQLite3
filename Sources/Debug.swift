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
	
	static func log<T>(object:@autoclosure()->T)
	{
		_log(object())
	}
	
	private static func _log<T>(object:@autoclosure()->T)
	{
		if mode && Config.Build.logLevel != Config.Build.LogLevel.None
		{
			println(object())
		}
	}
}