//
//  Value.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

import Foundation

//enum
//Value
//{
//	case Null
//	case Integer(value:Int64)
//	case Float(value:Double)
//	case Text(value:String)
//	case Blob(value:Binary)
//}
//
//typealias	Binary	=	Blob
public typealias	Value	=	AnyObject				///<	Don't use `Any`. Currently, it causes many subtle unknown problems.




//
//public typealias	FieldList	=	[Value]				///<	The value can be one of these types;	`Int`, `Double`, `String`, `Blob`. A field with NULL will not be stored.
//public typealias	Record		=	[String:Value]
//
//struct RowList
//{
//	let	columns:[String]
//	let	items:[FieldList]
//}





//typealias	Integer	=	Int64

///	64-bit signed integer class type.
///	Defined to provide conversion to AnyObject.
///	(Swift included in Xcode 6.0.1 does not support this conversion...)
public class Integer : Printable//, SignedIntegerType, SignedNumberType
{
	public init(_ number:Int64)
	{
		self.number	=	number
	}
	
	
	public var description:String
	{
		get
		{
			return	number.description
		}
	}
	
//	public var hashValue:Int
//	{
//		get
//		{
//			return	number.hashValue
//		}
//	}
//	
//	public var arrayBoundValue:Int64.ArrayBound
//	{
//		get
//		{
//			return	number.arrayBoundValue
//		}
//	}
//	public func toIntMax() -> IntMax
//	{
//		return	number.toIntMax()
//	}
//	
//	public class func from(x: IntMax) -> Integer
//	{
//		return	Integer(Int64.from(x))
//	}

	let	number:Int64
}

extension Int64
{
	init(_ integer:Integer)
	{
		self.init(integer.number)
	}
}



///	Represents BLOB.
class Blob
{
	class func fromUnsafeMemory(#address:UnsafePointer<()>, length:Int) -> Blob
	{
		precondition(address != UnsafePointer<Int8>.null())
		precondition(length >= 0)
		
		let	d1	=	NSData(bytes: address, length: length)
		return	Blob(value: d1)
	}
	
	var length:Int
	{
		get
		{
			return	value.length
		}
	}
	
	var bytes:UnsafePointer<()>
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