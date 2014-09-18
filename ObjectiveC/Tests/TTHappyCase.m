//
//  TTHappyCase.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "TTHelperFunctions.h"
#import "TTHappyCase.h"
#import "EonilSQLite3.h"


















@implementation TTHappyCase

- (id)init
{
    self = [super init];
    if (self) {
        
		TTRemoveTestDatabaseFile();
    }
    return self;
}
- (void)dealloc
{
	TTRemoveTestDatabaseFile();
}






inline
static
EESQLiteDatabase*
TTCreateDatabaseForGenericTest()
{
//	return	[EESQLiteDatabase temporaryDatabaseInMemory];
	
	TTRemoveTestDatabaseFile();
	[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:TTPathToTestDatabase() error:NULL];
	return	[EESQLiteDatabase persistentDatabaseOnDiskAtPath:TTPathToTestDatabase()];
}












- (void)testCreatingTemporaryDatabaseInMemory
{
	EESQLiteDatabase*	db	=	[EESQLiteDatabase temporaryDatabaseInMemory];
	EETempTestMacroAssertNotNil(db, @"`db` must be instance of in-memory database.");
}
- (void)testCreatingTemporaryDatabaseOnDisk
{
	EESQLiteDatabase*	db	=	[EESQLiteDatabase temporaryDatabaseOnDisk];
	EETempTestMacroAssertNotNil(db, @"`db` must be instance of in-memory database.");
}
- (void)testCreatingPersistentDatabaseAtTestingPath
{
	TTRemoveTestDatabaseFile();
	
	NSError*				err		=	nil;
	BOOL					result	=	[EESQLiteDatabase createEmptyPersistentDatabaseOnDiskAtPath:TTPathToTestDatabase() error:&err];
	
	NSLog(@"error = %@", err);
	EETempTestMacroAssertNil(err, @"Should be no error.");
	EETempTestMacroAssertTrue(result, @"The database file must be created.");
	
	EESQLiteDatabase*		db		=	[[EESQLiteDatabase alloc] initAsPersistentDatabaseOnDiskAtPath:TTPathToTestDatabase() error:&err];
	
	NSLog(@"error = %@", err);
	EETempTestMacroAssertNil(err, @"Should be no error.");
	EETempTestMacroAssertNotNil(db, @"Must be an instance to persistent database.");

	TTRemoveTestDatabaseFile();
}
- (void)testMakingMultipleStatements
{
	EESQLiteDatabase*		db		=	TTCreateDatabaseForGenericTest();
	
	NSError*				err		=	nil;
	NSArray*				stmts	=	[db statementsByParsingSQL:@"CREATE TABLE Table1 (column1 INTEGER); CREATE TABLE Table2 (column2 INTEGER);" error:&err];
	
	NSLog(@"stmts = %@", stmts);
	NSLog(@"error = %@", err);
	EETempTestMacroAssertNil(err, @"Should be no error.");
	EETempTestMacroAssertNotNil(stmts, @"Must return array of statements.");
}
- (void)testExecuteMultipleStatements
{
	EESQLiteDatabase*		db		=	TTCreateDatabaseForGenericTest();
	
	NSError*				err		=	nil;
	NSArray*				stmts	=	[db statementsByParsingSQL:@"CREATE TABLE Table1 (column1 INTEGER);" error:&err];
	
	NSLog(@"stmts = %@", stmts);
	NSLog(@"error = %@", err);
	EETempTestMacroAssertNil(err, @"Should be no error.");
	EETempTestMacroAssertNotNil(stmts, @"Must return array of statements.");
}




- (void)testCreatingAndDroppingTables
{
	EESQLiteDatabase*		db		=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	[db addTableWithName:@"Table1" withColumnNames:[NSArray arrayWithObjects:@"column1", nil]];
	[db addTableWithName:@"Table2" withColumnNames:[NSArray arrayWithObjects:@"column2", nil]];
	[db addTableWithName:@"Table3" withColumnNames:[NSArray arrayWithObjects:@"column3", nil]];
	[db addTableWithName:@"Table4" withColumnNames:[NSArray arrayWithObjects:@"column4", nil] rowIDAliasColumnName:@"column4"];
	
	NSArray*	names1	=	[NSArray arrayWithObjects:@"Table1", @"Table2", @"Table3", @"Table4", nil];
	NSArray*	names2	=	[db allTableNames];
	
	EETempTestMacroAssertTrue([names1 isEqual:names2], @"The table names should be matched.");
	
	[db removeTableWithName:@"Table1"];
	[db removeTableWithName:@"Table2"];
	[db removeTableWithName:@"Table3"];
	[db removeTableWithName:@"Table4"];
	
	NSArray*	names3	=	[db allTableNames];
	
	EETempTestMacroAssertTrue([names3 count] == 0, @"There should be no table now.");
}
- (void)testCreatingAndDroppingTableWithMultipleColumns
{
	EESQLiteDatabase*		db		=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");

	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];

	[db addTableWithName:@"Table1" withColumnNames:colnms rowIDAliasColumnName:@"column5"];
	
	NSArray*	names1	=	[NSArray arrayWithObjects:@"Table1", nil];
	NSArray*	names2	=	[db allTableNames];
	
	EETempTestMacroAssertTrue([names1 isEqual:names2], @"The table names should be matched.");
	
	[db removeTableWithName:@"Table1"];
	
	NSArray*	names3	=	[db allTableNames];
	
	EETempTestMacroAssertTrue([names3 count] == 0, @"There should be no table now.");
}
- (void)testTableInfo
{
	EESQLiteDatabase*		db		=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	[db addTableWithName:@"Table1" withColumnNames:colnms];
	
	NSSet*	names1	=	[NSSet setWithArray:[db allColumnNamesOfTable:@"Table1"]];
	NSSet*	names2	=	[NSSet setWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	EETempTestMacroAssertTrue([names1 isEqual:names2], @"Column names must be matched.");
}
- (void)testInsertIntoTable
{
	EESQLiteDatabase*		db		=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	[db addTableWithName:@"Table1" withColumnNames:colnms];
	
	
	const char		ddd[8]	=	{ 4,0,4,0,4,0,4,0 };
	NSDictionary*	dict1	=	[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithLongLong:1111], @"column1",
								 [NSNumber numberWithDouble:22.2222], @"column2",
								 @"#3, this is third value.", @"column3",
								 [NSData dataWithBytes:(const void*)ddd length:8], @"column4",
								 nil];

	TTAssertNoException(^
						{
							[db insertDictionaryValue:dict1 intoTable:@"Table1"];
						});

	@autoreleasepool
	{
		EESQLiteStatement*	stmt	=	[[db statementsByParsingSQL:@"SELECT * FROM 'Table1'"] lastObject];
		[stmt step];
		
		NSDictionary*		dict2	=	[stmt dictionaryValue];
		
		NSLog(@"dict1 = %@", dict1);
		NSLog(@"dict2 = %@", dict2);
		EETempTestMacroAssertTrue([dict2 isEqual:dict1], @"Inserted value must be equal with original.");
		
		BOOL	isDoubleNumber	=	0 == strncmp([((NSNumber*)[dict2 objectForKey:@"column2"]) objCType], @encode(double), 1);
		EETempTestMacroAssertTrue(isDoubleNumber, @"2nd field must be double type.");
	}
}
- (void)testInsertIntoTableRandomValues
{
	EESQLiteDatabase*		db		=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
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
	
	TTAssertNoException(^{
	[db insertArrayOfDictionaryValues:srclist intoTable:@"Table1"];
	});
	
	NSArray*			newlist	=	[db arrayOfRowsByExecutingSQL:@"SELECT * FROM 'Table1'"];
	
//	NSLog(@"srclist = %@", srclist);
//	NSLog(@"newlist = %@", newlist);
	EETempTestMacroAssertTrue([srclist isEqual:newlist], @"Inserted value must be equal with original.");
}

- (void)testUpdateTablewithSingleValue
{
	EESQLiteDatabase*		db		=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	NSArray*		colnms	=	[NSArray arrayWithObjects:@"column1", @"column2", @"column3", @"column4", nil];
	
	[db addTableWithName:@"Table1" withColumnNames:colnms];
	
	
	const char		ddd[8]	=	{ 4,0,4,0,4,0,4,0 };
	NSDictionary*	dict1	=	[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithLongLong:1111], @"column1",
								 [NSNumber numberWithDouble:22.2222], @"column2",
								 @"#3, this is third value.", @"column3",
								 [NSData dataWithBytes:(const void*)ddd length:8], @"column4",
								 nil];
	
	TTAssertNoException(^{
		[db insertDictionaryValue:dict1 intoTable:@"Table1"];
	});
	
	@autoreleasepool
	{
		EESQLiteStatement*	stmt	=	[[db statementsByParsingSQL:@"SELECT * FROM 'Table1'"] lastObject];
		[stmt step];
		
		NSDictionary*		dict2	=	[stmt dictionaryValue];
		NSLog(@"dict1 = %@", dict1);
		NSLog(@"dict2 = %@", dict2);
		EETempTestMacroAssertTrue([dict2 isEqual:dict1], @"Inserted value must be equal with original.");
	}
	
}


- (void)testUtilityFeatures
{
	EETempTestMacroAssertTrue([EESQLiteDatabase isValidIdentifierString:@"_adw1"], @"");
	EETempTestMacroAssertTrue([EESQLiteDatabase isValidIdentifierString:@"_a_dw1"], @"");
	EETempTestMacroAssertTrue([EESQLiteDatabase isValidIdentifierString:@"adw1"], @"");
	EETempTestMacroAssertTrue([EESQLiteDatabase isValidIdentifierString:@"_a.dw1"], @"");
	EETempTestMacroAssertTrue([EESQLiteDatabase isValidIdentifierString:@"1_a.dw1"], @"");
	EETempTestMacroAssertTrue([EESQLiteDatabase isValidIdentifierString:@"a a"], @"");
	EETempTestMacroAssertTrue([EESQLiteDatabase isValidIdentifierString:@"a++a"], @"");
	EETempTestMacroAssertFalse([EESQLiteDatabase isValidIdentifierString:@"'aa'"], @"");
 	EETempTestMacroAssertFalse([EESQLiteDatabase isValidIdentifierString:@"[aa]"], @"");
}

- (void)testSimpleSelectQueries
{
	EESQLiteDatabase*	db	=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	[db addTableWithName:@"table1" withColumnNames:[NSArray arrayWithObjects:@"column1", @"column2", @"column3", nil]];
	
	NSDictionary*	sampleValue1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R1a", @"column1", @"R1b", @"column2", @"R1c", @"column3", nil];
	NSDictionary*	sampleValue2	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R2a", @"column1", @"R2b", @"column2", @"R2c", @"column3", nil];
	NSDictionary*	sampleValue3	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R3a", @"column1", @"R3b", @"column2", @"R3c", @"column3", nil];
	EESQLiteRowID	rowid1			=	[db insertDictionaryValue:sampleValue1 intoTable:@"table1"];
	EESQLiteRowID	rowid2			=	[db insertDictionaryValue:sampleValue2 intoTable:@"table1"];
	EESQLiteRowID	rowid3			=	[db insertDictionaryValue:sampleValue3 intoTable:@"table1"];
	
	{
		BOOL		hasit			=	[db containsRawID:rowid2 inTable:@"table1"];
		EETempTestMacroAssertTrue(hasit, @"");
	}
	
	{
		BOOL		hasit			=	[db containsRawID:-1 inTable:@"table1"];		//	SQLite3 won't make negative ROWID automatically.
		EETempTestMacroAssertTrue(!hasit, @"");
	}
	
	{
		NSArray*	result			=	[db arrayOfAllRowsInTable:@"table1"];
		NSSet*		resultset		=	[NSSet setWithArray:result];
		NSSet*		allsamples		=	[NSSet setWithObjects:sampleValue1, sampleValue2, sampleValue3, nil];
		
		EETempTestMacroAssertEqualObjects(resultset, allsamples, @"All sample values must be equal.");
	}
	
	{
		NSMutableArray*		result	=	[NSMutableArray array];
		[db enumerateAllRowsInTable:@"table1" block:^(NSDictionary *row, BOOL *stop) {
			[result addObject:row];
		}];
		NSSet*		resultset		=	[NSSet setWithArray:result];
		NSSet*		allsamples		=	[NSSet setWithObjects:sampleValue1, sampleValue2, sampleValue3, nil];
		
		EETempTestMacroAssertEqualObjects(resultset, allsamples, @"All sample values must be equal.");
	}
	
	{
		NSMutableArray*		result	=	[NSMutableArray array];
		[db enumerateRowsHasValue:@"R2a" atColumne:@"column1" inTable:@"table1" limitCount:2 usingBlock:^(NSDictionary *row, BOOL *stop)
		 {
			 [result addObject:row];
		 }];
		NSSet*		resultset		=	[NSSet setWithArray:result];
		NSSet*		allsamples		=	[NSSet setWithObjects:sampleValue2, nil];
		
		EETempTestMacroAssertEqualObjects(resultset, allsamples, @"All sample values must be equal.");
	}
	{
		NSMutableArray*		result	=	[NSMutableArray array];
		[db enumerateRowsHasValue:@"R2a" atColumne:@"column1" inTable:@"table1" limitCount:0 usingBlock:^(NSDictionary *row, BOOL *stop)
		 {
			 [result addObject:row];
		 }];
		NSSet*		resultset		=	[NSSet setWithArray:result];
		NSSet*		allsamples		=	[NSSet setWithObjects:nil];
		
		EETempTestMacroAssertEqualObjects(resultset, allsamples, @"All sample values must be equal.");
	}
	
	{
		NSDictionary*	result1			=	[db dictionaryFromRowHasID:rowid1 inTable:@"table1"];
		NSDictionary*	result2			=	[db dictionaryFromRowHasID:rowid2 inTable:@"table1"];
		NSDictionary*	result3			=	[db dictionaryFromRowHasID:rowid3 inTable:@"table1"];
		
		EETempTestMacroAssertTrue([[result1 valueForKey:@"column1"] isEqual:@"R1a"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result1 valueForKey:@"column2"] isEqual:@"R1b"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result1 valueForKey:@"column3"] isEqual:@"R1c"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result2 valueForKey:@"column1"] isEqual:@"R2a"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result2 valueForKey:@"column2"] isEqual:@"R2b"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result2 valueForKey:@"column3"] isEqual:@"R2c"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result3 valueForKey:@"column1"] isEqual:@"R3a"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result3 valueForKey:@"column2"] isEqual:@"R3b"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result3 valueForKey:@"column3"] isEqual:@"R3c"], @"Sample value state should match.");
	}
	
	{
		NSDictionary*	result1			=	[db dictionaryFromRowHasValue:@"R1a" atColumne:@"column1" inTable:@"table1"];
		NSDictionary*	result2			=	[db dictionaryFromRowHasValue:@"R2b" atColumne:@"column2" inTable:@"table1"];
		NSDictionary*	result3			=	[db dictionaryFromRowHasValue:@"R3c" atColumne:@"column3" inTable:@"table1"];
		
		EETempTestMacroAssertTrue([[result1 valueForKey:@"column1"] isEqual:@"R1a"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result1 valueForKey:@"column2"] isEqual:@"R1b"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result1 valueForKey:@"column3"] isEqual:@"R1c"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result2 valueForKey:@"column1"] isEqual:@"R2a"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result2 valueForKey:@"column2"] isEqual:@"R2b"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result2 valueForKey:@"column3"] isEqual:@"R2c"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result3 valueForKey:@"column1"] isEqual:@"R3a"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result3 valueForKey:@"column2"] isEqual:@"R3b"], @"Sample value state should match.");
		EETempTestMacroAssertTrue([[result3 valueForKey:@"column3"] isEqual:@"R3c"], @"Sample value state should match.");
	}
	
	{
		long long		rowcount		=	[db countOfAllRowsInTable:@"table1"];
		EETempTestMacroAssertTrue(rowcount == 3, @"Count of all rows must be 3.");
	}
}


- (void)testSimpleDeleteQuery1
{
	EESQLiteDatabase*	db	=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	[db addTableWithName:@"table1" withColumnNames:[NSArray arrayWithObjects:@"column1", @"column2", @"column3", nil]];
	
	NSDictionary*	sampleValue1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R1a", @"column1", @"R1b", @"column2", @"R1c", @"column3", nil];
	NSDictionary*	sampleValue2	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R2a", @"column1", @"R2b", @"column2", @"R2c", @"column3", nil];
	NSDictionary*	sampleValue3	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R3a", @"column1", @"R3b", @"column2", @"R3c", @"column3", nil];
	EESQLiteRowID	rowid1			=	[db insertDictionaryValue:sampleValue1 intoTable:@"table1"];
	EESQLiteRowID	rowid2			=	[db insertDictionaryValue:sampleValue2 intoTable:@"table1"];
	EESQLiteRowID	rowid3			=	[db insertDictionaryValue:sampleValue3 intoTable:@"table1"];
	
	{
		@try
		{
			[db deleteRowHasID:rowid2 fromTable:@"table1"];
		}
		@catch (NSException* exc)
		{
			EETempTestMacroAssertNil(exc, [exc description]);
		}
		
		long long		rowcount		=	[db countOfAllRowsInTable:@"table1"];
		EETempTestMacroAssertTrue(rowcount == 2, @"Count of all rows must be 2 after delete one row.");	
		
		id				deletedvalue	=	[db dictionaryFromRowHasID:rowid2 inTable:@"table1"];
		EETempTestMacroAssertNil(deletedvalue, @"Deleted value must be returned as `nil`.");
		
		id				v1			=	[db dictionaryFromRowHasID:rowid1 inTable:@"table1"];
		id				v3			=	[db dictionaryFromRowHasID:rowid3 inTable:@"table1"];
		
		EETempTestMacroAssertEqualObjects(v1, sampleValue1, @"Value #1 must be alive and equal with sample.");
		EETempTestMacroAssertEqualObjects(v3, sampleValue3, @"Value #2 must be alive and equal with sample.");
	}
}

- (void)testSimpleDeleteQuery2
{
	EESQLiteDatabase*	db	=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	[db addTableWithName:@"table1" withColumnNames:[NSArray arrayWithObjects:@"column1", @"column2", @"column3", nil]];
	
	NSDictionary*	sampleValue1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R1a", @"column1", @"R1b", @"column2", @"R1c", @"column3", nil];
	NSDictionary*	sampleValue2	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R2a", @"column1", @"R2b", @"column2", @"R2c", @"column3", nil];
	NSDictionary*	sampleValue3	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R3a", @"column1", @"R3b", @"column2", @"R3c", @"column3", nil];
	
	EESQLiteRowID	rowid1			=	[db insertDictionaryValue:sampleValue1 intoTable:@"table1"];
	EESQLiteRowID	rowid2			=	[db insertDictionaryValue:sampleValue2 intoTable:@"table1"];
	EESQLiteRowID	rowid3			=	[db insertDictionaryValue:sampleValue3 intoTable:@"table1"];
	{
		@try
		{
			[db deleteAllRowsFromTable:@"table1"];
		}
		@catch (NSException* exc)
		{
			EETempTestMacroAssertNil(exc, [exc description]);
		}
		
		long long		rowcount		=	[db countOfAllRowsInTable:@"table1"];
		EETempTestMacroAssertTrue(rowcount == 0, @"Count of all rows must be 0 after delete all rows.");	
		
		EETempTestMacroAssertNil([db dictionaryFromRowHasID:rowid1 inTable:@"table1"], @"Any row must be nil now.");
		EETempTestMacroAssertNil([db dictionaryFromRowHasID:rowid2 inTable:@"table1"], @"Any row must be nil now.");
		EETempTestMacroAssertNil([db dictionaryFromRowHasID:rowid3 inTable:@"table1"], @"Any row must be nil now.");
	}
}
- (void)testSimpleUpdateQuery1
{
	EESQLiteDatabase*	db	=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	[db addTableWithName:@"table1" withColumnNames:[NSArray arrayWithObjects:@"column1", @"column2", @"column3", nil]];
	
	NSDictionary*	sampleValue1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R1a", @"column1", @"R1b", @"column2", @"R1c", @"column3", nil];
	NSDictionary*	sampleValue2	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R2a", @"column1", @"R2b", @"column2", @"R2c", @"column3", nil];
	
	EESQLiteRowID	rowid1			=	[db insertDictionaryValue:sampleValue1 intoTable:@"table1"];
	{
		TTAssertNoException(^{
			[db updateRowHasID:rowid1 inTable:@"table1" withDictionary:sampleValue2];
		});
		
		id		rowValue1	=	[db dictionaryFromRowHasID:rowid1 inTable:@"table1"];
		
		EETempTestMacroAssertEqualObjects(rowValue1, sampleValue2, @"");
	}
}
- (void)testSimpleUpdateQuery2
{
	EESQLiteDatabase*	db	=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	[db addTableWithName:@"table1" withColumnNames:[NSArray arrayWithObjects:@"column1", @"column2", @"column3", nil]];
	
	NSDictionary*	sampleValue1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R1a", @"column1", @"R1b", @"column2", @"R1c", @"column3", nil];
	NSDictionary*	sampleValue2	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R2a", @"column1", @"R2b", @"column2", [NSNull null], @"column3", nil];
	NSDictionary*	sampleValue3	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R2a", @"column1", @"R2b", @"column2", nil];
	
	EESQLiteRowID	rowid1			=	[db insertDictionaryValue:sampleValue1 intoTable:@"table1"];
	{
		TTAssertNoException(^{
			[db updateRowHasValue:@(rowid1) atColumn:@"_ROWID_" inTable:@"table1" withDictionary:sampleValue2 replacingValueAsNull:[NSNull null]];
		});
		
		id		rowValue1	=	[db dictionaryFromRowHasID:rowid1 inTable:@"table1"];
		
		EETempTestMacroAssertEqualObjects(rowValue1, sampleValue3, @"");
	}
}
- (void)testSimpleUpdateQuery3
{
	EESQLiteDatabase*	db	=	TTCreateDatabaseForGenericTest();
	EETempTestMacroAssertNotNil(db, @"");
	
	[db addTableWithName:@"table1" withColumnNames:[NSArray arrayWithObjects:@"column1", @"column2", @"column3", nil]];
	
	NSDictionary*	sampleValue1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R1a", @"column1", @"R1b", @"column2", @"R1c", @"column3", nil];
	NSDictionary*	sampleValue2	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R2a", @"column1", @"R2b", @"column2", @"R2c", @"column3", nil];
	NSDictionary*	sampleValue3	=	[NSDictionary dictionaryWithObjectsAndKeys:@"R2a", @"column1", @"R2b", @"column2", nil];
	
	EESQLiteRowID	rowid1			=	[db insertDictionaryValue:sampleValue1 intoTable:@"table1"];
	{
		TTAssertNoException(^{
			[db updateRowHasValue:@(rowid1) atColumn:@"_ROWID_" inTable:@"table1" withDictionary:sampleValue2 replacingValueAsNull:@"R2c"];
		});
		
		id		rowValue1	=	[db dictionaryFromRowHasID:rowid1 inTable:@"table1"];
		
		EETempTestMacroAssertEqualObjects(rowValue1, sampleValue3, @"");
	}
}








- (void)testTransactionCommit
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
	
	NSDictionary*		state1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"#1", @"content", nil];
	[db updateRowHasID:12 inTable:@"table1" withDictionary:state1];		
	EETempTestMacroAssertTrue(checkSampleIsValue(@"#1"), @"After update, it should become `#1`.");
	
	[db performTransactionUsingBlock:^
	{
		NSDictionary*		state1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"#2", @"content", nil];
		[db updateRowHasID:12 inTable:@"table1" withDictionary:state1];
		EETempTestMacroAssertTrue(checkSampleIsValue(@"#2"), @"After update, it should become `#2`.");
		
		//	COMMIT.
	}];
	
	EETempTestMacroAssertTrue(checkSampleIsValue(@"#2"), @"After commit, it should be back to `#2`.");
}
- (void)testTransactionRollback
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
	
	NSDictionary*		state1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"#1", @"content", nil];
	[db updateRowHasID:12 inTable:@"table1" withDictionary:state1];		
	EETempTestMacroAssertTrue(checkSampleIsValue(@"#1"), @"After update, it should become `#1`.");
	
	@try
	{
		[db performTransactionUsingBlock:^
		{
			NSDictionary*		state1	=	[NSDictionary dictionaryWithObjectsAndKeys:@"#2", @"content", nil];
			[db updateRowHasID:12 inTable:@"table1" withDictionary:state1];
			EETempTestMacroAssertTrue(checkSampleIsValue(@"#2"), @"After update, it should become `#2`.");
		
			@throw	[NSException exceptionWithName:@"example" reason:@"example" userInfo:nil];	//	ROLLBACK.
		}];
	}
	@catch (NSException *exception)
	{
	}
	
	EETempTestMacroAssertTrue(checkSampleIsValue(@"#1"), @"After rollback, it should be back to `#1`.");
}



- (void)testCheckIntegrity
{
	NSError*	err1	=	nil;
	EESQLiteDatabase*	db	=	[[EESQLiteDatabase alloc] initAsTemporaryDatabaseInMemoryWithError:&err1];
	
	EETempTestMacroAssertNil(err1, @"");
		
	BOOL	ok1		=	[db checkIntegrity];
	
	EETempTestMacroAssertTrue(ok1, @"");
}




@end





















;