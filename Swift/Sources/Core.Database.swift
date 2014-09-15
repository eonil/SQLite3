//
//  Core.Database.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation









extension
Core
{
	class Database
	{
		typealias	Common	=	Core.Common
		typealias	C		=	Core.Common.C
		
		struct OpenFlag
		{
			static let	None		=	OpenFlag(value: 0)
			static let	Readonly	=	OpenFlag(value: SQLITE_OPEN_READONLY)
			static let	ReadWrite	=	OpenFlag(value: SQLITE_OPEN_READWRITE)
			static let	Create		=	OpenFlag(value: SQLITE_OPEN_CREATE)
			
			///
			///	You can use any predefined option value `SQLITE_OPEN_~` constants.
			///
			let	value:Int32
			
			init(value:Int32)
			{
				func validate(value:Int32) -> Bool
				{
					let	opts	=
					[
						OpenFlag.Readonly,
						OpenFlag.ReadWrite,
						OpenFlag.Create,
					]
					
					let		has_any	=	opts.filter({ a in return a.value & value > 0 }).count > 0
					return	has_any
				}
				assert(validate(value))
				
				self.value	=	value
			}
		}
		
		struct Status
		{
			struct Code
			{
				static let	MemoryUsed			=	Code(value: SQLITE_STATUS_MEMORY_USED)
				static let	PagecacheUsed		=	Code(value: SQLITE_STATUS_PAGECACHE_USED)
				static let	PagecacheOverflow	=	Code(value: SQLITE_STATUS_PAGECACHE_OVERFLOW)
				static let	ScratchUsed			=	Code(value: SQLITE_STATUS_SCRATCH_USED)
				static let	ScratchOverflow		=	Code(value: SQLITE_STATUS_SCRATCH_OVERFLOW)
				static let	MallocSize			=	Code(value: SQLITE_STATUS_MALLOC_SIZE)
				static let	ParserStack			=	Code(value: SQLITE_STATUS_PARSER_STACK)
				static let	PagecacheSize		=	Code(value: SQLITE_STATUS_PAGECACHE_SIZE)
				static let	ScratchSize			=	Code(value: SQLITE_STATUS_SCRATCH_SIZE)
				static let	MallocCount			=	Code(value: SQLITE_STATUS_MALLOC_COUNT)
				
				let	value:Int32
			}
		}
		
		
		
		
		
		///	Queries whether this is pointing something or nothing.
		var null:Bool
		{
			get
			{
				return	_rawptr == C.NULL
			}
		}
		
		var currentErrorMessage:String
		{
			get
			{
				assert(_rawptr != C.NULL)
				
				let	cs1	=	sqlite3_errmsg(_rawptr)
				let	s2	=	String.fromCString(cs1)!
				return	s2
			}
		}
		var autocommit:Bool
		{
			get
			{
				assert(_rawptr != C.NULL)
				
				return	sqlite3_get_autocommit(_rawptr) != 0
			}
		}
		
		
		
		
		init()
		{
		}
		deinit
		{
			assert(_rawptr == C.NULL)
		}
		
		
		
		func checkNoErrorWith(resultCode code:Int32)
		{
			assert(code == sqlite3_errcode(_rawptr))
			assert(code == SQLITE_OK)
			println("[ERROR] \(currentErrorMessage)")
			Common.crash()
		}
		
		///	If `reset` is `true`, then the peak value will be reset after return.
		func status(op:Status.Code, resetPeak reset:Bool = false) -> (current:Int32, peak:Int32)
		{
			var	c	=	Int32(0)
			var	p	=	Int32(0)
			
			let	pc	=	UnsafeMutablePointer<Int32>.null()
			let	pp	=	UnsafeMutablePointer<Int32>.null()
			pc.initialize(c)
			pp.initialize(p)
			
			let	r	=	sqlite3_status(op.value, pc, pp, C.TRUE)
			checkNoErrorWith(resultCode: r)
			
			pp.destroy()
			pc.destroy()
			
			return	(c, p)
		}
		
		func open(filename:String, flags:OpenFlag)
		{
			assert(_rawptr == C.NULL)
			
			let	name2	=	filename.cStringUsingEncoding(NSUTF8StringEncoding)!
			var ptr		=	UnsafeMutablePointer<COpaquePointer>()
			ptr.initialize(_rawptr)
			
			let	r	=	sqlite3_open_v2(name2, ptr, flags.value, UnsafePointer<Int8>.null())
			checkNoErrorWith(resultCode: r)
			
			ptr.destroy()
		}
		
		func close()
		{
			assert(_rawptr != C.NULL)
			
			//	This can return `SQLITE_BUSY` for some cases,
			//	but it also will be treated as a programmer
			//	error -- a bug, and crashes the execution.
			let	r	=	sqlite3_close(_rawptr)
			checkNoErrorWith(resultCode: r)
			_rawptr	=	COpaquePointer.null()
		}
		
		///	Returns `nil` for `tail` if the SQL fully consumed.
		func prepare(SQL:String) -> (statements:[Core.Statement], tail:String?)
		{
			///	This does not use input zSql after it has been used.
			func once(zSql:UnsafePointer<Int8>, inout zTail:UnsafePointer<Int8>) -> Core.Statement?
			{
				precondition(zSql != zTail)
				
				let	pStmt	=	COpaquePointer.null()
				let	ppStmt	=	UnsafeMutablePointer<COpaquePointer>.null()
				
				let	pzTail	=	UnsafeMutablePointer<UnsafePointer<Int8>>.null()
				
				ppStmt.initialize(pStmt)
				pzTail.initialize(zTail)
				
				let	r		=	sqlite3_prepare_v2(_rawptr, zSql, -1, ppStmt, pzTail)
				checkNoErrorWith(resultCode: r)
				
				pzTail.destroy()
				ppStmt.destroy()
				
				if pStmt == C.NULL
				{
					return	nil
				}
				return	Core.Statement(database: self, pointerToRawCStatementObject: pStmt)
			}
			
			var	stmts:[Core.Statement]	=	[]
			
			///	`zTail` is NULL if the SQL string fully consumed. otheriwse, there's some content and `fromCString` shouldn't be nil.
			var	zSql	=	UnsafePointer<Int8>(SQL.cStringUsingEncoding(NSUTF8StringEncoding)!)
			var	zTail	=	UnsafePointer<Int8>.null()
			
			while let one = once(zSql, &zTail)
			{
				stmts.append(one)
				zSql	=	zTail
			}
			
			return	(stmts, zTail == UnsafePointer<Int8>.null() ? nil : String.fromCString(zTail)!)
		}
		
		
		
		
		
		
		
		
		private var	_rawptr	=	COpaquePointer.null()
	}
}









