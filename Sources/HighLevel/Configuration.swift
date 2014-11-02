//
//  Configuration.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 11/2/14.
//
//

import Foundation

public struct Configuration {
//	public var	schemaEditable:Bool			///<	Allows user to edit schema.
//	public var	contentEditable:Bool		///<	Allows user to edit contents.
	var	savepointNameGenerator:()->String	///<	Crash the app if you can't generate any more names.
}