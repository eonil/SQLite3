//
//  Debug.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/17/14.
//
//

import Foundation




struct Debug {
//	#if	DEBUG
	static let	mode:Bool	=	true
//	#else
//	static let	mode:Bool	=	false
//	#endif
	
	static let	useCoreLogging	=	false
	
	static func log<T>(object:@autoclosure()->T) {
		func _log(object:@autoclosure()->T) {
			if mode {
				println(object())
			}
		}
		_log(object())
	}
	
	
	///	Crashes the app only in debug mode.
	static func crash() {
		if mode {
			fatalError("Crash requested by programmer in debug mode.")
		}
	}
	
	
	
	///	Install these traps to make a conditional breakpoint for specific situations.
	
	static func trapConvenientExtensionsError() {
		crash()
	}
	static func trapError() {
		crash()
	}

	
}