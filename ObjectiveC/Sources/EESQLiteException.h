//
//  EESQLiteException.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 8/11/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import <sqlite3.h>
#import "EESQLiteError.h"
#import "EESQLiteCommon.h"

//#define		EESQLiteExceptionDomain		(@"EONIL-SQLITE-EXCEPTION")






/*!
 Represents an unrecoverable error. (or debug mode dynamic assertion)
 This means state is already corrupted, and program will crash immediately.
 */
@interface	EESQLiteException : NSException
+ (id)allocWithZone:(struct _NSZone *)zone EESQLITE3_UNAVAILABLE_METHOD;
+ (id)copyWithZone:(struct _NSZone *)zone EESQLITE3_UNAVAILABLE_METHOD;
- (id)initWithCoder:(NSCoder *)aDecoder EESQLITE3_UNAVAILABLE_METHOD;
+ (void)raise:(NSString *)name format:(NSString *)format, ... EESQLITE3_UNAVAILABLE_METHOD;
+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)argList EESQLITE3_UNAVAILABLE_METHOD;
@end



















inline
static
NSException*
EESQLiteExceptionFromError(NSError* originError)
{
	NSDictionary*	info	=	[NSDictionary dictionaryWithObjectsAndKeys:
								 originError, NSUnderlyingErrorKey,
								 nil];
	
	NSException*	ex		=	[NSException exceptionWithName:[originError domain] reason:[originError localizedDescription] userInfo:info];
	return			ex;
}


inline
static
void
EESQLiteHandleOKOrException(int result, sqlite3* db)
{
	if (result == SQLITE_OK)
	{
	}
	else
	{
		NSError*		err	=	EESQLiteErrorFromReturnCode(result, db);
		NSException*	ex	=	EESQLiteExceptionFromError(err);
		
		@throw			ex;
	}
}



inline
static
NSException*
EESQLiteExceptionForNestedExplicitTransaction()
{
	return	[NSException exceptionWithName:@"EESQLITE-DATABASE-TRANSACTION" reason:@"Currently the database is not in auto-commit mode. It means there's active transaction, and new transaction cannot be started." userInfo:nil];
}










































