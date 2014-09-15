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
//	case None
//	case Int(value:Int64)
//	case Float(value:Double)
//	case Text(value:String)
//	case Blob(value:Binary)
//}
//
//typealias	Binary	=	Blob






typealias	Row		=	[AnyObject]			///<	The value can be one of these types;	`Int`, `Double`, `String`, `Blob`. A field with NULL will not be stored.


struct
RowList
{
	
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