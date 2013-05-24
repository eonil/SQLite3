//
//  EESQLiteDatabase+Schema.m
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EESQLiteDatabase+CommandExecution.h"
#import "EESQLiteDatabase+Schema.h"




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
	return	[self arrayOfRowsByExecutingSQL:cmd];
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
