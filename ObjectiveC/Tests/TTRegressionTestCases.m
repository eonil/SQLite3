//
//  TTRegressionTestCases.m
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 12/21/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EonilSQLite3.h"
#import "TTRegressionTestCases.h"


#define TEST_FILE		@"./EESQLITE3_LIBRARY_REGRESSION_TEST_FILE.sqlite"


@implementation TTRegressionTestCases
{
	EESQLiteDatabase*	DBHolder;
}

- (void)test020_creatingNewTable
{
	/*
	 Creating database was impossible due to logic bug.
	 I removed the bug by;
	
	 1.	Removed duplicated cleanup in desig. -init~ method. let -dealloc method to perform clearup.
	 2.	All statements used in -executeSQL method wrapped by @autoreleasepool block. Now they are deallocated before database object.
	 
	 */
	NSString*	path	=	[TEST_FILE stringByExpandingTildeInPath];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSError*	err	=	nil;
		[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:path error:&err];
		EETempTestMacroAssertNil(err, @"Error while creating DB.");
		
	}
	
	
	@autoreleasepool
	{
		NSError*	err	=	nil;
		self->DBHolder	=	[[EESQLiteDatabase alloc] initAsPersistentDatabaseOnDiskAtPath:path error:&err];
		EETempTestMacroAssertNil(err, @"Error while opening DB.");
		
		[self->DBHolder addTableWithName:@"Node" withColumnNames:@[@"ID", @"timestamp", @"version", @"changeset", @"latitude", @"longitude"] rowIDAliasColumnName:@"ID"];
		[self->DBHolder addTableWithName:@"Way" withColumnNames:@[@"ID", @"timestamp", @"version", @"changeset"] rowIDAliasColumnName:@"ID"];
		[self->DBHolder addTableWithName:@"NodeTag" withColumnNames:@[@"ID", @"nodeID", @"key", @"value"] rowIDAliasColumnName:@"ID"];
		[self->DBHolder addTableWithName:@"WayTag" withColumnNames:@[@"ID", @"wayID", @"key", @"value"] rowIDAliasColumnName:@"ID"];
		
		self->DBHolder	=	nil;
	}
	
	@autoreleasepool
	{
		self->DBHolder	=	[[EESQLiteDatabase alloc] initAsPersistentDatabaseOnDiskAtPath:path error:NULL];
		NSLog(@"created database schema = %@", self->DBHolder.allRawSchema);
		NSLog(@"created database tables = %@", self->DBHolder.allTableNames);
	}
}



- (void)test022_insertIntoWithBadTableName
{
	@autoreleasepool
	{
		[[NSFileManager defaultManager] removeItemAtPath:TEST_FILE error:nil];
		[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:TEST_FILE];
		EESQLiteDatabase*	DB	=	[EESQLiteDatabase persistentDatabaseOnDiskAtPath:TEST_FILE ];
		[DB addTableWithName:@"t" withColumnNames:@[@"c1"] rowIDAliasColumnName:@"c1"];
		
		
		NSException*	test_exc	=	nil;
		@try
		{
			[DB insertDictionaryValue:@{} intoTable:@"ttt"];
		}
		@catch (NSException* exc)
		{
			test_exc	=	exc;
		}
		EETempTestMacroAssertNotNil(test_exc, @"Should be an exception.");
	}
}
- (void)test022_insertIntoWithTableNameWithSpecialCharacter
{
	@autoreleasepool
	{
		[[NSFileManager defaultManager] removeItemAtPath:TEST_FILE error:nil];
		[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:TEST_FILE];
		EESQLiteDatabase*	DB	=	[EESQLiteDatabase persistentDatabaseOnDiskAtPath:TEST_FILE];
		[DB addTableWithName:@"t+t" withColumnNames:@[@"c1"] rowIDAliasColumnName:@"c1"];
		
		
		NSException*	test_exc	=	nil;
		@try
		{
			[DB insertDictionaryValue:@{} intoTable:@"t+t"];
		}
		@catch (NSException* exc)
		{
			test_exc	=	exc;
		}
		EETempTestMacroAssertNil(test_exc, @"Should be no exception.");
	}
}

- (void)test023_selectingWithTableNameWithSpecialLetters
{
	@autoreleasepool
	{
		EESQLiteDatabase*	DB	=	[EESQLiteDatabase temporaryDatabaseInMemory];
		[DB addTableWithName:@"t+t" withColumnNames:@[@"c1"] rowIDAliasColumnName:@"c1"];
		[DB insertDictionaryValue:@{} intoTable:@"t+t"];
		
		NSArray*	A	=	[DB arrayOfAllRowsInTable:@"t+t"];
		
		EETempTestMacroAssertNotNil(A, @"Should return some value.");
	}
}






//- (void)test022_creatingNewTable
//{
//	/*
//	 ISSUE:
//	 Currently, 
//
//	 */
//	NSString*	path	=	[@"~/Temp/SubwayRoute/osm.sqlite" stringByExpandingTildeInPath];
//	
//	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
//	{
//		NSError*	err	=	nil;
//		[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:path error:&err];
//		EETempTestMacroAssertNil(err, @"Error while creating DB.");
//		
//	}
//	
//	
//	@autoreleasepool
//	{
//		NSError*	err	=	nil;
//		self->DB	=	[[EESQLiteDatabase alloc] initAsPersistentDatabaseOnDiskAtPath:path error:&err];
//		EETempTestMacroAssertNil(err, @"Error while opening DB.");
//		
//		/*
//		 refID			Integer. PK and ID to the target object.
//		 completion		Boolean. If this is NO, the object and all related objects must be re-downlaoded.
//		 */
//		[self->DB addTableWithName:@"DataloadingStateForNode" withColumnNames:@[@"refID", @"completion"] rowIDAliasColumnName:@"refID"];
//		[self->DB addTableWithName:@"DataloadingStateForWay" withColumnNames:@[@"refID", @"completion"] rowIDAliasColumnName:@"refID"];
//
//		self->DB	=	nil;
//	}
//	
//	@autoreleasepool
//	{
//		self->DB	=	[[EESQLiteDatabase alloc] initAsPersistentDatabaseOnDiskAtPath:path error:NULL];
//		
//		NSDictionary*	dict	=	@
//		{
//			@"refID"			:	@(11223344),
//			@"completion"		:	@(NO),
//		};
//		
//		if (![DB executeTransactionBlock:^BOOL
//			  {
//				  NSError*	errD	=	nil;
//				  NSError*	errI	=	nil;
//				  [DB deleteRowHasID:11223344 fromTable:@"DataloadingStateForNode" error:&errD];
//				  [DB insertDictionaryValue:dict intoTable:@"DataloadingStateForNode" error:&errI];
//				  EETempTestMacroAssertNil(errD, @"Error while opening DB.");
//				  EETempTestMacroAssertNil(errI, @"Error while opening DB.");
//				  return	errD == nil && errI == nil;
//			  }])
//		{
//			printf("error");
//			abort();
//		}
//	}
//}


















@end


















