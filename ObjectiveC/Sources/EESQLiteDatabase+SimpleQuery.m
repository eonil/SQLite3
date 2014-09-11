//
//  EESQLiteDatabase+SimpleQuery.m
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EESQLiteException.h"
#import "EESQLiteDatabase.h"
#import "EESQLiteStatement.h"
#import "EESQLiteDatabase+CommandExecution.h"
#import "EESQLiteDatabase+Schema.h"
#import "EESQLiteDatabase+SimpleQuery.h"
#import "____internals____.h"




inline static void
EXCEPT_IF_STATEMENT_IS_NOT_SINGLE(NSArray* stmts)
{
	if ([stmts count] != 1)
	{
		EESQLiteExcept(@"Reason unknown, but count of generated statement is not 1.");
	}
}

inline static void
EXCEPT_IF_NAME_IS_INVALID(NSString* name)
{
	if (![EESQLiteDatabase isValidIdentifierString:name])
	{
		EESQLiteExcept([NSString stringWithFormat:@"The name %@ is invalid for SQLite3.", name]);
	}
}














@implementation EESQLiteDatabase (SimpleQuery)


- (BOOL)checkIntegrity
{
	NSArray*		rows	=	[self arrayOfRowsByExecutingSQL:@"PRAGMA integrity_check;"];
	
	if ([rows count] == 1 && [[rows lastObject] count] == 1 && [[[[[rows lastObject] allValues] lastObject] uppercaseString] isEqual:@"OK"])
	{
		return	YES;
	}
	else
	{
		return	NO;
	}
}

- (BOOL)containsRawID:(EESQLiteRowID)rowID inTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	
	NSString*	cmdform	=	@"SELECT COUNT(_ROWID_) AS count FROM [%@] WHERE _ROWID_ = %@";
	NSString*	idstr	=	[NSString stringWithFormat:@"%lld", rowID];
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName, idstr];
	NSArray*	rows	=	[self arrayOfRowsByExecutingSQL:cmd];
	NSNumber*	count	=	[[rows lastObject] valueForKey:@"count"];
	
	return		[count longLongValue] > 0;
}


- (NSArray *)arrayOfAllRowsInTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	
	NSString*	cmdform	=	@"SELECT * FROM [%@]";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName];
	
	return	[self arrayOfRowsByExecutingSQL:cmd];
}
- (NSArray *)arrayOfRowsHasValue:(id)value atColumne:(NSString *)columnName inTable:(NSString *)tableName limitCount:(NSUInteger)limitCount
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(columnName);
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	
	NSString*	paramnm	=	@"@columnValue";
	NSString*	limstr	=	[NSString stringWithFormat:@"%llu", (unsigned long long)limitCount];
	NSString*	cmdform	=	@"SELECT * FROM [%@] WHERE [%@] = %@ LIMIT %@;";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName, columnName, paramnm, limstr];
	
	@autoreleasepool
	{
		NSError*	inerr	=	nil;
		NSArray*	stmts	=	[self statementsByParsingSQL:cmd error:&inerr];
		EESQLiteExceptIfThereIsAnError(inerr);
		EXCEPT_IF_STATEMENT_IS_NOT_SINGLE(stmts);
		
		EESQLiteStatement*	stmt	=	[stmts lastObject];
		[stmt setValue:value forParameterName:paramnm];
		
		NSMutableArray*	results	=	[NSMutableArray array];
		
		while ([stmt step])
		{
			[results addObject:[stmt dictionaryValue]];
		}
		return	results;
	}
}
- (void)enumerateAllRowsInTable:(NSString *)tableName block:(void (^)(NSDictionary *, BOOL *))block
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	EESQLITE3_DEBUG_ASSERT(block != nil);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	
	NSString*	cmdform	=	@"SELECT * FROM [%@]";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName];
	
	[self enumerateRowsByExecutingSQL:cmd block:block];
}
- (void)enumerateRowsHasValue:(id)value atColumne:(NSString *)columnName inTable:(NSString *)tableName limitCount:(NSUInteger)limitCount usingBlock:(void (^)(NSDictionary *, BOOL *))block
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	EESQLITE3_DEBUG_ASSERT(block != nil);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(columnName);
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	
	NSString*	paramnm	=	@"@columnValue";
	NSString*	limstr	=	[NSString stringWithFormat:@"%llu", (unsigned long long)limitCount];
	NSString*	cmdform	=	@"SELECT * FROM [%@] WHERE [%@] = %@ LIMIT %@;";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName, columnName, paramnm, limstr];
	
	@autoreleasepool
	{
		NSError*	inerr	=	nil;
		NSArray*	stmts	=	[self statementsByParsingSQL:cmd error:&inerr];
		EXCEPT_IF_STATEMENT_IS_NOT_SINGLE(stmts);
		EESQLiteExceptIfThereIsAnError(inerr);
		
		EESQLiteStatement*	stmt	=	stmts[0];
		[stmt setValue:value forParameterName:paramnm];
		
		BOOL	stop	=	NO;
		while (!stop && [stmt step])
		{
			block([stmt dictionaryValue], &stop);
		}
	}
}
- (void)enumerateRowsHasValue:(id)value atColumne:(NSString *)columnName inTable:(NSString *)tableName usingBlock:(void (^)(NSDictionary *, BOOL *))block
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	EESQLITE3_DEBUG_ASSERT(block != nil);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(columnName);
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	
	NSString*	paramnm	=	@"@columnValue";
	NSString*	cmdform	=	@"SELECT * FROM [%@] WHERE [%@] = %@;";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName, columnName, paramnm];
	
	@autoreleasepool
	{
		NSError*	inerr	=	nil;
		NSArray*	stmts	=	[self statementsByParsingSQL:cmd error:&inerr];
		EXCEPT_IF_STATEMENT_IS_NOT_SINGLE(stmts);
		EESQLiteExceptIfThereIsAnError(inerr);

		EESQLiteStatement*	stmt	=	stmts[0];
		[stmt setValue:value forParameterName:paramnm];
		
		BOOL	stop	=	NO;
		while (!stop && [stmt step])
		{
			block([stmt dictionaryValue], &stop);
		}
	}
}
- (void)enumerateRowsHasValue:(id)value atColumne:(NSString *)columnName inTable:(NSString *)tableName limitCount:(NSUInteger)limitCount block:(void (^)(NSDictionary *, BOOL *))block
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	EESQLITE3_DEBUG_ASSERT(block != nil);

	////
	
	return	[self enumerateRowsHasValue:value atColumne:columnName inTable:tableName limitCount:limitCount usingBlock:block];
}

- (NSDictionary *)dictionaryFromRowHasValue:(id)value atColumne:(NSString *)columnName inTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);

	////
	
	return	[[self arrayOfRowsHasValue:value atColumne:columnName inTable:tableName limitCount:1] lastObject];
}
- (NSDictionary *)dictionaryFromRowHasID:(EESQLiteRowID)rowID inTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	return	[self dictionaryFromRowHasValue:[NSNumber numberWithLongLong:rowID] atColumne:@"_ROWID_" inTable:tableName];
}
- (unsigned long long)countOfAllRowsInTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	
	NSString*	cmdform	=	@"SELECT count(*) AS COUNT FROM [%@];";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName];
	NSArray*	result	=	[self arrayOfRowsByExecutingSQL:cmd];
	
	return					[[[result lastObject] valueForKey:@"COUNT"] unsignedLongLongValue];
}









- (EESQLiteRowID)insertDictionaryValue:(NSDictionary *)dictionaryValue intoTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	if (dictionaryValue == nil)
	{
		dictionaryValue	=	[NSDictionary dictionary];
	}
	
	NSArray*			vallist	=	[NSArray arrayWithObject:dictionaryValue];
	EESQLiteRowIDList*	ridlist	=	[self insertArrayOfDictionaryValues:vallist intoTable:tableName];
	
	return				[ridlist lastRowID];
}
- (EESQLiteRowIDList *)insertArrayOfDictionaryValues:(NSArray *)dictionaryValues intoTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	EESQLiteAssert([[self allTableNames] containsObject:tableName], @"The table-name must be exist.");
	
	@autoreleasepool
	{
		NSArray*			cols	=	[self allColumnNamesOfTable:tableName];
		NSUInteger			len		=	[cols count];
		NSMutableString*	cmd		=	[NSMutableString string];
		
		if (cols.count == 0)
		{
			//	SQLite is known as not to support table with no column.
			//	And also, doesn't support INSERT INTO with no column setting.
			//	So treat it invalid table name which is not exist.
			//
			//	Ref:
			//	http://stackoverflow.com/questions/4567180/sqlite3-creating-table-with-no-columns
			NSString*		message	=	[NSString stringWithFormat:@"There's no column defined for the table-name. Seems no table exist for the name: %@", tableName];
			EESQLiteExcept(message);
			return	nil;
		}
		else
		{
			[cmd appendString:@"INSERT INTO ["];
			[cmd appendString:tableName];
			[cmd appendString:@"]("];
			
			if (len > 0)		//	`len` can be zero. In that case, `len-1` goes to insane number.
			{
				for (NSUInteger i=0; i<len-1 ;i++)
				{
					[cmd appendString:@"["];
					[cmd appendString:[cols objectAtIndex:i]];
					[cmd appendString:@"]"];
					[cmd appendString:@","];
				}
				[cmd appendString:[cols lastObject]];
			}
			[cmd appendString:@")"];
			[cmd appendString:@" VALUES ("];
			
			if (len > 0)		//	`len` can be zero. In that case, `len-1` goes to insane number.
			{
				for (NSUInteger i=0; i<len-1; i++)
				{
					[cmd appendString:@"@"];
					[cmd appendString:[cols objectAtIndex:i]];
					[cmd appendString:@","];
				}
				[cmd appendString:@"@"];
				[cmd appendString:[cols lastObject]];
			}
			[cmd appendString:@");"];
			
			////
			
			@autoreleasepool
			{	
				NSError*					err		=	nil;
				NSArray*					stmts	=	[self statementsByParsingSQL:cmd error:&err];
				
				//	SQL command parsing error.
				//	This should not happen because SQL command is generated by program.
				//	This means a bug in the program. Fix it.
				EESQLiteExceptIfThereIsAnError(err);
				
				////
				
				EESQLiteStatement*			stmt	=	stmts[0];
				EESQLiteMutableRowIDList*	ridlist	=	[[EESQLiteMutableRowIDList alloc] init];
				
				for (NSDictionary* dict in dictionaryValues)
				{
					[dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
					{
						NSString*	paramname	=	[NSString stringWithFormat:@"@%@", key];
						[stmt setValue:obj forParameterName:paramname];
					}];
					
					[stmt step];
					[stmt reset];
					[ridlist appendRowID:sqlite3_last_insert_rowid(eesqlite3____get_raw_db_object_from(self))];
					[stmt clearParametersValues];
				}
				
				return	ridlist;
			}
		}
	}
}







- (void)updateRowHasID:(EESQLiteRowID)rowID inTable:(NSString *)tableName withDictionary:(NSDictionary *)newValue
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	[self updateRowHasValue:[NSNumber numberWithLongLong:rowID] atColumn:@"_ROWID_" inTable:tableName withDictionary:newValue];
}
- (void)updateRowHasValue:(id)columnValue atColumn:(NSString *)columnName inTable:(NSString *)tableName withDictionary:(NSDictionary *)newValue replacingValueAsNull:(id)nullValue
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	NSArray*	allKeyNames	=	[newValue allKeys];
	EXCEPT_IF_NAME_IS_INVALID(columnName);
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	for (NSString* colnm in allKeyNames)
	{
		EXCEPT_IF_NAME_IS_INVALID(colnm);
	}
	
	////
	
	@autoreleasepool
	{
		NSString*			(^setParameterNameForColumnName)(NSString*)=^(NSString* columnName)
		{
			return	[NSString stringWithFormat:@"@set_param_to_column_%@", columnName];
		};
		
		NSMutableArray*		setexps	=	[NSMutableArray arrayWithCapacity:[newValue count]];
		[newValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
		{
			NSString*		setexp	=	[NSString stringWithFormat:@"[%@] = %@", key, setParameterNameForColumnName(key)];
			[setexps addObject:setexp];
		}];
		
		id (^filterNullValue)(id value) = ^(id value)
		{
			return	(value == nullValue || [value isEqual:nullValue]) ? nil : value;
		};
		
		NSString*			setexpr	=	[setexps componentsJoinedByString:@","];
		NSString*			FCPN	=	@"@criteria_column_value";					//	Filter-Column Paramter Name.
		NSString*			cmdform	=	@"UPDATE [%@] SET %@ WHERE [%@] = %@;";
		NSString*			cmd		=	[NSString stringWithFormat:cmdform, tableName, setexpr, columnName, FCPN];
		
		////

		@autoreleasepool
		{
			NSError*			inerr	=	nil;
			EESQLiteStatement*	stmt	=	[[self statementsByParsingSQL:cmd error:&inerr] lastObject];
			EESQLiteExceptIfThereIsAnError(inerr);
			
			[stmt setValue:filterNullValue(columnValue) forParameterName:FCPN];
			
			for (NSString*	keynm in allKeyNames)
			{
				id			val		=	[newValue valueForKey:keynm];
				[stmt setValue:filterNullValue(val) forParameterName:setParameterNameForColumnName(keynm)];
			}
			
			while ([stmt step])
			{
			};
		}
	}
}
- (void)updateRowHasValue:(id)columnValue atColumn:(NSString *)columnName inTable:(NSString *)tableName withDictionary:(NSDictionary *)newValue
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	[self updateRowHasValue:columnValue atColumn:columnName inTable:tableName withDictionary:newValue replacingValueAsNull:nil];
}
- (void)deleteAllRowsFromTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	
	NSString*	cmdform	=	@"DELETE FROM [%@];";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName];

	[self executeSQL:cmd];
}
- (void)deleteRowsHasValue:(id)value atColumn:(NSString *)columnName fromTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	EXCEPT_IF_NAME_IS_INVALID(tableName);
	EXCEPT_IF_NAME_IS_INVALID(columnName);

	NSString*	cmdform	=	@"DELETE FROM [%@] WHERE [%@] = %@";
	NSString*	valuenm	=	@"@valueParameter";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName, columnName, valuenm];
	
	@autoreleasepool
	{
		NSError*			parerr	=	nil;
		EESQLiteStatement*	stmt	=	[self statementsByParsingSQL:cmd error:&parerr][0];
		EESQLiteExceptIfThereIsAnError(parerr);
		
		[stmt setValue:value forParameterName:valuenm];
		while ([stmt step])
		{
		}
	}
}
- (void)deleteRowHasID:(EESQLiteRowID)rowID fromTable:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);

	////
	
	return	[self deleteRowsHasValue:[NSNumber numberWithLongLong:rowID] atColumn:@"_ROWID_" fromTable:tableName];
}









- (void)performTransactionUsingBlock:(void (^)(void))block
{
	EESQLITE3_DEBUG_ASSERT(block != nil);
	
	////
	
	[self objecyByPerformingTransactionUsingBlock:^id
	{
		block();
		return 	nil;
	}];
}
- (id)objecyByPerformingTransactionUsingBlock:(id (^)(void))block
{
	EESQLITE3_DEBUG_ASSERT(block != nil);
	
	////
	
	BOOL	hasNoTransactionNow	=	[self isAutocommitMode];

	if (!hasNoTransactionNow)
	{
		@throw		EESQLiteExceptionForNestedExplicitTransaction();
	}

	////

	[self beginTransaction];

	id				transactionResult	=	nil;
	NSException*	caughtException		=	nil;

	@try
	{
		transactionResult	=	block();
		[self commitTransaction];
		
		//	Do not return at here because it may abuse stack-unwinding, and may cause
		//	weird behavior. Return at the end of the function.
	}
	@catch (NSException* exc)
	{
		[self rollbackTransaction];
		caughtException	=	exc;
	}
	
	if (caughtException)
	{
		@throw	caughtException;
	}
	
	return	transactionResult;
}

@end





















