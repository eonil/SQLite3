//
//  EESQLiteDatabase+CommandExecution.m
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EESQLiteStatement.h"
#import "EESQLiteDatabase+CommandExecution.h"

@implementation EESQLiteDatabase (CommandExecution)
- (NSArray *)arrayOfValuesByExecutingSQL:(NSString *)command											EESQLITE3_DEPRECATED_METHOD
{
return	[self arrayOfRowsByExecutingSQL:command];
}
- (NSArray *)arrayOfValuesByExecutingSQL:(NSString *)command replacingNullsWithValue:(id)nullValue		EESQLITE3_DEPRECATED_METHOD
{
return	[self arrayOfRowsByExecutingSQL:command replacingNullsWithValue:nullValue];
}
- (NSArray *)arrayOfRowsByExecutingSQL:(NSString *)command
{
	return	[self arrayOfRowsByExecutingSQL:command replacingNullsWithValue:nil];
}
- (NSArray *)arrayOfRowsByExecutingSQL:(NSString *)command replacingNullsWithValue:(id)nullValue
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
	[self enumerateRowsByExecutingSQL:command replacingNullsWithValue:nil block:block];
}
- (void)enumerateRowsByExecutingSQL:(NSString *)command replacingNullsWithValue:(id)nullValue block:(void (^)(NSDictionary *, BOOL *))block
{
	@autoreleasepool
	{
		NSArray*	stmts		=	[self statementsByParsingSQL:command];
		
		for (EESQLiteStatement*	stmt in stmts)
		{
			BOOL	internstop	=	NO;
			while ([stmt step])
			{
				block([stmt dictionaryValueReplacingNullsWithValue:nullValue], &internstop);
				if (internstop)	break;
			};
			
			if (internstop)	break;
		}
	}
}
@end







