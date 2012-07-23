//
//  EESQLiteDatabase+SimpleQuery.m
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EESQLiteDatabase.h"
#import "EESQLiteDatabase+Internal.h"
#import "EESQLiteStatement.h"
#import "EESQLiteDatabase+CommandExecution.h"
#import "EESQLiteDatabase+Schema.h"
#import "EESQLiteDatabase+SimpleQuery.h"

@implementation EESQLiteDatabase (SimpleQuery)



- (BOOL)containsRawID:(EESQLiteRowID)rowID inTable:(NSString *)tableName
{
	if (![[self class] isValidIdentifierString:tableName])	return	NO;
	
	NSString*	cmdform	=	@"SELECT COUNT(_ROWID_) AS count FROM %@ WHERE _ROWID_ = %@";
	NSString*	idstr	=	[NSString stringWithFormat:@"%lld", rowID];
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName, idstr];
	NSArray*	rows	=	[self arrayOfRowsByExecutingSQL:cmd];
	NSNumber*	count	=	[[rows lastObject] valueForKey:@"count"];
	
	return		[count longLongValue] > 0;
}


- (NSArray *)arrayOfAllRowsInTable:(NSString *)tableName
{
	if (![[self class] isValidIdentifierString:tableName])	return	nil;
	
	NSString*	cmdform	=	@"SELECT * FROM %@";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName];
	
	return	[self arrayOfRowsByExecutingSQL:cmd];
}
- (NSArray *)arrayOfRowsHasValue:(id)value atColumne:(NSString *)columnName inTable:(NSString *)tableName limitCount:(NSUInteger)limitCount
{
	if (![[self class] isValidIdentifierString:columnName])	return	nil;
	if (![[self class] isValidIdentifierString:tableName])	return	nil;
	
	NSError*	inerr	=	nil;
	NSString*	paramnm	=	@"@columnValue";
	NSString*	limstr	=	[NSString stringWithFormat:@"%llu", (unsigned long long)limitCount];
	NSString*	cmdform	=	@"SELECT * FROM %@ WHERE %@ = %@ LIMIT %@;";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName, columnName, paramnm, limstr];
	NSArray*	stmts	=	[self statementsByParsingSQL:cmd error:&inerr];
	
	if (inerr == nil && [stmts count]== 1)
	{
		EESQLiteStatement*	stmt	=	[stmts lastObject];
		[stmt setValue:value forParameterName:paramnm error:&inerr];
		
		if (inerr == nil)
		{
			NSMutableArray*	results	=	[NSMutableArray array];
			
			while ([stmt stepWithError:&inerr])
			{
				if (inerr != nil)
				{
					return	nil;
				}
				
				[results addObject:[stmt dictionaryValue]];
			}
			return	results;
		}
	}
	return	nil;	
}
- (NSDictionary *)dictionaryFromRowHasValue:(id)value atColumne:(NSString *)columnName inTable:(NSString *)tableName
{
	return	[[self arrayOfRowsHasValue:value atColumne:columnName inTable:tableName limitCount:1] lastObject];
}
- (NSDictionary *)dictionaryFromRowHasID:(EESQLiteRowID)rowID inTable:(NSString *)tableName
{
	return	[self dictionaryFromRowHasValue:[NSNumber numberWithLongLong:rowID] atColumne:@"_ROWID_" inTable:tableName];
}
- (unsigned long long)countOfAllRowsInTable:(NSString *)tableName
{
	if (![[self class] isValidIdentifierString:tableName])	return	0;
	
	NSString*	cmdform	=	@"SELECT count(*) AS COUNT FROM %@;";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName];
	NSArray*	result	=	[self arrayOfRowsByExecutingSQL:cmd];
	
	return					[[[result lastObject] valueForKey:@"COUNT"] unsignedLongLongValue];
}









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
			 [ridlist appendRowID:sqlite3_last_insert_rowid([self rawdb])];
			 
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
- (void)deleteValuesFromTable:(NSString *)tableName withFilteringSQLExpression:(NSString *)filteringExpression error:(NSError *__autoreleasing *)error
{
	if (![[self class] isValidIdentifierString:tableName])	return;
	
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






- (BOOL)updateRowHasID:(EESQLiteRowID)rowID inTable:(NSString *)tableName withDictionary:(NSDictionary *)newValue
{
	return	[self updateRowHasValue:[NSNumber numberWithLongLong:rowID] atColumn:@"_ROWID_" inTable:tableName withDictionary:newValue];
}
- (BOOL)updateRowHasValue:(id)value atColumn:(NSString *)columnName inTable:(NSString *)tableName withDictionary:(NSDictionary *)newValue
{
	NSArray*	allKeyNames	=	[newValue allKeys];
	if (![[self class] isValidIdentifierString:columnName])	return	NO;
	if (![[self class] isValidIdentifierString:tableName])	return	NO;
	for (NSString* colnm in allKeyNames)
	{
		if (![[self class] isValidIdentifierString:colnm])	return	NO;
	}
	
	NSString*			(^setParameterNameForColumnName)(NSString*)=^(NSString* columnName)
	{
		return	[NSString stringWithFormat:@"@set_param_to_column_%@", columnName];
	};
	
	NSMutableArray*		setexps	=	[NSMutableArray arrayWithCapacity:[newValue count]];
	[newValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
	{
		NSString*		setexp	=	[NSString stringWithFormat:@"%@ = %@", key, setParameterNameForColumnName(key)];
		[setexps addObject:setexp];
	}];
	
	NSString*			setexpr	=	[setexps componentsJoinedByString:@","];
	NSString*			valPN	=	@"@criteria_column_value";
	NSString*			cmdform	=	@"UPDATE %@ SET %@ WHERE %@ = %@;";
	NSString*			cmd		=	[NSString stringWithFormat:cmdform, tableName, setexpr, columnName, valPN];
	
	////
	
	return
	[self executeTransactionBlock:^BOOL
	{
		NSError*			inerr	=	nil;
		EESQLiteStatement*	stmt	=	[[self statementsByParsingSQL:cmd error:&inerr] lastObject];
		
		if (inerr != nil)
		{
			return	NO;
		}
		else
		{
			NSError*	inerr4	=	nil;
			[stmt setValue:value forParameterName:valPN error:&inerr4];
			if (inerr4 != nil)
			{
				return	NO;
			}
			
			for (NSString*	keynm in allKeyNames)
			{
				NSError*	inerr2	=	nil;
				id			val		=	[newValue valueForKey:keynm];
				[stmt setValue:val forParameterName:setParameterNameForColumnName(keynm) error:&inerr2];
				
				if (inerr2 != nil)
				{
					return	NO;
				}
			}
			
			NSError*	inerr3	=	nil;
			while ([stmt stepWithError:&inerr3])
			{
				if (inerr3 != nil)
				{
					return	NO;
				}
			};
			
			return	YES;	
		}
		
	}];
}
- (void)deleteAllRowsInTable:(NSString *)tableName
{
	if (![[self class] isValidIdentifierString:tableName])	return;
	
	NSString*	cmdform	=	@"DELETE FROM %@;";
	NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName];
	
	[self executeTransactionBlock:^BOOL
	{	
		[self executeSQL:cmd];
		return	YES;
	}];
}
- (void)deleteRowsHasValue:(id)value atColumn:(NSString *)columnName inTable:(NSString *)tableName
{
	if (![[self class] isValidIdentifierString:columnName])	return;
	if (![[self class] isValidIdentifierString:tableName])	return;
	
	[self executeTransactionBlock:^BOOL
	{	
		NSString*	cmdform	=	@"DELETE FROM %@ WHERE %@ = %@";
		NSString*	valuenm	=	@"@valueParameter";
		NSString*	cmd		=	[NSString stringWithFormat:cmdform, tableName, columnName, valuenm];
		NSError*	inerr	=	nil;
		
		EESQLiteStatement*	stmt	=	[[self statementsByParsingSQL:cmd] lastObject];
		[stmt setValue:value forParameterName:valuenm error:&inerr];
		
		while ([stmt stepWithError:&inerr]) 
		{
			if (inerr != nil)
			{
				return	NO;
			}
		}
		return	YES;
	}];
}
- (void)deleteRowHasID:(EESQLiteRowID)rowID inTable:(NSString *)tableName
{
	[self deleteRowsHasValue:[NSNumber numberWithLongLong:rowID] atColumn:@"_ROWID_" inTable:tableName];
}
@end
