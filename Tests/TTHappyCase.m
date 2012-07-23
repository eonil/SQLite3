//
//  TTHappyCase.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "TTHappyCase.h"
#import "EonilSQLite.h"


@implementation TTHappyCase
- (void)setUp
{
	[super setUp];
	
	TTRemoveTestDatabaseFile();
}
- (void)tearDown
{
	[super tearDown];
	
	TTRemoveTestDatabaseFile();
}



















- (void)testCreatingTemporaryDatabaseInMemory
{
	EESQLiteDatabase*	db	=	[EESQLiteDatabase temporaryDatabaseInMemory];
	STAssertNotNil(db, @"`db` must be instance of in-memory database.");
}
- (void)testCreatingTemporaryDatabaseOnDisk
{
	EESQLiteDatabase*	db	=	[EESQLiteDatabase temporaryDatabaseOnDisk];
	STAssertNotNil(db, @"`db` must be instance of in-memory database.");
}
- (void)testCreatingPersistentDatabaseAtTestingPath
{
	TTRemoveTestDatabaseFile();
	
	NSError*				err		=	nil;
	BOOL					result	=	[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:TTPathToTestDatabase() error:&err];
	
	NSLog(@"error = %@", err);
	STAssertNil(err, @"Should be no error.");
	STAssertTrue(result, @"The database file must be created.");
	
	EESQLiteDatabase*		db		=	[[EESQLiteDatabase alloc] initAsPersistentDatabaseOnDiskAtPath:TTPathToTestDatabase() error:&err];
	
	NSLog(@"error = %@", err);
	STAssertNil(err, @"Should be no error.");
	STAssertNotNil(db, @"Must be an instance to persistent database.");

	TTRemoveTestDatabaseFile();
}
- (void)testMakingMultipleStatements
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	
	NSError*				err		=	nil;
	NSArray*				stmts	=	[db statementsByParsingSQL:@"CREATE TABLE Table1 (column1 INTEGER); CREATE TABLE Table2 (column2 INTEGER);" error:&err];
	
	NSLog(@"stmts = %@", stmts);
	NSLog(@"error = %@", err);
	STAssertNil(err, @"Should be no error.");
	STAssertNotNil(stmts, @"Must return array of statements.");
}
- (void)testExecuteMultipleStatements
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	
	NSError*				err		=	nil;
	NSArray*				stmts	=	[db statementsByParsingSQL:@"CREATE TABLE Table1 (column1 INTEGER);" error:&err];
	
	NSLog(@"stmts = %@", stmts);
	NSLog(@"error = %@", err);
	STAssertNil(err, @"Should be no error.");
	STAssertNotNil(stmts, @"Must return array of statements.");
}




- (void)testCreatingAndDroppingTables
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	STAssertNotNil(db, @"");
	
	[db addTableWithName:@"Table1" withColumnNames:[NSArray arrayWithObjects:@"column1", nil]];
	[db addTableWithName:@"Table2" withColumnNames:[NSArray arrayWithObjects:@"column2", nil]];
	[db addTableWithName:@"Table3" withColumnNames:[NSArray arrayWithObjects:@"column3", nil]];
	[db addTableWithName:@"Table4" withColumnNames:[NSArray arrayWithObjects:@"column4", nil] rowIDAliasColumnName:@"column4"];
	
	NSArray*	names1	=	[NSArray arrayWithObjects:@"Table1", @"Table2", @"Table3", @"Table4", nil];
	NSArray*	names2	=	[db allTableNames];
	
	STAssertTrue([names1 isEqual:names2], @"The table names should be matched.");
	
	[db removeTableWithName:@"Table1"];
	[db removeTableWithName:@"Table2"];
	[db removeTableWithName:@"Table3"];
	[db removeTableWithName:@"Table4"];
	
	NSArray*	names3	=	[db allTableNames];
	
	STAssertTrue([names3 count] == 0, @"There should be no table now.");
}
- (void)testCreatingAndDroppingTableWithMultipleColumns
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	STAssertNotNil(db, @"");

	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];

	[db addTableWithName:@"Table1" withColumnNames:colnms rowIDAliasColumnName:@"column5"];
	
	NSArray*	names1	=	[NSArray arrayWithObjects:@"Table1", nil];
	NSArray*	names2	=	[db allTableNames];
	
	STAssertTrue([names1 isEqual:names2], @"The table names should be matched.");
	
	[db removeTableWithName:@"Table1"];
	
	NSArray*	names3	=	[db allTableNames];
	
	STAssertTrue([names3 count] == 0, @"There should be no table now.");
}
- (void)testTableInfo
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	STAssertNotNil(db, @"");
	
	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	[db addTableWithName:@"Table1" withColumnNames:colnms];
	
	NSSet*	names1	=	[NSSet setWithArray:[db allColumnNamesOfTable:@"Table1"]];
	NSSet*	names2	=	[NSSet setWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	STAssertTrue([names1 isEqual:names2], @"Column names must be matched.");
}
- (void)testInsertIntoTable
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	STAssertNotNil(db, @"");
	
	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	[db addTableWithName:@"Table1" withColumnNames:colnms];
	
	
	const char		ddd[8]	=	{ 4,0,4,0,4,0,4,0 };
	NSDictionary*	dict1	=	[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithLongLong:1111], @"column1",
								 [NSNumber numberWithDouble:22.2222], @"column2",
								 @"#3, this is third value.", @"column3",
								 [NSData dataWithBytes:(const void*)ddd length:8], @"column4",
								 nil];

	NSError*	err;
	[db insertDictionaryValue:dict1 intoTable:@"Table1" error:&err];
	NSLog(@"error = %@", err);
	STAssertNil(err, @"Should be no error.");

	EESQLiteStatement*	stmt	=	[[db statementsByParsingSQL:@"SELECT * FROM 'Table1'"] lastObject];
	[stmt step];

	NSDictionary*		dict2	=	[stmt dictionaryValue];
	
	NSLog(@"dict1 = %@", dict1);
	NSLog(@"dict2 = %@", dict2);
	STAssertTrue([dict2 isEqual:dict1], @"Inserted value must be equal with original.");
	
	BOOL	isDoubleNumber	=	0 == strncmp([((NSNumber*)[dict2 objectForKey:@"column2"]) objCType], @encode(double), 1);	
	STAssertTrue(isDoubleNumber, @"2nd field must be double type.");
}
- (void)testInsertIntoTableRandomValues
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	STAssertNotNil(db, @"");
	
	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	[db addTableWithName:@"Table1" withColumnNames:colnms];
	
	NSUInteger			len		=	128;
	NSMutableArray*		srclist	=	[NSMutableArray arrayWithCapacity:len];
	for (NSUInteger i = 0; i< len; i++)
	{
		NSDictionary*	dict1	=	[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithLongLong:rand()], @"column1",
									 [NSNumber numberWithDouble:rand()], @"column2",
									 [NSString stringWithFormat:@"Number = %d", rand()], @"column3",
									 [NSData dataWithBytes:(const void*)(char[]){ rand(), rand(), rand(), rand() } length:4], @"column4",
									 nil];

		[srclist addObject:dict1];
	}
	
	NSError*	err;
	[db insertArrayOfDictionaryValues:srclist intoTable:@"Table1" error:&err];
	NSLog(@"error = %@", err);
	STAssertNil(err, @"Should be no error.");
	
	NSArray*			newlist	=	[db arrayOfRowsByExecutingSQL:@"SELECT * FROM 'Table1'"];
	
//	NSLog(@"srclist = %@", srclist);
//	NSLog(@"newlist = %@", newlist);
	STAssertTrue([srclist isEqual:newlist], @"Inserted value must be equal with original.");
}

- (void)testUpdateTablewithSingleValue
{
	EESQLiteDatabase*		db		=	[EESQLiteDatabase temporaryDatabaseInMemory];
	STAssertNotNil(db, @"");
	
	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	[db addTableWithName:@"Table1" withColumnNames:colnms];
	
	
	const char		ddd[8]	=	{ 4,0,4,0,4,0,4,0 };
	NSDictionary*	dict1	=	[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithLongLong:1111], @"column1",
								 [NSNumber numberWithDouble:22.2222], @"column2",
								 @"#3, this is third value.", @"column3",
								 [NSData dataWithBytes:(const void*)ddd length:8], @"column4",
								 nil];
	
	NSError*	err;
	[db insertDictionaryValue:dict1 intoTable:@"Table1" error:&err];
	NSLog(@"error = %@", err);
	STAssertNil(err, @"Should be no error.");
	
	EESQLiteStatement*	stmt	=	[[db statementsByParsingSQL:@"SELECT * FROM 'Table1'"] lastObject];
	[stmt step];
	
	NSDictionary*		dict2	=	[stmt dictionaryValue];
	
	NSLog(@"dict1 = %@", dict1);
	NSLog(@"dict2 = %@", dict2);
	STAssertTrue([dict2 isEqual:dict1], @"Inserted value must be equal with original.");
}
- (void)testUtilityFeatures
{
	STAssertTrue([EESQLiteDatabase isValidIdentifierString:@"_adw1"], @"");
	STAssertTrue([EESQLiteDatabase isValidIdentifierString:@"_a_dw1"], @"");
	STAssertTrue([EESQLiteDatabase isValidIdentifierString:@"adw1"], @"");
	STAssertFalse([EESQLiteDatabase isValidIdentifierString:@"_a.dw1"], @"");
	STAssertFalse([EESQLiteDatabase isValidIdentifierString:@"1_a.dw1"], @"");
	STAssertFalse([EESQLiteDatabase isValidIdentifierString:@"a a"], @"");
	STAssertFalse([EESQLiteDatabase isValidIdentifierString:@"'aa'"], @"");
}

- (void)testSimpleQueries
{
	EESQLiteDatabase*	db	=	[EESQLiteDatabase temporaryDatabaseInMemory];
	STAssertNotNil(db, @"");
	
	[db addTableWithName:@"table1" withColumnNames:[NSArray arrayWithObjects:@"column1", @"column2", @"column3", nil]];
	
	NSDictionary*	sampleValue1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R1a", @"column1", @"R1b", @"column2", @"R1c", @"column3", nil];
	NSDictionary*	sampleValue2	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R2a", @"column1", @"R2b", @"column2", @"R2c", @"column3", nil];
	NSDictionary*	sampleValue3	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R3a", @"column1", @"R3b", @"column2", @"R3c", @"column3", nil];
	EESQLiteRowID	rowid1			=	[db insertDictionaryValue:sampleValue1 intoTable:@"table1" error:NULL];
	EESQLiteRowID	rowid2			=	[db insertDictionaryValue:sampleValue2 intoTable:@"table1" error:NULL];
	EESQLiteRowID	rowid3			=	[db insertDictionaryValue:sampleValue3 intoTable:@"table1" error:NULL];
	
	{
		NSDictionary*	result1			=	[db dictionaryFromRowHasID:rowid1 inTable:@"table1"];
		NSDictionary*	result2			=	[db dictionaryFromRowHasID:rowid2 inTable:@"table1"];
		NSDictionary*	result3			=	[db dictionaryFromRowHasID:rowid3 inTable:@"table1"];
		
		STAssertTrue([[result1 valueForKey:@"column1"] isEqual:@"R1a"], @"Sample value state should match.");
		STAssertTrue([[result1 valueForKey:@"column2"] isEqual:@"R1b"], @"Sample value state should match.");
		STAssertTrue([[result1 valueForKey:@"column3"] isEqual:@"R1c"], @"Sample value state should match.");
		STAssertTrue([[result2 valueForKey:@"column1"] isEqual:@"R2a"], @"Sample value state should match.");
		STAssertTrue([[result2 valueForKey:@"column2"] isEqual:@"R2b"], @"Sample value state should match.");
		STAssertTrue([[result2 valueForKey:@"column3"] isEqual:@"R2c"], @"Sample value state should match.");
		STAssertTrue([[result3 valueForKey:@"column1"] isEqual:@"R3a"], @"Sample value state should match.");
		STAssertTrue([[result3 valueForKey:@"column2"] isEqual:@"R3b"], @"Sample value state should match.");
		STAssertTrue([[result3 valueForKey:@"column3"] isEqual:@"R3c"], @"Sample value state should match.");
	}
	
	{
		NSDictionary*	result1			=	[db dictionaryFromRowHasValue:@"R1a" atColumne:@"column1" inTable:@"table1"];
		NSDictionary*	result2			=	[db dictionaryFromRowHasValue:@"R2b" atColumne:@"column2" inTable:@"table1"];
		NSDictionary*	result3			=	[db dictionaryFromRowHasValue:@"R3c" atColumne:@"column3" inTable:@"table1"];
		
		STAssertTrue([[result1 valueForKey:@"column1"] isEqual:@"R1a"], @"Sample value state should match.");
		STAssertTrue([[result1 valueForKey:@"column2"] isEqual:@"R1b"], @"Sample value state should match.");
		STAssertTrue([[result1 valueForKey:@"column3"] isEqual:@"R1c"], @"Sample value state should match.");
		STAssertTrue([[result2 valueForKey:@"column1"] isEqual:@"R2a"], @"Sample value state should match.");
		STAssertTrue([[result2 valueForKey:@"column2"] isEqual:@"R2b"], @"Sample value state should match.");
		STAssertTrue([[result2 valueForKey:@"column3"] isEqual:@"R2c"], @"Sample value state should match.");
		STAssertTrue([[result3 valueForKey:@"column1"] isEqual:@"R3a"], @"Sample value state should match.");
		STAssertTrue([[result3 valueForKey:@"column2"] isEqual:@"R3b"], @"Sample value state should match.");
		STAssertTrue([[result3 valueForKey:@"column3"] isEqual:@"R3c"], @"Sample value state should match.");
	}
	
	{
		long long		rowcount		=	[db countOfAllRowsInTable:@"table1"];
		STAssertTrue(rowcount == 3, @"Count of all rows must be 3.");
	}
}
@end





















;