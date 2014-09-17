//
//  Database.Transaction.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/17/14.
//
//

import Foundation

extension Database
{
	public struct Operation
	{
//		public typealias	RowIterator		=	Database.RowIterator
		
		public func execute(code c:String, parameters ps:ParameterList=ParameterList(), success s:SuccessHandler=Database.Default.Handler.success, failure f:FailureHandler=Database.Default.Handler.failure)
		{
			assert(version.number == database._dbg.transactionVersion.number)
			precondition(database._core.null == false)
			precondition(database._core.autocommit == false)
			
			database.execute(code: c, parameters: ps, success: s, failure: f)
		}

		
		
		
		
		
		let	database:Database
		let	version:Database.DebuggingSupport.TransactionVersion
		
		func execute(query x:Query.Expression, success s:SuccessHandler=Database.Default.Handler.success, failure f:FailureHandler=Database.Default.Handler.failure)
		{
			assert(version.number == database._dbg.transactionVersion.number)
			precondition(database._core.null == false)
			precondition(database._core.autocommit == false)
			
			database.execute(query: x, success: s, failure: f)
		}
		func execute<T:QueryExpressive>(query q:T, success s:SuccessHandler=Database.Default.Handler.success, failure f:FailureHandler=Database.Default.Handler.failure)
		{
			execute(query: q.express(), success: s, failure: f)
		}
		
		///	Default error handler.
		///	Crash the caller. Any uncommited transaction will be undone.
		static func crash(message m: String)
		{
			Core.Common.crash(message: m)
		}
	}

}








