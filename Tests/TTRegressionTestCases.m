//
//  TTRegressionTestCases.m
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 12/21/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EonilSQLite.h"
#import "TTRegressionTestCases.h"

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
	NSString*	path	=	[@"./osm.sqlite" stringByExpandingTildeInPath];
	
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
		NSLog(@"created database schema = %@", self->DBHolder.allSchema);
		NSLog(@"created database tables = %@", self->DBHolder.allTableNames);
	}
}



- (void)test022_insertIntoWithBadTableName
{
	@autoreleasepool
	{
		[[NSFileManager defaultManager] removeItemAtPath:@"./t.db" error:nil];
		[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:@"./t.db"];
		EESQLiteDatabase*	DB	=	[EESQLiteDatabase persistentDatabaseOnDiskAtPath:@"./t.db" ];
		[DB addTableWithName:@"t" withColumnNames:@[@"c1"] rowIDAliasColumnName:@"c1"];
		
		NSError*	err	=	nil;
		[DB insertDictionaryValue:@{} intoTable:@"ttt" error:&err];
		EETempTestMacroAssertNotNil(err, @"It should raise an error.");
	}
}
- (void)test022_insertIntoWithTableNameWithSpecialCharacter
{
	@autoreleasepool
	{
		[[NSFileManager defaultManager] removeItemAtPath:@"./t.db" error:nil];
		[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:@"./t.db"];
		EESQLiteDatabase*	DB	=	[EESQLiteDatabase persistentDatabaseOnDiskAtPath:@"./t.db" ];
		[DB addTableWithName:@"t+t" withColumnNames:@[@"c1"] rowIDAliasColumnName:@"c1"];
		
		NSError*	err	=	nil;
		[DB insertDictionaryValue:@{} intoTable:@"t+t" error:&err];
		EETempTestMacroAssertNil(err, @"Should be no error.");
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


















