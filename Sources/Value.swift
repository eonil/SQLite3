//
//  Value.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation




public typealias	Binary	=	Blob

///	We don't use Swift `nil` to represent SQLite3 `NULL` because it
///	makes program more complex.
///
///	https://www.sqlite.org/datatype3.html
public enum Value {
	case Null
	case Integer(Int64)
	case Float(Double)
	case Text(String)
	case Blob(Binary)
}

extension Value: Equatable {
}

extension Value: NilLiteralConvertible {
	public init(nilLiteral: ()) {
		self	=	Value.Null
	}
}
extension Value: IntegerLiteralConvertible, FloatLiteralConvertible, StringLiteralConvertible {
	public init(integerLiteral value: Int64) {
		self	=	Integer(value)
	}
//	public init(integerLiteral value: Int) {
//		precondition(IntMax(value) <= IntMax(Int64.max))
//		self	=	Integer(Int64(value))
//	}

	public init(floatLiteral value: Double) {
		self	=	Float(value)
	}
	public init(stringLiteral value: String) {
		self	=	Text(value)
	}
	public init(extendedGraphemeClusterLiteral value: String) {
		self	=	Text(value)
	}
	public init(unicodeScalarLiteral value: String) {
		self	=	Text(value)
	}
}

extension Value: Printable {
	public var description:String {
		get {
			switch self {
			case let Null(s):		return	"NULL"
			case let Integer(s):	return	"INTEGER(\(s))"
			case let Float(s):		return	"FLOAT(\(s))"
			case let Text(s):		return	"TEXT(\(s))"
			case let Blob(s):		return	"BLOB(~~~~)"
//			default:				fatalError("Unsupported value case.")
			}
		}
	}
}


public func == (l:Value, r:Value) -> Bool {
	switch (l,r) {
	case let (Value.Null, Value.Null):				return	true
	case let (Value.Integer(a), Value.Integer(b)):	return	a == b
	case let (Value.Float(a), Value.Float(b)):		return	a == b
	case let (Value.Text(a), Value.Text(b)):		return	a == b
	case let (Value.Blob(a), Value.Blob(b)):		return	a == b
	default:										return	false
	}
}

func == (l:Value, r:()?) -> Bool {
	return	l == Value.Null && r == nil
}

func == (l:Value, r:Int) -> Bool {
	return	l == Int64(r)
}
func == (l:Value, r:Int64) -> Bool {
	if let v2 = l.integer { return v2 == r }
	return	false
}
func == (l:Value, r:Double) -> Bool {
	if let v2 = l.float { return v2 == r }
	return	false
}
func == (l:Value, r:String) -> Bool {
	if let v2 = l.text { return v2 == r }
	return	false
}
func == (l:Value, r:Binary) -> Bool {
	if let v2 = l.blob { return v2 == r }
	return	false
}

extension Value {
//	init(){
//		self	=	Value.Null
//	}
	init(_ v:Int64) {
		self	=	Integer(v)
	}
	init(_ v:Double) {
		self	=	Float(v)
	}
	init(_ v:String) {
		self	=	Text(v)
	}
	init(_ v:Binary) {
		self	=	Blob(v)
	}
	
	var null:Bool {
		get {
			return	self == Value.Null
//			switch self {
//			case let Null:			return	true
//			default:				return	false
//			}
		}
	}
	var integer:Int64? {
		get {
			switch self {
			case let Integer(s):	return	s
			default:				return	nil
			}
		}
	}
	var float:Double? {
		get {
			switch self {
			case let Float(s):		return	s
			default:				return	nil
			}
		}
	}
	var text:String? {
		get {
			switch self {
			case let Text(s):		return	s
			default:				return	nil
			}
		}
	}
	var blob:Binary? {
		get {
			switch self {
			case let Blob(s):		return	s
			default:				return	nil
			}
		}
	}
}

























//
//public typealias	Value	=	AnyObject				///<	Don't use `Any`. Currently, it causes many subtle unknown problems.
//
//
//
//
////
////public typealias	FieldList	=	[Value]				///<	The value can be one of these types;	`Int`, `Double`, `String`, `Blob`. A field with NULL will not be stored.
////public typealias	Record		=	[String:Value]
////
////struct RowList
////{
////	let	columns:[String]
////	let	items:[FieldList]
////}
//
//
//
//
//
////typealias	Integer	=	Int64
//
/////	64-bit signed integer class type.
/////	Defined to provide conversion to AnyObject.
/////	(Swift included in Xcode 6.0.1 does not support this conversion...)
//public class Integer : Printable//, SignedIntegerType, SignedNumberType
//{
//	public init(_ number:Int64)
//	{
//		self.number	=	number
//	}
//	
//	
//	public var description:String
//	{
//		get
//		{
//			return	number.description
//		}
//	}
//	
////	public var hashValue:Int
////	{
////		get
////		{
////			return	number.hashValue
////		}
////	}
////	
////	public var arrayBoundValue:Int64.ArrayBound
////	{
////		get
////		{
////			return	number.arrayBoundValue
////		}
////	}
////	public func toIntMax() -> IntMax
////	{
////		return	number.toIntMax()
////	}
////	
////	public class func from(x: IntMax) -> Integer
////	{
////		return	Integer(Int64.from(x))
////	}
//
//	let	number:Int64
//}
//
//extension Int64
//{
//	init(_ integer:Integer)
//	{
//		self.init(integer.number)
//	}
//}



///	Represents BLOB.
public class Blob
{
	init(address:UnsafePointer<()>, length:Int) {
		precondition(address != UnsafePointer<Int8>.null())
		precondition(length >= 0)
		
		value	=	NSData(bytes: address, length: length)
	}
	
	
	var length:Int
	{
		get
		{
			return	value.length
		}
	}
	
	var address:UnsafePointer<()>
	{
		get
		{
			return	value.bytes
		}
	}
	
	
	
	
	
	private init(value:NSData)
	{
		self.value	=	value
	}
	
	private let	value:NSData
}

public func == (l:Blob, r:Blob) -> Bool {
	return	l.value == r.value
}










