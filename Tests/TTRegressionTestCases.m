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
	EESQLiteDatabase*	DB;
}

- (void)test020_creatingNewTable
{
	/*
	 Creating database was impossible due to logic bug.
	 I removed the bug by;
	
	 1.	Removed duplicated cleanup in desig. -init~ method. let -dealloc method to perform clearup.
	 2.	All statements used in -executeSQL method wrapped by @autoreleasepool block. Now they are deallocated before database object.
	 
	 */
	NSString*	path	=	[@"~/Temp/SubwayRoute/osm.sqlite" stringByExpandingTildeInPath];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSError*	err	=	nil;
		[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:path error:&err];
		EETempTestMacroAssertNil(err, @"Error while creating DB.");
		
	}
	
	
	@autoreleasepool
	{
		NSError*	err	=	nil;
		self->DB	=	[[EESQLiteDatabase alloc] initAsPersistentDatabaseOnDiskAtPath:path error:&err];
		EETempTestMacroAssertNil(err, @"Error while opening DB.");
		
		[self->DB addTableWithName:@"Node" withColumnNames:@[@"ID", @"timestamp", @"version", @"changeset", @"latitude", @"longitude"] rowIDAliasColumnName:@"ID"];
		[self->DB addTableWithName:@"Way" withColumnNames:@[@"ID", @"timestamp", @"version", @"changeset"] rowIDAliasColumnName:@"ID"];
		[self->DB addTableWithName:@"NodeTag" withColumnNames:@[@"ID", @"nodeID", @"key", @"value"] rowIDAliasColumnName:@"ID"];
		[self->DB addTableWithName:@"WayTag" withColumnNames:@[@"ID", @"wayID", @"key", @"value"] rowIDAliasColumnName:@"ID"];
		
		self->DB	=	nil;
	}
	
	@autoreleasepool
	{
		self->DB	=	[[EESQLiteDatabase alloc] initAsPersistentDatabaseOnDiskAtPath:path error:NULL];
		NSLog(@"created database schema = %@", self->DB.allSchema);
		NSLog(@"created database tables = %@", self->DB.allTableNames);
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


















