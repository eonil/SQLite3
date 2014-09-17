//
//  Core.Common.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation

extension Core
{
	struct Common
	{
	}
}

extension Core.Common
{
	@noreturn static func crash(message s:String = "")
	{
		Core.log("CRASH requested by PROGRAMMER" + (s == "" ? "." : (": " + s)))
		abort()
	}
	
	
	
	struct C
	{
		static let	NULL		=	COpaquePointer.null()
		
		static let	TRUE		=	Int32(1)
		static let	FALSE		=	Int32(0)
	}
	
	
	
	
	
//	struct
//	Validation
//	{
//		
//	}
}