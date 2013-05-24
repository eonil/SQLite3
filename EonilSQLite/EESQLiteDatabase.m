//
//  EESQLiteDatabase.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				"EESQLiteException.h"
#import				"EESQLite-Internal.h"
#import				"EESQLiteStatement.h"
#import				"EESQLiteStatement+Internal.h"

#import				"EESQLiteDatabase.h"





#define				IN_MEMORY_DATABASE_NAME	@":memory:"












inline static void
EXCEPT_IF_NAME_IS_INVALID(NSString* name)
{
	if (![EESQLiteDatabase isValidIdentifierString:name])
	{
		EESQLiteExcept([NSString stringWithFormat:@"The name %@ is invalid for SQLite3.", name]);
	}
}











@implementation		EESQLiteDatabase
{	
	sqlite3*		db;
}

sqlite3*
EESQLiteDatabaseGetCorePointerToSQLite3(EESQLiteDatabase* self)
{
	return	self->db;
}

/*!
 Returns YES if prepared succesfully.
 Otherwise, NO.
 */
static
inline
BOOL
PrepareWithName(EESQLiteDatabase* self, NSString* name, NSError** error, BOOL allowCreation)
{
	const char * filename = [name cStringUsingEncoding:NSUTF8StringEncoding];
	int flags = allowCreation ? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE : SQLITE_OPEN_READWRITE;
	const char * vfs = NULL;
	int result = sqlite3_open_v2(filename, &(self->db), flags, vfs);
	
	if (self->db == NULL)
	{
		if (error != NULL)
		{
			*error = EESQLiteOutOfMemoryError();
		}
		return	NO;
	}
	else
	{
		return	EESQLiteHandleOKOrError(result, error, self->db);

		//	dealloc will take care of closing.
//		if (EESQLiteHandleOKOrError(result, error, self->db))
//		{
//			return	YES;
//		}
//		else
//		{
////			sqlite3_close(self->db);
//			return	NO;
//		}
	}
}
static
inline
BOOL
CleanupWithError(EESQLiteDatabase* self, NSError** error)
{
	return	EESQLiteHandleOKOrError(sqlite3_close(self->db), error, self->db);
}




#pragma mark	-	EESQLiteDatabase
- (void)executeSQL:(NSString *)command
{
	@autoreleasepool
	{
		NSError*	parerr		=	nil;
		NSArray*	stmts		=	[self statementsByParsingSQL:command error:&parerr];
		EESQLiteExceptIfThereIsAnError(parerr);
		
		for (EESQLiteStatement* stmt in stmts)
		{
			while ([stmt step])
			{
			}
		}
	}
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
	[self executeSQL:@"BEGIN TRANSACTION;"];
}
- (void)commitTransaction
{
	[self executeSQL:@"COMMIT TRANSACTION;"];
}
- (void)rollbackTransaction
{
	[self executeSQL:@"ROLLBACK TRANSACTION;"];
}
- (void)markSavepointWithName:(NSString *)savepointName
{
	EXCEPT_IF_NAME_IS_INVALID(savepointName);
	
	NSString*	cmdform	=	@"SAVEPOINT %@;";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, savepointName];
	
	[self executeSQL:cmd];
}
- (void)releaseSavepointOfName:(NSString *)savepointName
{
	EXCEPT_IF_NAME_IS_INVALID(savepointName);
	
	NSString*	cmdform	=	@"RELEASE %@;";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, savepointName];
	
	[self executeSQL:cmd];
}
- (void)rollbackToSavepointOfName:(NSString *)savepointName
{
	EXCEPT_IF_NAME_IS_INVALID(savepointName);
	
	NSString*	cmdform	=	@"ROLLBACK %@;";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, savepointName];
	
	[self executeSQL:cmd];
}
//- (BOOL)executeTransactionBlock:(BOOL (^)(void))transactionBlock
//{
//	return
//	[[self objectByExecutingTransactionBlock:^id
//	{
//		BOOL	result	=	transactionBlock();
//		return	result ? @(YES) : nil;
//	}] boolValue];
//}
//- (id)objectByExecutingTransactionBlock:(id (^)(void))transactionBlock
//{
//	BOOL	hasNoTransactionNow	=	[self isAutocommitMode];
//	
//	if (!hasNoTransactionNow)
//	{
//		@throw		EESQLiteExceptionForNestedExplicitTransaction();
//	}
//	
//	////
//	
//	[self beginTransaction];
//	
//	id	transactionResult	=	nil;
//
//	@try
//	{
//		transactionResult	=	transactionBlock();
//	}
//	@finally
//	{
//		if (transactionResult != nil)
//		{
//			[self commitTransaction];
//		}
//		else
//		{
//			[self rollbackTransaction];
//		}
//	}
//	
//	////	Return is fine to be here becasue there's nothing to return in exception situation.
//	return	transactionResult;
//}






#pragma mark	-	NSObject

- (NSString *)description
{
	return	[NSString stringWithFormat:@"<%@: memused = %llu (peak = %llu)>", NSStringFromClass([self class]), (unsigned long long)[self usingMemorySizeCurrent], (unsigned long long)[self usingMemorySizeAtPeak]];
}
- (id)initAsTemporaryDatabaseInMemoryWithError:(NSError *__autoreleasing *)error
{
	self	=	[super init];
	
	if (self && PrepareWithName(self, IN_MEMORY_DATABASE_NAME, error, YES))
	{
		return	self;
	}
	
	return	nil;
}
- (id)initAsTemporaryDatabaseOnDiskWithError:(NSError *__autoreleasing *)error
{
	self	=	[super init];

	if (self && PrepareWithName(self, nil, error, YES))
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
	
	if (self && PrepareWithName(self, pathTodDatabase, error, createIfNotExist))
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
	NSError*	error	=	nil;
	if(!CleanupWithError(self, &error))
	{
		@throw	EESQLiteExceptionFromError(error);
	}
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
- (BOOL)autocommitMode
{
	return	[self isAutocommitMode];
}
- (BOOL)isAutocommitMode
{
	return	sqlite3_get_autocommit(self->db) != 0;
}
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
	return	[identifierString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"[]'\""]].location == NSNotFound;
//	static	NSMutableCharacterSet*	validCharacters	=	nil;
//	static dispatch_once_t			onceToken;
//	dispatch_once(&onceToken, ^
//	{
//		validCharacters	=	[[NSMutableCharacterSet alloc] init];
//		[validCharacters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
//		[validCharacters formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];	
//		[validCharacters invert];
//	});
//
//	NSRange	firstInvalidRange	=	[identifierString rangeOfCharacterFromSet:validCharacters];
//	return	firstInvalidRange.location	==	NSNotFound;
}
+ (NSString *)stringWithEscapeForSQL:(NSString *)string
{
	return	[[NSString alloc] initWithFormat:@"[%@]", string];
//	NSString*	str2	=	[string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//	return	[NSString stringWithFormat:@"'%@'", str2];
}
@end
































