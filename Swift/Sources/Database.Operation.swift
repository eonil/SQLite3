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
		public typealias	RowIterator		=	Database.RowIterator
		public typealias	ErrorHandler	=	Database.ErrorHandler
		
		public func run(code c:String, parameters ps:ParameterList=ParameterList(), success s:SuccessHandler=Database.Default.null, failure f:ErrorHandler=Database.Default.crash)
		{
			assert(version.number == database._dbg.transactionVersion.number)
			precondition(database._core.null == false)
			precondition(database._core.autocommit == false)
			
			database.execute(code: c, parameters: ps, success: s, failure: f)
		}
		public func run(query q:Query.Select, success s:SuccessHandler=Database.Default.null, failure f:ErrorHandler=Database.Default.crash)
		{
			execute(query: q, success: s, failure: f)
		}
		public func run(query q:Query.Insert, success s:SuccessHandler=Database.Default.null, failure f:ErrorHandler=Database.Default.crash)
		{
			execute(query: q, success: s, failure: f)
		}
		public func run(query q:Query.Update, success s:SuccessHandler=Database.Default.null, failure f:ErrorHandler=Database.Default.crash)
		{
			execute(query: q, success: s, failure: f)
		}
		public func run(query q:Query.Delete, success s:SuccessHandler=Database.Default.null, failure f:ErrorHandler=Database.Default.crash)
		{
			execute(query: q, success: s, failure: f)
		}
		public func run(query q:Query.Schema.Table.Create, success s:SuccessHandler=Database.Default.null, failure f:ErrorHandler=Database.Default.crash)
		{
			execute(query: q, success: s, failure: f)
		}
		public func run(query q:Query.Schema.Table.Drop, success s:SuccessHandler=Database.Default.null, failure f:ErrorHandler=Database.Default.crash)
		{
			execute(query: q, success: s, failure: f)
		}

		
		
		
		
		let	database:Database
		let	version:Database.DebuggingSupport.TransactionVersion
		
		func execute<T:QueryExpressive>(query q:T, success s:SuccessHandler=Database.Default.null, failure f:ErrorHandler=Database.Default.crash)
		{
			assert(version.number == database._dbg.transactionVersion.number)
			precondition(database._core.null == false)
			precondition(database._core.autocommit == false)
			
			database.execute(query: q, success: s, failure: f)
		}
		
		///	Default error handler.
		///	Crash the caller. Any uncommited transaction will be undone.
		static func crash(message m: String)
		{
			Core.Common.crash(message: m)
		}
	}

}