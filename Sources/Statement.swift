//
//  Statement.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation








































///	MARK:

///	Comments for Maintainers
///	------------------------
///	This can't be a `SequenceType`, but `GeneratorType` because
///	there's only one iteration context can be exist at once. It
///	is impossible to create multiple context from a statement.
public final class Statement {
	unowned let	database:Database
	
	private let	_core:Core.Statement
	private var	_exec:Bool				///<	Has been executed at least once.
	private var	_rowidx:Int				///<	Counted for validation.
	
	init(database:Database, core:Core.Statement) {
		self.database	=	database
		
		_core	=	core
		_exec	=	false
		_rowidx	=	-1
	}
	deinit {
		_core.finalize()
	}
}



extension Statement: Printable {
	public var description: String {
		get {
			return	"Statement(\(_core.sql()))"
		}
	}
}

extension Statement : GeneratorType {
	public func next() -> Row? {
		if self.step() {
			return	self.row()
		}
		return	nil
	}
}

extension Statement {
	
	var execution:Bool {
		get {
			return	_exec
		}
	}
	func step() -> Bool {
		_exec	=	true
		_rowidx++
		return	_core.step()
	}
	func reset() {
		_exec	=	false
		_rowidx	=	-1
		_core.reset()
	}
	
	func row() -> Row {
		return	RowReader(host: self, rowIndex: _rowidx)
	}
	
	func bind2(parameters ps:[Value]) {
		for i in 0..<ps.count {
			let	v			=	ps[i]
			let	(n1, f1)	=	Int.addWithOverflow(i, 1)
			precondition(f1 == false)
			precondition(IntMax(n1) < IntMax(Int32.max))
			let	n2			=	Int32(n1)
			
			switch v {
			case let Value.Null:		_core.bindNull(at: n2)
			case let Value.Integer(s):	_core.bindInt64(s, at: n2)
			case let Value.Float(s):	_core.bindDouble(s, at: n2)
			case let Value.Text(s):		_core.bindText(s, at: n2)
			case let Value.Blob(s):		_core.bindBytes(s, at: n2)
			}
		}
	}
	
}





















































































///	MARK:

public protocol Row {
	var numberOfFields:Int { get }
	subscript(index:Int) -> Value { get }				///<	Program crashes if the field value is `NULL`. Use `isNull` method to test nullity.
	//	subscript(column:String) -> AnyObject? { get }
	func columnNameOfField(atIndex index:Int) -> String
	func isNullField(atIndex index:Int) -> Bool
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
	
	///	0-based indexing.
	subscript(index:Int) -> Value
	{
		get
		{
			precondition(host._core.null == false)
			precondition(index < numberOfFields)
			precondition(isNullField(atIndex: index) == false)
			
			let	idx2	=	Int32(index)
			let	t2		=	host._core.columnType(idx2)
			
			if t2 == Core.ColumnTypeCode.null		{ return Value.Null }
			if t2 == Core.ColumnTypeCode.integer	{ return Value(host._core.columnInt64(at: idx2)) }
			if t2 == Core.ColumnTypeCode.float		{ return Value(host._core.columnDouble(at: idx2)) }
			if t2 == Core.ColumnTypeCode.text		{ return Value(host._core.columnText(at: idx2)) }
			if t2 == Core.ColumnTypeCode.blob		{ return Value(host._core.columnBlob(at: idx2)) }
			
			Core.Common.crash(message: "Unknown column type code discovered; \(t2)")
		}
	}
//	subscript(column:String) -> Value?
//	{
//		get
//		{
//		}
//	}
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










