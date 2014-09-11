//
//  EESQLiteStatement.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import	"EESQLiteError.h"
#import	"EESQLiteStatement.h"
#import	"EESQLiteStatement+Internal.h"
#import "EESQLiteDatabase+Limits.h"
#import "____internals____.h"


static uint64_t const
uint64_power(uint64_t const num, uint64_t const exp)
{
	EESQLITE3_DEBUG_ASSERT(exp <= 64);
	
	if (exp == 0)
	{
		return	1;
	}
	if (exp == 1)
	{
		return	num;
	}
	
	return	num * uint64_power(num, exp-1);
}
static int64_t const
SINT64_MAX()
{
	return	+(uint64_power(2ull, 63ull)) - 1ull;
}
static int64_t const
SINT64_MIN()
{
	return	-(uint64_power(2ull, 63ull)) + 1ull;
}













@implementation		EESQLiteStatement
{	
	sqlite3*			db;
	sqlite3_stmt*		stmt;
}
sqlite3_stmt* const
eesqlite3____get_raw_stmt_object_from(EESQLiteStatement* stmt)
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(stmt, EESQLiteStatement);
	
	////
	
	return	stmt->stmt;
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
			EESQLiteExceptWithReturnCodeForDatabase(r, db);
		}
	}
}
- (void)reset
{
	EESQLiteExceptIfReturnCodeIsNotOK(sqlite3_reset(stmt), db);
}






#if	EESQLiteOptimizeForSystemHaveEqualSizedIntAndNSInteger
#define	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_COLUMN_INDEX_VALUE(columnIndex)
#else
#define	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_COLUMN_INDEX_VALUE(columnIndex)		{ NSAssert((columnIndex) <= INT_MAX && (columnIndex) >= INT_MIN, @"Range of `columnIndex` must be in range of `int` defined by its limit. This is Objective-C wrapper level exception."); }
#endif

- (long long)longLongValueForColumnIndex:(NSInteger)columnIndex
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	EESQLITE3_DEBUG_ASSERT(columnIndex >= 0);
	EESQLITE3_DEBUG_ASSERT(columnIndex < [self dataCount]);
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_COLUMN_INDEX_VALUE(columnIndex);
	return	sqlite3_column_int64(stmt, (int)columnIndex);
}
- (NSInteger)integerValueForColumnIndex:(NSInteger)columnIndex
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	EESQLITE3_DEBUG_ASSERT(columnIndex >= 0);
	EESQLITE3_DEBUG_ASSERT(columnIndex < [self dataCount]);
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_COLUMN_INDEX_VALUE(columnIndex);
	return	(NSInteger)sqlite3_column_int64(stmt, (int)columnIndex);
}
- (double)doubleValueForColumnIndex:(NSInteger)columnIndex
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	EESQLITE3_DEBUG_ASSERT(columnIndex >= 0);
	EESQLITE3_DEBUG_ASSERT(columnIndex < [self dataCount]);
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_COLUMN_INDEX_VALUE(columnIndex);
	
	return	sqlite3_column_double(stmt, (int)columnIndex);
}
- (NSString *)stringValueForColumnIndex:(NSInteger)columnIndex
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	EESQLITE3_DEBUG_ASSERT(columnIndex >= 0);
	EESQLITE3_DEBUG_ASSERT(columnIndex < [self dataCount]);
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_COLUMN_INDEX_VALUE(columnIndex);
	
	int				bc		=	sqlite3_column_bytes(stmt, (int)columnIndex);
	const unsigned char *	txt	=	sqlite3_column_text(stmt, (int)columnIndex);
	
	return			[[NSString alloc] initWithBytes:txt length:bc encoding:NSUTF8StringEncoding];
//	return			[[NSString alloc] initWithBytesNoCopy:(void*)txt length:bc encoding:NSUTF8StringEncoding freeWhenDone:NO];
}
- (NSData *)dataValueForColumnIndex:(NSInteger)columnIndex
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	EESQLITE3_DEBUG_ASSERT(columnIndex >= 0);
	EESQLITE3_DEBUG_ASSERT(columnIndex < [self dataCount]);
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_COLUMN_INDEX_VALUE(columnIndex);

	int				bc		=	sqlite3_column_bytes(stmt, (int)columnIndex);
	const void *	buffer	=	sqlite3_column_blob(stmt, (int)columnIndex);

	return			[NSData dataWithBytes:buffer length:bc];
//	return			[NSData dataWithBytesNoCopy:(void*)buffer length:bc freeWhenDone:NO];
}
- (BOOL)isNullAtColumnIndex:(NSInteger)columnIndex
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	EESQLITE3_DEBUG_ASSERT(columnIndex >= 0);
	EESQLITE3_DEBUG_ASSERT(columnIndex < [self dataCount]);
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_COLUMN_INDEX_VALUE(columnIndex);

	//	http://stackoverflow.com/questions/8961457/how-to-check-a-value-in-a-sqlite-column-is-null-or-not-with-c-api/8961553#8961553
	
	return	sqlite3_column_type(stmt, (int)columnIndex) == SQLITE_NULL;
}
- (NSUInteger)dataCount
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	
	////
	
	return	sqlite3_data_count(stmt);
}
- (NSDictionary *)dictionaryValue
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	
	////
	
	return	[self dictionaryValueReplacingNullsWithValue:nil];
}
- (NSDictionary *)dictionaryValueReplacingNullsWithValue:(id)nullValue
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	
	////
	
	int						cn		=	sqlite3_data_count(stmt);
	NSMutableDictionary*	dict	=	[NSMutableDictionary dictionaryWithCapacity:cn];
	
	for (int i=0; i<cn; i++)
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

#undef	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_COLUMN_INDEX_VALUE














#pragma mark	-	NSObject

- (NSString *)description
{
	EESQLITE3_DEBUG_ASSERT(stmt != NULL);
	
	////
	
	return	[NSString stringWithFormat:@"<%@: \"%@\">", NSStringFromClass([self class]), [self SQL]];
}
- (id)initWithDB:(sqlite3 *)newDb sql:(const char *)sql byte:(int)byte tail:(const char **)tail error:(NSError *__autoreleasing *)error
{
	EESQLITE3_DEBUG_ASSERT(stmt == NULL);
	EESQLITE3_DEBUG_ASSERT(newDb != NULL);
	EESQLITE3_DEBUG_ASSERT(sql != NULL);
	EESQLITE3_DEBUG_ASSERT(tail != NULL);
	
	////
	
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
	EESQLITE3_DEBUG_ASSERT(sqlString != NULL);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(sqlString, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(database, EESQLiteDatabase);
	
	////
	
	NSUInteger		cmdlen		=	[sqlString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

#if	!EESQLiteOptimizeForSystemHaveEqualSizedIntAndNSInteger
	if (cmdlen>INT_MAX)
	{
		if (error != NULL)	*error	=	EESQLiteInputArgumentErrorDataIsTooLong();
		return	nil;
	}
	else
#endif
	{
		
		int				byte		=	(int)cmdlen;
		const char *	sql			=	[sqlString cStringUsingEncoding:NSUTF8StringEncoding];
		const char *	tail;
		
		NSMutableArray*	statements	=	[NSMutableArray array];
		
		do 
		{
			sqlite3*			coredb		=	eesqlite3____get_raw_db_object_from(database);
			
			NSError*			internerr	=	nil;
			EESQLiteStatement*	statement	=	[[self alloc] initWithDB:coredb sql:sql byte:byte tail:&tail error:&internerr];
			
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







inline static void
EXCEPT_DATA_TOO_LONG()
{
	EESQLiteExcept(@"The length in byte count of input data (encoded string or binary) is too long to be used as SQLite input argument. Maximum length cannot exceed `INT_MAX`. This is Objective-C wrapper level error.");
}

#if	EESQLiteOptimizeForSystemHaveEqualSizedIntAndNSInteger
#define	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE(parameterIndex)
#else
#define	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE(parameterIndex)		{ EESQLiteAssert(((parameterIndex) <= INT_MAX) && ((parameterIndex) >= INT_MIN), @"Range of `parameterIndex` must be in range of `int` defined by its limit. (This is Objective-C wrapper level assertion.)"); }
#endif

#define	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_INTEGER_PARAMETER_VALUE(parameterValue)		{ EESQLiteAssert(( ((unsigned long long)(parameterValue)) >= (0x8000000000000000ULL)) || ( ((unsigned long long)(parameterValue)) <= (0x7FFFFFFFFFFFFFFFULL)), @"Range of `parameterValue` must be in range of 64-bit signed integer. (This is Objective-C wrapper level assertion.)"); }

- (void)setInt64Value:(int64_t)value forParameterIndex:(NSInteger)parameterIndex
{
	EESQLITE3_DEBUG_ASSERT(value <= SINT64_MAX());
	EESQLITE3_DEBUG_ASSERT(value >= SINT64_MIN());
	EESQLITE3_DEBUG_ASSERT(parameterIndex <= [self parameterCount]);		//	Parameter index is 1-based.
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE(parameterIndex);
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_INTEGER_PARAMETER_VALUE(value);
	
	EESQLiteExceptIfReturnCodeIsNotOK(sqlite3_bind_int64(stmt, (int)parameterIndex, value), db);
}
- (void)setLongLongValue:(long long)value forParameterIndex:(NSInteger)parameterIndex
{
	EESQLITE3_DEBUG_ASSERT(value <= SINT64_MAX());
	EESQLITE3_DEBUG_ASSERT(value >= SINT64_MIN());
	EESQLITE3_DEBUG_ASSERT(parameterIndex <= [self parameterCount]);		//	Parameter index is 1-based.
	
	////

	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE(parameterIndex);
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_INTEGER_PARAMETER_VALUE(value);

	EESQLiteExceptIfReturnCodeIsNotOK(sqlite3_bind_int64(stmt, (int)parameterIndex, value), db);
}
- (void)setIntegerValue:(NSInteger)value forParameterIndex:(NSInteger)parameterIndex
{
	EESQLITE3_DEBUG_ASSERT(value <= SINT64_MAX());
	EESQLITE3_DEBUG_ASSERT(value >= SINT64_MIN());
	EESQLITE3_DEBUG_ASSERT(parameterIndex <= [self parameterCount]);		//	Parameter index is 1-based.
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE(parameterIndex);
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_INTEGER_PARAMETER_VALUE(value);
	
	EESQLiteExceptIfReturnCodeIsNotOK(sqlite3_bind_int64(stmt, (int)parameterIndex, value), db);
}
- (void)setDoubleValue:(double)value forParameterIndex:(NSInteger)parameterIndex
{
	EESQLITE3_DEBUG_ASSERT(parameterIndex <= [self parameterCount]);		//	Parameter index is 1-based.
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE(parameterIndex);
	
	EESQLiteExceptIfReturnCodeIsNotOK(sqlite3_bind_double(stmt, (int)parameterIndex, value), db);
}
- (void)setStringValue:(NSString *)value forParameterIndex:(NSInteger)parameterIndex 
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(value, NSString);
	EESQLITE3_DEBUG_ASSERT(parameterIndex <= [self parameterCount]);		//	Parameter index is 1-based.
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE(parameterIndex);
	const char *	buffer	=	[value cStringUsingEncoding:NSUTF8StringEncoding];
	NSUInteger		buflen	=	[value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
#if !EESQLiteInputArgumentErrorDataIsTooLong
	if (buflen>INT_MAX)
	{
		EXCEPT_DATA_TOO_LONG();
	}
	else
#endif
	{
		int	len	=	(int)buflen;
		EESQLiteExceptIfReturnCodeIsNotOK(sqlite3_bind_text(stmt, (int)parameterIndex, buffer, len, SQLITE_TRANSIENT), db);
	}
}
- (void)setDataValue:(NSData *)value forParameterIndex:(NSInteger)parameterIndex 
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(value, NSData);
	EESQLITE3_DEBUG_ASSERT(parameterIndex <= [self parameterCount]);		//	Parameter index is 1-based.
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE(parameterIndex);
	
	const void *	buffer	=	[value bytes];
	NSUInteger		buflen	=	[value length];
	
#if !EESQLiteInputArgumentErrorDataIsTooLong
	if (buflen>INT_MAX)
	{
		EXCEPT_DATA_TOO_LONG();
	}
	else
#endif
	{
		int	len	=	(int)buflen;
		EESQLiteExceptIfReturnCodeIsNotOK(sqlite3_bind_blob(stmt, (int)parameterIndex, buffer, len, SQLITE_TRANSIENT), db);
	}
}
- (void)setNullForParameterIndex:(NSInteger)parameterIndex
{
	EESQLITE3_DEBUG_ASSERT(parameterIndex <= [self parameterCount]);		//	Parameter index is 1-based.
	
	////
	
	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE(parameterIndex);

	EESQLiteExceptIfReturnCodeIsNotOK(sqlite3_bind_null(stmt, (int)parameterIndex), db);
}
- (void)setValue:(id)value forParameterIndex:(NSInteger)parameterIndex 
{
	EESQLITE3_DEBUG_ASSERT(parameterIndex <= [self parameterCount]);		//	Parameter index is 1-based.
	
	////
	
	if (value == nil)
	{
		return	[self setNullForParameterIndex:parameterIndex];
	}
	else
	if ([value isKindOfClass:[NSData class]])
	{
		return	[self setDataValue:value forParameterIndex:parameterIndex];
	}
	else
	if ([value isKindOfClass:[NSString class]])
	{
		return	[self setStringValue:value forParameterIndex:parameterIndex];
	}
	else
	if ([value isKindOfClass:[NSNumber class]])
	{
		const char tc	=	*[value objCType];

		if (tc == 'd' || tc == 'f')
		{
			[self setDoubleValue:[value doubleValue] forParameterIndex:parameterIndex];
		}
		else
		{
			[self setLongLongValue:[value longLongValue] forParameterIndex:parameterIndex];
		}
	}
	else 
	{
		//	Bad typed value. Ignore it.
	}	
}
- (void)setValue:(id)value forParameterName:(NSString *)parameterName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(parameterName, NSString);
	
	////
	
	int	paramidx	=	sqlite3_bind_parameter_index(stmt, [parameterName cStringUsingEncoding:NSUTF8StringEncoding]);
	
	[self setValue:value forParameterIndex:paramidx];
}

- (void)clearParametersValues
{
	EESQLiteExceptIfReturnCodeIsNotOK(sqlite3_clear_bindings(stmt), db);
}
@end


#undef	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_PARAMETER_INDEX_VALUE
#undef	CHECK_AND_ASSERT_OVERFLOW_OR_UNDERFLOW_INTEGER_PARAMETER_VALUE







