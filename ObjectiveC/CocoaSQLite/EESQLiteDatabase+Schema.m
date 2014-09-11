//
//  EESQLiteDatabase+Schema.m
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EESQLiteDatabase+CommandExecution.h"
#import "EESQLiteDatabase+Schema.h"
#import "____internals____.h"



@implementation 
EESQLiteDatabase (Schema)



- (NSArray *)allRawSchema
{
	return		[self arrayOfRowsByExecutingSQL:@"SELECT * FROM sqlite_master;"];
}
- (NSArray *)allTableNames
{
	NSArray*			list	=	[self arrayOfRowsByExecutingSQL:@"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"];
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
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
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
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	NSString*	cmd		=	[NSString stringWithFormat:@"PRAGMA table_info('%@');", tableName];
	return	[self arrayOfRowsByExecutingSQL:cmd];
}
- (void)addTableWithName:(NSString *)tableName withColumnNames:(NSArray *)columnNames
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnNames, NSArray);
	
	////
	
	[self addTableWithName:tableName withColumnNames:columnNames rowIDAliasColumnName:nil];
}
- (void)addTableWithName:(NSString *)tableName withColumnNames:(NSArray *)columnNames rowIDAliasColumnName:(NSString *)rowIDAliasColumnName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnNames, NSArray);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE_OR_NIL(rowIDAliasColumnName, NSString);
	
	////
	
	if (nil!=rowIDAliasColumnName && ![columnNames containsObject:rowIDAliasColumnName])
	{
		columnNames	=	[columnNames arrayByAddingObject:rowIDAliasColumnName];
	}
	
	NSString*			tblexp	=	[[self class] stringWithEscapeForSQL:tableName];
	NSMutableArray*		colexps	=	[NSMutableArray arrayWithCapacity:[columnNames count]];
	
	for (NSString* colnm in columnNames)
	{
		EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(colnm, NSString);
		
		////
		
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
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableExpression, NSString);
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(columnExpressions, NSArray);
	if (EONIL_DEBUG_MODE)
	{
		for (id o1 in columnExpressions)
		{
			EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(o1, NSString);
		}
	}

	////

	NSString*			tmpexp	=	temporary ? @"TEMP" : @"";
	NSString*			extexp	=	ifNotExist ? @"IF NOT EXIST" : @"";
	NSString*			colexps	=	[columnExpressions componentsJoinedByString:@","];
	NSString*			sqlcmd	=	[NSString stringWithFormat:@"CREATE %@ TABLE %@ %@ (%@);", tmpexp, extexp, tableExpression, colexps];
	
	[self executeSQL:sqlcmd];
}
- (void)removeTableWithName:(NSString *)tableName
{
	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(tableName, NSString);
	
	////
	
	NSString*	cmd		=	[NSString stringWithFormat:@"DROP TABLE '%@';", tableName];
	[self executeSQL:cmd];
}
@end
