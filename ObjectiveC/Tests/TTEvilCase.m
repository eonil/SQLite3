//
//  TTEvilCase.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "TTEvilCase.h"
#import "EonilSQLite3.h"


@implementation TTEvilCase
{
	id	holderForTest;
}





- (void)testBadPathToDatabaseFile
{
	NSError*			err		=	nil;
	EESQLiteDatabase*	db		=	[[EESQLiteDatabase alloc] initAsPersistentDatabaseOnDiskAtPath:@"" error:&err];
	NSLog(@"error = %@", err);
	EETempTestMacroAssertNil(db, @"`db` must be nil when offer bad path.");
}
- (void)testInsertingNil
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	EETempTestMacroAssertNotNil(db, @"");
	
	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	[db addTableWithName:@"Table1" withColumnNames:colnms];
	
	@try
	{
		[db insertDictionaryValue:nil intoTable:@"Table1"];
	}
	@catch (NSException* exc)
	{
		NSLog(@"exception = %@", exc);
		EETempTestMacroAssertNil(exc, @"Should be no exception.");
	}
	
	NSArray*	list	=	[db arrayOfRowsByExecutingSQL:@"SELECT * FROM 'Table1'"];
	
//	EETempTestMacroAssertTrue([list count] == 0, @"The count of result must be 0. `INSERT` should be no-op.");
	EETempTestMacroAssertTrue([list count] == 1, @"The count of list must be 1.");
	EETempTestMacroAssertTrue([[list lastObject] count] == 0, @"The result row must be empty.");
}
- (void)testInsertingEmptyDictionary
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	EETempTestMacroAssertNotNil(db, @"");
	
	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	[db addTableWithName:@"Table1" withColumnNames:colnms];
	
	NSDictionary*	dict1		=	[NSDictionary dictionary];
	
	@try
	{
		[db insertDictionaryValue:dict1 intoTable:@"Table1"];
	}
	@catch (NSException* exc)
	{
		NSLog(@"exception = %@", exc);
		EETempTestMacroAssertNil(exc, @"Should be no exception.");
	}
	
	NSArray*		list		=	[db arrayOfRowsByExecutingSQL:@"SELECT * FROM 'Table1'"];
	NSDictionary*	dict2		=	[list lastObject];
	
	EETempTestMacroAssertTrue([list count] == 1, @"The count of list must be 1.");
	EETempTestMacroAssertTrue([dict2 count] == 0, @"The result row must be empty.");
}


//- (void)testLMemoryLeak
//{
//	for (NSUInteger i=0; i<100000; i++)
//	{
//		@autoreleasepool 
//		{
//			EESQLiteDatabase*	db	=	[[EESQLiteDatabase alloc] initWithDatabaseAtPath:TTPathToTestDatabase() error:NULL];
//			
//			if (i % 10000 == 0)
//			{
//				NSLog(@"db instance creation #%d, db = %@", i, db);
//			}
//		}
//	}
//}






- (void)testTransactionNesting
{	
	EESQLiteDatabase*	db	=	[EESQLiteDatabase temporaryDatabaseInMemory];
	NSDictionary*		row	=	[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithLongLong:12], @"ID",
								 nil];
	
	BOOL	(^checkSampleIsValue)(NSString*)=^(NSString* value)
	{
		id		current	=	[[db dictionaryFromRowHasID:12 inTable:@"table1"] valueForKey:@"content"];
		return	(BOOL)(current == value || [current isEqual:value]);
	};
	
	[db addTableWithName:@"table1" withColumnNames:[NSArray arrayWithObjects:@"ID", @"content", nil] rowIDAliasColumnName:@"ID"];
	[db insertDictionaryValue:row intoTable:@"table1"];
	EETempTestMacroAssertTrue(checkSampleIsValue(nil), @"At first, it should be `nil`.");
	
	[db performTransactionUsingBlock:^
	{
		 NSDictionary*		state1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"#1", @"content", nil];
		 [db updateRowHasID:12 inTable:@"table1" withDictionary:state1];		
		 EETempTestMacroAssertTrue(checkSampleIsValue(@"#1"), @"After update, it should be `#1`.");
		 
		 @try
		 {
			 [db performTransactionUsingBlock:^
			 {
				 @throw	[NSException exceptionWithName:@"TEST" reason:@"This is tester exception." userInfo:nil];
			 }];
		 }
		 @catch (NSException* ex)
		 {
			 EETempTestMacroAssertNotNil(ex, @"Must throw an exception calling nested transaction.");
		 }
		 
		 EETempTestMacroAssertTrue(checkSampleIsValue(@"#1"), @"After rollback, it should be back to `#1`.");
		 
		//	COMMIT at end.
	 }];
	
	EETempTestMacroAssertTrue(checkSampleIsValue(@"#1"), @"After commit, it should be remain as `#1`.");
}








- (void)test010_exceptionWhileTransaction
{
	EESQLiteDatabase*	db	=	[EESQLiteDatabase temporaryDatabaseInMemory];
	
	[db addTableWithName:@"T1" withColumnNames:@[@"C1"] rowIDAliasColumnName:@"C1"];
	
	[db insertDictionaryValue:@{ @"C1": @(5) } intoTable:@"T1"];
	
	NSUInteger	C	=	[db countOfAllRowsInTable:@"T1"];
	
	EETempTestMacroAssertTrue(C == 1, @"");
	
	@try
	{
		[db performTransactionUsingBlock:^
		{
			[db insertDictionaryValue:@{ @"C1": @(6) } intoTable:@"T1"];
			@throw	[NSException exceptionWithName:@"sample-exception" reason:@"" userInfo:nil];
		}];
	}
	@catch (NSException* exception)
	{
		NSLog ( @"the exceptionis = %@", exception);
	}
	@finally {
			
	}
	ASS (C == (2-1));	//	Last insert should be rollback.
}






@end











