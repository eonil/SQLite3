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

















































@implementation		EESQLiteDatabase (Select)

- (NSArray *)arrayOfValuesByExecutingSQL:(NSString *)command
{
	return	[self arrayOfValuesByExecutingSQL:command replacingNullsWithValue:nil];
}
- (NSArray *)arrayOfValuesByExecutingSQL:(NSString *)command replacingNullsWithValue:(id)nullValue
{
	NSMutableArray*	array	=	[NSMutableArray array];
	
	[self enumerateRowsByExecutingSQL:command block:^(NSDictionary *row, BOOL *stop) 
	{
		[array addObject:row];
	}];
	
	return	array;
}
- (void)enumerateRowsByExecutingSQL:(NSString *)command block:(void (^)(NSDictionary *, BOOL *))block
{
	return	[self enumerateRowsByExecutingSQL:command replacingNullsWithValue:nil block:block];
}
- (void)enumerateRowsByExecutingSQL:(NSString *)command replacingNullsWithValue:(id)nullValue block:(void (^)(NSDictionary *, BOOL *))block
{
	NSArray*	stmts	=	[self statementsByParsingSQL:command];
	
	for (EESQLiteStatement*	stmt in stmts)
	{
		BOOL				internstop	=	NO;
		while ([stmt step])
		{
			block([stmt dictionaryValueReplacingNullsWithValue:nullValue], &internstop);
			if (internstop)	break;
		};

		if (internstop)	break;
	}
}
@end








@implementation		EESQLiteDatabase (Mutate)
- (EESQLiteRowID)insertDictionaryValue:(NSDictionary *)dictionaryValue intoTable:(NSString *)tableName error:(NSError *__autoreleasing *)error
{
	if (dictionaryValue == nil)
	{
		dictionaryValue	=	[NSDictionary dictionary];
	}
	
	NSArray*			vallist	=	[NSArray arrayWithObject:dictionaryValue];
	EESQLiteRowIDList*	ridlist	=	[self insertArrayOfDictionaryValues:vallist intoTable:tableName error:error];
	return				[ridlist lastRowID];
}
- (EESQLiteRowIDList *)insertArrayOfDictionaryValues:(NSArray *)dictionaryValues intoTable:(NSString *)tableName error:(NSError *__autoreleasing *)error
{
	NSArray*			cols	=	[self allColumnNamesOfTable:tableName];
	NSUInteger			len		=	[cols count];
	NSMutableString*	cmd		=	[NSMutableString string];
	
	[cmd appendString:@"INSERT INTO "];
	[cmd appendString:tableName];
	[cmd appendString:@" ("];

	for (NSUInteger i=0; i<len-1 ;i++)
	{
		[cmd appendString:[cols objectAtIndex:i]];
		[cmd appendString:@","];
	};
	[cmd appendString:[cols lastObject]];
	[cmd appendString:@")"];
	[cmd appendString:@" VALUES ("];
	
	for (NSUInteger i=0; i<len-1; i++)
	{
		[cmd appendString:@"@"];
		[cmd appendString:[cols objectAtIndex:i]];
		[cmd appendString:@","];
	}
	[cmd appendString:@"@"];
	[cmd appendString:[cols lastObject]];
	[cmd appendString:@");"];
	
	////
	
	NSArray*					stmts	=	[self statementsByParsingSQL:cmd];
	EESQLiteStatement*			stmt	=	[stmts objectAtIndex:0];
	EESQLiteMutableRowIDList*	ridlist	=	[[EESQLiteMutableRowIDList alloc] init];
	
	[self executeTransactionBlock:^BOOL
	{
		for (NSDictionary* dict in dictionaryValues)
		{
			__block
			NSError*	inerr	=	nil;
			
			[dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
			{
				NSString*	paramname	=	[NSString stringWithFormat:@"@%@", key];
				[stmt setValue:obj forParameterName:paramname error:&inerr];
				
				*stop	=	inerr != nil;
			}];
			
			if (inerr != nil)
			{
				if (error != NULL)
				{
					*error	=	inerr;
				}
				return	NO;
			}
			
			[stmt stepWithError:&inerr];
			[stmt reset];
			[ridlist appendRowID:sqlite3_last_insert_rowid(db)];
			
			if (inerr != nil)
			{
				return	NO;
			}
			
			[stmt clearParametersValuesWithError:&inerr];
			
			if (inerr != nil)
			{
				return	NO;
			}
		}	
		return	YES;
	}];
	
	return	ridlist;
}
- (void)updateTable:(NSString *)tableName withDictionaryValue:(NSDictionary *)dictionaryValue filteringSQLExpression:(NSString *)filteringExpression error:(NSError *__autoreleasing *)error
{
	NSMutableString*	cmd		=	[NSMutableString string];
	
	[cmd appendString:@"UPDATE '"];
	[cmd appendString:tableName];
	[cmd appendString:@"' SET ("];

	[dictionaryValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
	{
		[cmd appendFormat:@"%@ = @%@", key, key];
		[cmd appendString:@","];
	}];
	
	[cmd deleteCharactersInRange:(NSRange){cmd.length-1,1}];
	[cmd appendString:@") WHERE "];
	[cmd appendString:filteringExpression];
	
	////
	
	[self executeTransactionBlock:^BOOL
	{
		NSError*	inerr	=	nil;
		[self executeSQL:cmd error:&inerr];
		
		if (error != NULL)
		{
			*error	=	inerr;
		}
		return		inerr == nil;
	}];
}
- (void)deleteValuesFromTable:(NSString *)tableName withFilteringSQLExpression:(NSString *)filteringExpression error:(NSError *__autoreleasing *)error
{
	NSString*	cmd		=	[NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@", tableName, filteringExpression];
	
	[self executeTransactionBlock:^BOOL
	{
		NSError*	inerr	=	nil;
		[self executeSQL:cmd error:&inerr];
		
		if (error != NULL)
		{
			*error	=	inerr;
		}
		return		inerr == nil;
	}];
}

@end





































@implementation		EESQLiteDatabase (Schema)
- (NSArray *)allSchema
{
	return	[self arrayOfValuesByExecutingSQL:@"SELECT * FROM sqlite_master;"];
}
- (NSArray *)allTableNames
{
	NSArray*			list	=	[self arrayOfValuesByExecutingSQL:@"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"];
	NSMutableArray*		names	=	[NSMutableArray arrayWithCapacity:[list count]];
	
	[list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
	{
		NSDictionary*	dict	=	obj;
		[names addObject:[dict objectForKey:@"name"]];
	}];
	
	return	names;
}
- (NSArray *)allColumnNamesOfTable:(NSString *)tableName
{
	NSArray*			list	=	[self tableInformationForName:tableName];
	NSMutableArray*		names	=	[NSMutableArray arrayWithCapacity:[list count]];
	
	[list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
	{
		NSDictionary*	dict	=	obj;
		[names addObject:[dict objectForKey:@"name"]];
	}];
	
	return	names;
}
- (NSArray *)tableInformationForName:(NSString *)tableName
{
	NSString*	cmd		=	[NSString stringWithFormat:@"PRAGMA table_info('%@');", tableName];
	return	[self arrayOfValuesByExecutingSQL:cmd];
}
- (void)addTableWithName:(NSString *)tableName withColumnNames:(NSArray *)columnNames
{
	[self addTableWithName:tableName withColumnNames:columnNames rowIDAliasColumnName:nil];
}
- (void)addTableWithName:(NSString *)tableName withColumnNames:(NSArray *)columnNames rowIDAliasColumnName:(NSString *)rowIDAliasColumnName
{
	if (nil!=rowIDAliasColumnName && ![columnNames containsObject:rowIDAliasColumnName])
	{
		columnNames	=	[columnNames arrayByAddingObject:rowIDAliasColumnName];
	}
	
	NSString*			tblexp	=	[[self class] stringWithEscapeForSQL:tableName];
	NSMutableArray*		colexps	=	[NSMutableArray arrayWithCapacity:[columnNames count]];
	
	for (NSString* colnm in columnNames)
	{
		NSString*	colexp	=	[[self class] stringWithEscapeForSQL:colnm];
		
		if ([colnm isEqualToString:rowIDAliasColumnName])
		{
			colexp	=	[colexp stringByAppendingString:@" INTEGER PRIMARY KEY ASC"];
		}
		
		[colexps addObject:colexp];
	}
	
	[self addTableWithExpession:tblexp withColumnExpressions:colexps isTemporary:NO onlyWhenNotExist:NO];
}
- (void)addTableWithExpession:(NSString *)tableExpression withColumnExpressions:(NSArray *)columnExpressions isTemporary:(BOOL)temporary onlyWhenNotExist:(BOOL)ifNotExist
{
	NSString*			tmpexp	=	temporary ? @"TEMP" : @"";
	NSString*			extexp	=	ifNotExist ? @"IF NOT EXIST" : @"";
	NSString*			colexps	=	[columnExpressions componentsJoinedByString:@","];
	NSString*			sqlcmd	=	[NSString stringWithFormat:@"CREATE %@ TABLE %@ %@ (%@);", tmpexp, extexp, tableExpression, colexps];

	[self executeSQL:sqlcmd];
}
- (void)removeTableWithName:(NSString *)tableName
{
	NSString*	cmd		=	[NSString stringWithFormat:@"DROP TABLE '%@';", tableName];
	[self executeSQL:cmd];
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
+ (NSString *)stringWithEscapeForSQL:(NSString *)string
{
	NSString*	str2	=	[string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	return	[NSString stringWithFormat:@"'%@'", str2];
}
@end
































