//
//  ____internals____.m
//  CocoaSQLite
//
//  Created by Hoon H. on 2014/06/24.
//  Copyright (c) 2014 Eonil Company. All rights reserved.
//

#import "____internals____.h"
#import "EESQLiteCommon.h"
#import "EESQLiteDatabase.h"
#import "EESQLite____internal_doctor.h"








BOOL
EESQLiteIsDebuggingMode()
{
#ifdef	EESQLITE_DEBUG_MODE
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









































#pragma mark	-	Dynamic Assertion Utilities


#if EONIL_DEBUG_MODE

void
eesqlite3____error_log(NSString* message)
{
	NSLog(@"[Universe/Error/Log] %@", message);
}

void
EESQLITE3_DEBUG_ASSERT(BOOL cond)
{
	[EESQLite____internal_doctor panicIf:!cond withMessage:@"Debugging assertion failure!"];
}
void
EESQLITE3_DEBUG_ASSERT_WITH_MESSAGE(BOOL cond, NSString* message)
{
	[EESQLite____internal_doctor panicIf:!cond withMessage:message];
}

void
EESQLITE3_UNREACHABLE_CODE()
{
	[EESQLite____internal_doctor panicWithMessage:@"Unreacable code! (asserted for debugging)"];
	__builtin_unreachable();
}

#endif









































