//
//  EESQLiteDatabase.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				"EESQLiteDatabase.h"
#import				"EESQLite-Internal.h"
#import				"EESQLiteStatement.h"
#import				"EESQLiteStatement+Internal.h"










@implementation		EESQLiteDatabase
{	
	sqlite3*		db;
	
	BOOL			inTransaction;
}



- (BOOL)			EESQLiteDatabasePrepareWithName:(NSString*)name error:(NSError**)error
{
	const char * filename = [name cStringUsingEncoding:NSUTF8StringEncoding];
	int flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
	const char * vfs = NULL;
	int result = sqlite3_open_v2(filename, &db, flags, vfs);
	
	if (db == NULL)
	{	
		if (error != NULL)
		{
			*error = EESQLiteOutOfMemoryError();
		}
		return	NO;
	}
	else 
	{
		if (EESQLiteHandleOKOrError(result, error, db))
		{
			return	YES;
		}
		else
		{
			sqlite3_close(db);
			return	NO;
		}
	}
}
- (void)			EESQLiteDatabaseCleanupWithError:(NSError**)error
{
	EESQLiteHandleOKOrError(sqlite3_close(db), error, db);
}
- (sqlite3*)rawdb
{
	return	db;
}




#pragma mark	-	EESQLiteDatabase
- (BOOL)executeSQL:(NSString *)command
{
	return	[self executeSQL:command error:NULL];
}
- (BOOL)executeSQL:(NSString *)command error:(NSError *__autoreleasing *)error
{
	NSError*	internerr	=	nil;
	NSArray*	stmts		=	[self statementsByParsingSQL:command error:&internerr];
	
	if (internerr != nil)
	{
		if (error != NULL)
		{
			*error	=	internerr;
		}
		return	NO;
	}
	
	for (EESQLiteStatement* stmt in stmts)
	{
		NSError*	internerr	=	nil;
		BOOL		internret	=	[stmt stepWithError:&internerr];
		
		if (!internret || internerr != nil)
		{
			if (error != NULL)
			{
				*error	=	internerr;
			}
			return	NO;
		}
	}
	
	return	YES;
}
- (NSArray *)statementsByParsingSQL:(NSString *)sql
{
	return	[self statementsByParsingSQL:sql error:NULL];
}
- (NSArray *)statementsByParsingSQL:(NSString *)sql error:(NSError *__autoreleasing *)error
{
	return	[EESQLiteStatement statementsWithSQLString:sql database:self error:error];
}

- (void)beginTransaction
{
	inTransaction	=	YES;
	[self executeSQL:@"BEGIN TRANSACTION;"];
}
- (void)commitTransaction
{
	[self executeSQL:@"COMMIT TRANSACTION;"];
	inTransaction	=	NO;
}
- (void)rollbackTransaction
{
	[self executeSQL:@"ROLLBACK TRANSACTION;"];
	inTransaction	=	NO;
}
- (void)executeTransactionBlock:(BOOL (^)(void))transaction
{
	[self beginTransaction];
	
	if (transaction())
	{
		[self commitTransaction];
	}
	else 
	{
		[self rollbackTransaction];
	}
}








#pragma mark	-	NSObject

- (NSString *)description
{
	return	[NSString stringWithFormat:@"<%@: memused = %llu (peak = %llu)>", NSStringFromClass([self class]), (unsigned long long)[self usingMemorySizeCurrent], (unsigned long long)[self usingMemorySizeAtPeak]];
}
- (id)initAsTemporaryDatabaseInMemoryWithError:(NSError *__autoreleasing *)error
{
	self	=	[super init];
	
	if (self && [self EESQLiteDatabasePrepareWithName:@":memory:" error:error])
	{
		return	self;
	}
	
	return	nil;
}
- (id)initAsTemporaryDatabaseOnDiskWithError:(NSError *__autoreleasing *)error
{
	self	=	[super init];
	
	if (self && [self EESQLiteDatabasePrepareWithName:nil error:error])
	{
		return	self;
	}
	
	return	nil;
}

- (id)initAsPersistentDatabaseOnDiskAtPath:(NSString *)pathTodDatabase error:(NSError *__autoreleasing *)error createIfNotExist:(BOOL)createIfNotExist
{
	if (!createIfNotExist && ![[NSFileManager defaultManager] fileExistsAtPath:pathTodDatabase])
	{
		if (error != NULL)
		{
			*error	=	EESQLiteFileDoesNotExistAtPathError(pathTodDatabase);
		}
		return	nil;
	}
	
	////
	
	self	=	[super init];
	
	if (self && [self EESQLiteDatabasePrepareWithName:pathTodDatabase error:error])
	{
		return	self;
	}
	
	return	nil;
}
- (id)initAsPersistentDatabaseOnDiskAtPath:(NSString *)pathTodDatabase error:(NSError *__autoreleasing *)error
{
	return	[self initAsPersistentDatabaseOnDiskAtPath:pathTodDatabase error:error createIfNotExist:NO];
}
- (void)dealloc
{
	[self EESQLiteDatabaseCleanupWithError:NULL];
}















#pragma mark	-	Static Methods
+ (EESQLiteDatabase *)temporaryDatabaseInMemory
{
	return	[[self alloc] initAsTemporaryDatabaseInMemoryWithError:NULL];
}
+ (EESQLiteDatabase *)temporaryDatabaseOnDisk
{
	return	[[self alloc] initAsTemporaryDatabaseOnDiskWithError:NULL];
}
+ (EESQLiteDatabase *)persistentDatabaseOnDiskAtPath:(NSString *)pathToDatabase
{
	return	[[self alloc] initAsPersistentDatabaseOnDiskAtPath:pathToDatabase error:NULL];
}
+ (BOOL)createEmptyPersistentDatabaseOnDiskAtPath:(NSString *)path
{
	return	[self createEmptyPersistentDatabaseOnDiskAtPath:path error:NULL];
}
+ (BOOL)createEmptyPersistentDatabaseOnDiskAtPath:(NSString *)path error:(NSError *__autoreleasing *)error
{	
	EESQLiteDatabase*	db	=	[[self alloc] initAsPersistentDatabaseOnDiskAtPath:path error:error createIfNotExist:YES];
	BOOL				ok	=	db != nil;
	return				ok;
}
@end





























@implementation		EESQLiteDatabase (Status)
- (NSUInteger)usingMemorySizeCurrent
{
	int current;
	int peak;
	
	EESQLiteHandleOKOrException(sqlite3_status(SQLITE_STATUS_MEMORY_USED, &current, &peak, false), db);
	
	return	current;
}
- (NSUInteger)usingMemorySizeAtPeak
{
	int current;
	int peak;
	
	EESQLiteHandleOKOrException(sqlite3_status(SQLITE_STATUS_MEMORY_USED, &current, &peak, false), db);
	
	return	peak;
}
@end
			 					 
@implementation		EESQLiteDatabase (Utility)
+ (BOOL)isValidIdentifierString:(NSString *)identifierString
{
	static	NSMutableCharacterSet*	validCharacters	=	nil;
	static dispatch_once_t			onceToken;
	dispatch_once(&onceToken, ^
	{
		validCharacters	=	[[NSMutableCharacterSet alloc] init];
		[validCharacters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
		[validCharacters formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];	
		[validCharacters invert];
	});

	NSRange	firstInvalidRange	=	[identifierString rangeOfCharacterFromSet:validCharacters];
	return	firstInvalidRange.location	==	NSNotFound;
}
+ (NSString *)stringWithEscapeForSQL:(NSString *)string
{
	NSString*	str2	=	[string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	return	[NSString stringWithFormat:@"'%@'", str2];
}
@end
































