//
//  EESQLite+Internal.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>






extern
NSString* const
EESQLiteErrorDomain;




















//
//	This function will create error even the code is successful number such as `SQLITE_OK`.
//	
inline
static
NSError*
EESQLiteErrorFromReturnCode(int returnCode, sqlite3* db)
{
	const char *			errmsg	=	sqlite3_errmsg(db);
	
	NSString*				desc	=	[NSString stringWithCString:errmsg encoding:NSUTF8StringEncoding];
	NSMutableDictionary*	info	=	[NSMutableDictionary dictionary];		
	
	[info setObject:desc forKey:NSLocalizedDescriptionKey];
	
	NSError*				err		=	[NSError errorWithDomain:EESQLiteErrorDomain code:returnCode userInfo:info];

	return	err;
}




//	Returns YES for success, NO fo otherwise.
inline
static
BOOL
EESQLiteHandleOKOrError(int result, NSError** error, sqlite3* db)
{
	if ( result == SQLITE_OK )
	{
		if (error != NULL)
		{
			*error	=	nil;
		}
		return	YES;
	}
	else
	{
		if (error != NULL)
		{
			*error	=	EESQLiteErrorFromReturnCode(result, db);
		}
		
		return	NO;
	}
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
NSError*
EESQLiteOutOfMemoryError()
{
	NSDictionary*	info	=	[NSDictionary dictionaryWithObjectsAndKeys:@"Out of memory.", NSLocalizedDescriptionKey, nil];
	return	[NSError errorWithDomain:EESQLiteErrorDomain code:-1 userInfo:info];
}




inline
static
NSError*
EESQLiteFileDoesNotExistAtPathError(NSString* path)
{
	NSString*		message	=	[NSString stringWithFormat:@"File doesnt' exist at path: %@", path];
	NSDictionary*	info	=	[NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, nil];
	return	[NSError errorWithDomain:EESQLiteErrorDomain code:-2 userInfo:info];
}



























