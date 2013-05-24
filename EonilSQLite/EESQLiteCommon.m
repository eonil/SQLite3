//
//  EESQLiteCommon.m
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 5/24/13.
//  Copyright (c) 2013 Eonil Company. All rights reserved.
//


#import <sqlite3.h>
#import "EESQLiteCommon.h"
#import "EESQLiteDatabase.h"




BOOL
EESQLiteIsDebuggingMode()
{
#ifdef	EESQLITE_DEBUG
	return	YES;
#else
	return	NO;
#endif
}


void
EESQLiteAssert(BOOL condition, NSString* message)
{
	if (EESQLiteIsDebuggingMode() && !condition)
	{
		NSString*	reason	=	[@"EESQLite assertion failure!!! " stringByAppendingString:message];
		EESQLiteExcept(reason);
	}
}

void
EESQLiteExcept(NSString* reason)
{
	@throw	[NSException exceptionWithName:@"EESQLITE-EXCEPTION" reason:reason userInfo:nil];
}



void
EESQLiteExceptWithReturnCodeForDatabase(int returnCode, sqlite3* db)
{
	NSString*				prefix	=	[NSString stringWithFormat:@"return code = %@, ", @(returnCode)];
	const char *			errmsg	=	sqlite3_errmsg(db);
	NSString*				desc	=	[NSString stringWithCString:errmsg encoding:NSUTF8StringEncoding];
	NSString*				reason	=	[prefix stringByAppendingString:desc];
	
	EESQLiteExcept(reason);	
}












void
EESQLiteExceptIfReturnCodeIsNotOK(int result, sqlite3* db)
{
	if (result != SQLITE_OK)
	{
		EESQLiteExceptWithReturnCodeForDatabase(result, db);
	}
}


void
EESQLiteExceptIfThereIsAnError(NSError* error)
{
	if (error != nil)
	{
		EESQLiteExcept([error description]);
	}
}






void
EESQLiteExceptIfIdentifierIsInvalid(NSString* identifier)
{
	if (![EESQLiteDatabase isValidIdentifierString:identifier])
	{
		EESQLiteExcept([NSString stringWithFormat:@"The name %@ is invalid for SQLite3. Only alphanumeric and underscore letters are permitted. This is Objective-C wrapper level error.", identifier]);
	}
}





