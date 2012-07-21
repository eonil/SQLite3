//
//  EESQLiteDatabase.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				<Foundation/Foundation.h>


#import				"EESQLiteRowIDList.h"









@interface			EESQLiteDatabase : NSObject

- (BOOL)			executeSQL:(NSString*)command;
- (BOOL)			executeSQL:(NSString*)command error:(NSError**)error;
- (NSArray*)		statementsByParsingSQL:(NSString*)command;
- (NSArray*)		statementsByParsingSQL:(NSString*)command error:(NSError**)error;

- (void)			beginTransaction;
- (void)			commitTransaction;
- (void)			rollbackTransaction;
- (void)			executeTransactionBlock:(BOOL(^)(void))transaction;		//	Trnsaction will be commited if the block returns YES, all otherwise will be rolled back.

/*!
 @abstract
 Creates a new in-memory database.
 The database will be erased when the connection being closed.
 */
- (id)				initAsTemporaryDatabaseInMemoryWithError:(NSError**)error;

/*!
 @abstract
 Open a new temporary database on temporary file.
 The database file will be deleted when the connecion being closed.
 */
- (id)				initAsTemporaryDatabaseOnDiskWithError:(NSError**)error;

/*!
 @abstract
 Open a database from the file.
 
 @param
 pathToDatabase
 Cannot starts with `:` character.
 If your file is starts with the character, prefix it with `./`.
 The file must be exist. If you want to create a new empty database, use `-createEmptyPersistentDatabaseOnDiskAtPath:` method.
 
 @result
 An object instance. `nil` for any error.
 */
- (id)				initAsPersistentDatabaseOnDiskAtPath:(NSString*)pathTodDatabase error:(NSError**)error;

+ (EESQLiteDatabase*)	temporaryDatabaseInMemory;
+ (EESQLiteDatabase*)	temporaryDatabaseOnDisk;
+ (EESQLiteDatabase*)	persistentDatabaseOnDiskAtPath:(NSString*)pathToDatabase;								//	This path cannot start with `:` character.
+ (BOOL)				createEmptyPersistentDatabaseOnDiskAtPath:(NSString *)path;								//	YES if creation succeeded. NO for all otherwise.
+ (BOOL)				createEmptyPersistentDatabaseOnDiskAtPath:(NSString *)path error:(NSError**)error;		//	YES if creation succeeded. NO for all otherwise.

@end









@interface			EESQLiteDatabase (Select)
- (NSArray*)		arrayOfValuesByExecutingSQL:(NSString*)command;
- (NSArray*)		arrayOfValuesByExecutingSQL:(NSString*)command replacingNullsWithValue:(id)nullValue;
- (void)			enumerateRowsByExecutingSQL:(NSString*)command block:(void(^)(NSDictionary* row, BOOL* stop))block;
- (void)			enumerateRowsByExecutingSQL:(NSString*)command replacingNullsWithValue:(id)nullValue block:(void(^)(NSDictionary* row, BOOL* stop))block;
@end





@interface			EESQLiteDatabase (Mutate)
/*!
 @discussion
 You can set `dictioaryValue` to nil, it'll be treated as empty dictionary.
 And this will insert a new row with only `NULL` values.
 */
- (EESQLiteRowID)		insertDictionaryValue:(NSDictionary*)dictionaryValue intoTable:(NSString*)tableName error:(NSError**)error;
- (EESQLiteRowIDList*)	insertArrayOfDictionaryValues:(NSArray*)dictionaryValues intoTable:(NSString*)tableName error:(NSError**)error;
- (void)				updateTable:(NSString*)tableName withDictionaryValue:(NSDictionary*)dictionaryValue filteringSQLExpression:(NSString*)filteringExpression error:(NSError**)error;
- (void)				deleteValuesFromTable:(NSString*)tableName withFilteringSQLExpression:(NSString*)filteringExpression error:(NSError**)error;
@end






@interface			EESQLiteDatabase (Schema)
- (NSArray*)		allSchema;
- (NSArray*)		allTableNames;
- (NSArray*)		allColumnNamesOfTable:(NSString*)tableName;
- (NSArray*)		tableInformationForName:(NSString*)tableName;

/*!
 @param
 columnExpressions
 An array contains column-definition expressions for each columns.
 The expresisons will not be escaped at all. It's your responsibility to make it safe.
 Definition of single column is enough with only its name.
 If you want to specify more constrains, see here:
 http://www.sqlite.org/lang_createtable.html
 
 @discussion
 If you don't supply any column-definition, this method is no-op.
 */
- (void)			addTableWithExpession:(NSString*)tableExpression withColumnExpressions:(NSArray*)columnExpressions isTemporary:(BOOL)temporary onlyWhenNotExist:(BOOL)ifNotExist;
- (void)			addTableWithName:(NSString*)tableName withColumnNames:(NSArray*)columnNames;
- (void)			removeTableWithName:(NSString*)tableName;
@end









@interface			EESQLiteDatabase (Status)
@property			(readonly,nonatomic)		NSUInteger		usingMemorySizeCurrent;
@property			(readonly,nonatomic)		NSUInteger		usingMemorySizeAtPeak;
@end







@interface			EESQLiteDatabase (Utility)
+ (NSString*)		stringWithEscapeForSQL:(NSString*)string;
@end





