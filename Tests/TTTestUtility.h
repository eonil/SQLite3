//
//  TTTestUtility.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import <Foundation/Foundation.h>





inline
static
NSString*
TTPathToTestDatabase()
{
	NSString*	path	=	[NSTemporaryDirectory() stringByAppendingPathComponent:@"test.sqlite3"];
	return		path;
}



inline
static
void
TTRemoveTestDatabaseFile()
{
	[[NSFileManager defaultManager] removeItemAtPath:TTPathToTestDatabase() error:NULL];
}





inline
static
long long
TTMakeRandomLongLong()
{
	return	(long long)rand();
};


inline
static
double
TTMakeRandomDouble()	
{
	return	(double)TTMakeRandomLongLong();
};


inline
static
NSNumber*	
TTMakeRandomLongLongNumber()
{
	return	[NSNumber numberWithLongLong:TTMakeRandomLongLong()];
};


inline
static
NSNumber*	
TTMakeRandomDoubleNumber()	
{
	return	[NSNumber numberWithDouble:TTMakeRandomDouble()];
};


inline
static
NSString*	
TTMakeRandomString()	
{
	return	[NSString stringWithFormat:@"This is random string with number = %lld", TTMakeRandomLongLong()];
};





inline
static
NSData*		
TTMakeRandomData()		
{
	return	[NSData dataWithBytes:(const void *)(char[]){ rand(), rand(), rand(), rand(), rand(), rand(), rand(), rand() } length:8];
};

























@interface TTTestUtility : NSObject
@end
