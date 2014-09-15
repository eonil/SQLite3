//
//  Statement.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation

class Statement
{
	let	database:Database
	
	init(database:Database, core:Core.Statement)
	{
		self.database	=	database
		
		_core	=	core
	}
	deinit
	{
		_core.finalize()
	}
	
	private let	_core:Core.Statement
}