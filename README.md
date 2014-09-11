Eonil's SQLite3 wrapper library
===============================
Hoon H., 2014/09/12 2014/06/24 2012/12/21 2012/10/04











`EonilSQLite` is an Objective-C library which wraps C-level SQLite3 database engine library.
This library provides these features.

-	Reducing complexity of using C level functions directly.
-	Offers simple and object-oriented data handling. (handling data using `NSValue`, `NSDictionary` and `NSArray`)










Getting Started
---------------

First, make a new database. We will use in-memory database for easy start up.

	EESQLiteDatabase*	db1	=	[EESQLiteDatabase temporaryDatabaseInMemory];
	
Create tables.

	[db1 addTableWithName:@"Table1" withColumnNames:@[@"col1", @"col2", @"col3"]];
	
insert some rows.

	NSDictionary*		row	=	@
	{
		@"col1"				:	@(56),
		@"col2"				:	@"pancake",
	};
	EESQLiteRowID	rowID	=	[db1 insertDictionaryValue:row intoTable:@"Table1"];

and, delete it.

	[db1 deleteRowHasID:rowID fromTable:@"Table1"];

Of course, you also can perform transaction.

	[db1 performTransactionUsingBlock:^
	{
		NSDictionary*		row	=	@
		{
			@"col1"				:	@(56),
			@"col2"				:	@"pancake",
		};
		EESQLiteRowID	rowID	=	[db1 insertDictionaryValue:row intoTable:@"Table1"];
		[db1 deleteRowHasID:rowID fromTable:@"Table1"];

		//	Will commit automatically after the block finished.
		//	Any exception will cause rollback.
	}];






See `MANUAL.md` file for more informations.
	
	
	
	
	

	
	
	
	
	
	















