//
//  EESQLiteStatement.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				"EESQLite-Internal.h"
#import				"EESQLiteStatement.h"
#import				"EESQLiteStatement+Internal.h"









@implementation		EESQLiteStatement
{	
	sqlite3*			db;
	sqlite3_stmt*		stmt;
}
- (NSString *)SQL
{
	const char *	str		=	sqlite3_sql(stmt);
	return	[[NSString alloc] initWithBytesNoCopy:(void*)str length:strlen(str) encoding:NSUTF8StringEncoding freeWhenDone:NO];
}
- (sqlite3_stmt *)rawstmt
{
	return	stmt;
}




















- (BOOL)step
{
	return	[self stepWithError:NULL];
}
- (BOOL)stepWithError:(NSError *__autoreleasing *)error
{
	int	r	=	sqlite3_step(stmt);
	
	switch (r) 
	{
		case	SQLITE_OK:
		{
			return	NO;
		}
		case	SQLITE_ROW:
		{
			return	YES;
		}
		case	SQLITE_DONE:
		{
			return	NO;
		}
		default:
		{
			if (error != NULL)
			{
				*error	=	EESQLiteErrorFromReturnCode(r, db);
			}
			return	NO;
		}
	}
}
- (void)resetWithError:(NSError *__autoreleasing *)error
{
	EESQLiteHandleOKOrError(sqlite3_reset(stmt), error, db);
}
- (void)reset
{
	[self resetWithError:NULL];
}



- (long long)longLongValueForColumnIndex:(NSInteger)columnIndex
{
	return	sqlite3_column_int64(stmt, columnIndex);
}
- (double)doubleValueForColumnIndex:(NSInteger)columnIndex
{
	return	sqlite3_column_double(stmt, columnIndex);
}
- (NSString *)stringValueForColumnIndex:(NSInteger)columnIndex
{
	int				bc		=	sqlite3_column_bytes(stmt, columnIndex);
	const unsigned char *	txt	=	sqlite3_column_text(stmt, columnIndex);
	
	return			[[NSString alloc] initWithBytes:txt length:bc encoding:NSUTF8StringEncoding];
//	return			[[NSString alloc] initWithBytesNoCopy:(void*)txt length:bc encoding:NSUTF8StringEncoding freeWhenDone:NO];
}
- (NSData *)dataValueForColumnIndex:(NSInteger)columnIndex
{
	int				bc		=	sqlite3_column_bytes(stmt, columnIndex);
	const void *	buffer	=	sqlite3_column_blob(stmt, columnIndex);

	return			[NSData dataWithBytes:buffer length:bc];
//	return			[NSData dataWithBytesNoCopy:(void*)buffer length:bc freeWhenDone:NO];
}
- (BOOL)isNullAtColumnIndex:(NSInteger)columnIndex
{
	//	http://stackoverflow.com/questions/8961457/how-to-check-a-value-in-a-sqlite-column-is-null-or-not-with-c-api/8961553#8961553
	
	return	sqlite3_column_type(stmt, columnIndex) == SQLITE_NULL;
}
- (NSUInteger)dataCount
{
	return	sqlite3_data_count(stmt);
}
- (NSDictionary *)dictionaryValue
{
	return	[self dictionaryValueReplacingNullsWithValue:nil];
}
- (NSDictionary *)dictionaryValueReplacingNullsWithValue:(id)nullValue
{
	int						cn		=	sqlite3_data_count(stmt);
	NSMutableDictionary*	dict	=	[NSMutableDictionary dictionaryWithCapacity:cn];
	
	for (NSUInteger i=0; i<cn; i++)
	{
		const char *	keybuffer	=	sqlite3_column_name(stmt, i);
		NSString*		key			=	[NSString stringWithCString:keybuffer encoding:NSUTF8StringEncoding];
		id				val			=	nil;
		
		int		coltype		=	sqlite3_column_type(stmt, i);
		switch (coltype)
		{
			case	SQLITE_BLOB:
			{
//				val		=	[[self dataValueForColumnIndex:i] copy];
				val		=	[self dataValueForColumnIndex:i];
				break;
			}
			case	SQLITE_TEXT:
			{
//				val		=	[[self stringValueForColumnIndex:i] copy];
				val		=	[self stringValueForColumnIndex:i];
				break;
			}
			case	SQLITE_INTEGER:
			{
				val		=	[NSNumber numberWithLongLong:[self longLongValueForColumnIndex:i]];
				break;
			}
			case	SQLITE_FLOAT:
			{
				val		=	[NSNumber numberWithDouble:[self doubleValueForColumnIndex:i]];
				break;
			}
			case	SQLITE_NULL:
			{
				val		=	nullValue;
				break;
			}
			default:
			{
				//	Can't be other value by the SQLite3 specification.
				//	Anyway if it is, ignore it.
			}
		}
		
		if (val != nil)
		{
			[dict setObject:val forKey:key];
		}
	}
	
	return	dict;
}
















#pragma mark	-	NSObject

- (NSString *)description
{
	return	[NSString stringWithFormat:@"<%@: \"%@\">", NSStringFromClass([self class]), [self SQL]];
}
- (id)initWithDB:(sqlite3 *)newDb sql:(const char *)sql byte:(int)byte tail:(const char **)tail error:(NSError *__autoreleasing *)error
{
	self	=	[super init];
	
	if (self)
	{		
		db	=	newDb;

		EESQLiteHandleOKOrError(sqlite3_prepare_v2(db, sql, byte, &stmt, tail), error, db);
		
		if (stmt == NULL)
		{
			return	nil;
		}
		else 
		{
			return	self;
		}
	}
	else 
	{
		return	nil;
	}
}
- (void)dealloc
{
	EESQLiteHandleOKOrError(sqlite3_finalize(stmt), NULL, db);
}







+ (NSArray *)statementsWithSQLString:(NSString *)sqlString database:(EESQLiteDatabase *)database error:(NSError *__autoreleasing *)error
{	
	int byte = [sqlString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	const char * sql	=	[sqlString cStringUsingEncoding:NSUTF8StringEncoding];
	const char * tail;		
	
	NSMutableArray*		statements	=	[NSMutableArray array];
	
	do 
	{
		NSError*			internerr	=	nil;
		EESQLiteStatement*	statement	=	[[self alloc] initWithDB:[database rawdb] sql:sql byte:byte tail:&tail error:&internerr];
		
		if (statement != nil)
		{
			[statements addObject:statement];
		}
		
		if (internerr != nil)
		{
			if (error != NULL)
			{
				*error	=	internerr;
			}
			return	nil;
		}
		
		////
		
		byte	-=	tail - sql;
		sql		=	tail;
	}
	while (tail < sql);

	return		statements;
}
@end
































@implementation		EESQLiteStatement (Mutation)

void				EESQLiteStatementDummyFreeMemory(void * memory)
{
	//	Does nothing.
}

- (NSUInteger)parameterCount
{
	return	sqlite3_bind_parameter_count(stmt);
}
- (void)setLongLongValue:(long long)value forParameterIndex:(NSInteger)parameterIndex error:(NSError *__autoreleasing *)error
{
	EESQLiteHandleOKOrError(sqlite3_bind_int64(stmt, parameterIndex, value), error, db);
}
- (void)setDoubleValue:(double)value forParameterIndex:(NSInteger)parameterIndex error:(NSError *__autoreleasing *)error
{
	EESQLiteHandleOKOrError(sqlite3_bind_double(stmt, parameterIndex, value), error, db);
}
- (void)setStringValue:(NSString *)value forParameterIndex:(NSInteger)parameterIndex error:(NSError *__autoreleasing *)error
{ 
	const char *	buffer	=	[value cStringUsingEncoding:NSUTF8StringEncoding];
	int				len		=	[value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
//	EESQLiteHandleOKOrError(sqlite3_bind_text(stmt, parameterIndex, buffer, len, EESQLiteStatementDummyFreeMemory), error, db);
	EESQLiteHandleOKOrError(sqlite3_bind_text(stmt, parameterIndex, buffer, len, SQLITE_TRANSIENT), error, db);
}
- (void)setDataValue:(NSData *)value forParameterIndex:(NSInteger)parameterIndex error:(NSError *__autoreleasing *)error
{
	const void *	buffer	=	[value bytes];
	int				len		=	[value length];
	
//	EESQLiteHandleOKOrError(sqlite3_bind_blob(stmt, parameterIndex, buffer, len, EESQLiteStatementDummyFreeMemory), error, db);
	EESQLiteHandleOKOrError(sqlite3_bind_blob(stmt, parameterIndex, buffer, len, SQLITE_TRANSIENT), error, db);
}
- (void)setNullForParameterIndex:(NSInteger)parameterIndex error:(NSError *__autoreleasing *)error
{
	EESQLiteHandleOKOrError(sqlite3_bind_null(stmt, parameterIndex), error, db);
}
- (void)setValue:(id)value forParameterIndex:(NSInteger)parameterIndex error:(NSError *__autoreleasing *)error
{
	if ([value isKindOfClass:[NSData class]])
	{
		[self setDataValue:value forParameterIndex:parameterIndex error:error];
	}
	else
	if ([value isKindOfClass:[NSString class]])
	{
		[self setStringValue:value forParameterIndex:parameterIndex error:error];
	}
	else
	if ([value isKindOfClass:[NSNumber class]])
	{
		const char tc	=	*[value objCType];

		if (tc == 'd' || tc == 'f')
		{
			[self setDoubleValue:[value doubleValue] forParameterIndex:parameterIndex error:error];
		}
		else
		{
			[self setLongLongValue:[value longLongValue] forParameterIndex:parameterIndex error:error];
		}
	}
	else 
	{
		//	Bad typed value. Ignore it.
	}	
}
- (void)setValue:(id)value forParameterName:(NSString *)parameterName error:(NSError *__autoreleasing *)error
{
	int	paramidx	=	sqlite3_bind_parameter_index(stmt, [parameterName cStringUsingEncoding:NSUTF8StringEncoding]);
	
	[self setValue:value forParameterIndex:paramidx error:error];
}

- (void)clearParametersValuesWithError:(NSError *__autoreleasing *)error
{
	EESQLiteHandleOKOrError(sqlite3_clear_bindings(stmt), error, db);
}
@end








