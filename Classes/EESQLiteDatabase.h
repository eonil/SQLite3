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
- (NSArray*)		statementsByParsingSQL:(NSString*)command;									//	Returns `nil` for any error.
- (NSArray*)		statementsByParsingSQL:(NSString*)command error:(NSError**)error;			//	Returns `nil` for any error.

- (void)			beginTransaction;
- (void)			commitTransaction;
- (void)			rollbackTransaction;
- (void)			executeTransactionBlock:(BOOL(^)(void))transaction;							//	Trnsaction will be commited if the block returns YES, all otherwise will be rolled back.

/*!
 @abstract
 Creates a new in-memory database.
 The database will be erased when the connection closes.
 */
- (id)				initAsTemporaryDatabaseInMemoryWithError:(NSError**)error;

/*!
 @abstract
 Open a new temporary database on temporary file.
 The database file will be deleted when the connecion closes.
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

@interface			EESQLiteDatabase (Status)
@property			(readonly,nonatomic)		NSUInteger		usingMemorySizeCurrent;
@property			(readonly,nonatomic)		NSUInteger		usingMemorySizeAtPeak;
@end

@interface			EESQLiteDatabase (Utility)
+ (BOOL)			isValidIdentifierString:(NSString*)identifierString;
+ (NSString*)		stringWithEscapeForSQL:(NSString*)string;
@end





