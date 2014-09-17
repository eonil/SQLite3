//
//  Statement.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation





public protocol Row
{
	var numberOfFields:Int { get }
	subscript(index:Int) -> AnyObject { get }				///<	Program crashes if the field value is `NULL`. Use `isNull` method to test nullity.
//	subscript(column:String) -> AnyObject? { get }
	func columnNameOfField(atIndex index:Int) -> String
	func isNullField(atIndex index:Int) -> Bool
}

public class Statement : GeneratorType
{
	public typealias	Element	=	Row
	
	public func next() -> Element?
	{
		if self.step()
		{
			return	self.row()
		}
		return	nil
	}
	
	
	
	
	
	
	
	
	let	database:Database
	
	init(database:Database, core:Core.Statement)
	{
		self.database	=	database
		
		_core	=	core
		_exec	=	false
		_rowidx	=	-1
	}
	deinit
	{
		_core.finalize()
	}
	
	var execution:Bool
	{
		get
		{
			return	_exec
		}
	}
	func step() -> Bool
	{
		_exec	=	true
		_rowidx++
		return	_core.step()
	}
	func reset()
	{
		_exec	=	false
		_rowidx	=	-1
		_core.reset()
	}
	
	func row() -> Row
	{
		return	RowReader(host: self, rowIndex: _rowidx)
	}
	
	func bind(parameters ps:Database.ParameterList)
	{
		_setparams(ps)
	}
	
	
	
	private let	_core:Core.Statement
	private var	_exec:Bool				///<	Has been executed at least once.
	private var	_rowidx:Int				///<	Counted for validation.
	
	private func _setparams(ps:[String:AnyObject])
	{
		for (k, v) in ps
		{
			let	n1	=	_core.bindParameterIndex(by: k)
			if n1 == 0
			{
				//	skip.
			}
			else
			{
				if v is Integer { _core.bindInt64(v as Integer, at: n1) }
				if v is Double { _core.bindDouble(v as Double, at: n1) }
				if v is String { _core.bindText(v as String, at: n1) }
				if v is Blob { _core.bindBytes(v as Blob, at: n1) }
			}
		}
	}
	
	private struct RowReader : Row
	{
		let	host:Statement
		let	rowIndex:Int		///<	Stored for validation.
		
		var validity:Bool
		{
			get
			{
				return	host._rowidx == rowIndex
			}
		}
		
		var numberOfFields:Int
		{
			get
			{
				precondition(host._core.dataCount().toIntMax() <= Int.max.toIntMax())
				
				return	Int(host._core.dataCount())
			}
		}
		subscript(index:Int) -> AnyObject
		{
			get
			{
				precondition(host._core.null == false)
				precondition(index < numberOfFields)
				precondition(isNullField(atIndex: index) == false)
				
				let	idx2	=	Int32(index)
				let	t2		=	host._core.columnType(idx2)
				
//				if t2 == Core.ColumnTypeCode.null		{ return nil }
				if t2 == Core.ColumnTypeCode.integer	{ return host._core.columnInt64(at: idx2) }
				if t2 == Core.ColumnTypeCode.float		{ return host._core.columnDouble(at: idx2) }
				if t2 == Core.ColumnTypeCode.text		{ return host._core.columnText(at: idx2) }
				if t2 == Core.ColumnTypeCode.blob		{ return host._core.columnBlob(at: idx2) }
				
				Core.Common.crash(message: "Unknown column type code discovered; \(t2)")
			}
		}
//		subscript(column:String) -> AnyObject?
//		{
//			get
//			{
//			}
//		}
		func columnNameOfField(atIndex index:Int) -> String
		{
			precondition(index.toIntMax() <= Int32.max.toIntMax())
			return	host._core.columnName(Int32(index))
		}
		func isNullField(atIndex index: Int) -> Bool
		{
			let	idx2	=	Int32(index)
			let	t2		=	host._core.columnType(idx2)
			return	t2 == Core.ColumnTypeCode.null
		}
	}
}





















