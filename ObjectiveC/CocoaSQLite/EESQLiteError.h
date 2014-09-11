//
//  EESQLiteError.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 8/12/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//


#import <sqlite3.h>



extern
NSString* const
EESQLiteErrorDomain;











inline
static
NSError*
EESQLiteInputArgumentErrorDataIsTooLong()
{
	NSString*				desc	=	@"The length in byte count of input data (encoded string or binary) is too long to be used as SQLite input argument. Maximum length cannot exceed `INT_MAX`. This is Objective-C wrapper level error.";
	NSMutableDictionary*	info	=	[NSMutableDictionary dictionary];
	
	[info setObject:desc forKey:NSLocalizedDescriptionKey];
	
	NSError*				err		=	[NSError errorWithDomain:EESQLiteErrorDomain code:0 userInfo:info];
	
	return	err;
}








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




//	Returns YES for OK and success, NO for failure or any errors.
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
NSError*
EESQLiteOutOfMemoryError()
{
	NSDictionary*	info	=	[NSDictionary dictionaryWithObjectsAndKeys:@"Out of memory.", NSLocalizedDescriptionKey, nil];
	return	[NSError errorWithDomain:EESQLiteErrorDomain code:-1 userInfo:info];
}
















#pragma mark	-	Objective-C Level Raises

inline
static
NSError*
EESQLiteFileDoesNotExistAtPathError(NSString* path)
{
	NSString*		message	=	[NSString stringWithFormat:@"File doesnt' exist at path: %@", path];
	NSDictionary*	info	=	[NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, nil];
	return	[NSError errorWithDomain:EESQLiteErrorDomain code:-2 userInfo:info];
}
//inline
//static
//NSError*
//EESQLiteErrorWithUnderlyingError(NSError* underlyingError, NSString* message)
//{
//	NSDictionary*	info	=	@
//	{
//		NSUnderlyingErrorKey		:	underlyingError,
//		NSLocalizedDescriptionKey	:	message,
//	};
//	return	[NSError errorWithDomain:EESQLiteErrorDomain code:-3 userInfo:info];
//}




//inline
//static
//NSError*
//EESQLiteCannotInsertIntoTableBecauseOfNoColumnError(NSString* tableName)
//{
//	NSString*		message	=	[NSString stringWithFormat:@"Cannot INSERT INO because there's no insertable column in the table: %@", tableName];
//	NSDictionary*	info	=	[NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, nil];
//	return	[NSError errorWithDomain:EESQLiteErrorDomain code:-4 userInfo:info];
//}









