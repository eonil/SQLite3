//
//  EESQLite+Internal.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EESQLite-Internal.h"





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
