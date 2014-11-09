//
//  Debug.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/17/14.
//
//

import Foundation




struct Debug {
	static var mode:Bool {
		get {
			#if	DEBUG
				return	true
			#else
				return	false
			#endif
		}
	}
	
	static let	useCoreLogging	=	false
	
	static func log<T>(object:@autoclosure()->T) {
		if Debug.mode && Test.mode {
			println(object())
		}
	}
	
	
	///	Crashes the app only in debug mode.
	static func crash(_ message:String = "Reason unknown.") {
		if mode {
			fatalError("Crash requested by programmer in debug mode: " + message)
		}
	}
	
	
	
	///	Install these traps to make a conditional breakpoint for specific situations.
	
	static func trapConvenientExtensionsError(message:String) {
		crash(message)
	}
	static func trapError(message:String) {
		crash(message)
	}

	
}









