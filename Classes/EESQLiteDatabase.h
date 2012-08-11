//
//  EESQLiteDatabase.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				"EESQLiteSymbols.h"
#import				"EESQLiteRowIDList.h"



/*!
 An SQLite3 database.
 
 @discussion
 Any method that exeutes SQL command does not use explicit transaction 
 implicitly at all. (except the method call the explicit transaction itself
 such as `beginTransactionWithError:`).
 
 You need to manage all transactions yourself.
 */
@interface			EESQLiteDatabase : NSObject

- (BOOL)			executeSQL:(NSString*)command;
- (BOOL)			executeSQL:(NSString*)command error:(NSError**)error;						//	Returns `NO` for any error.
- (NSArray*)		statementsByParsingSQL:(NSString*)command;									//	Returns `nil` for any error.
- (NSArray*)		statementsByParsingSQL:(NSString*)command error:(NSError**)error;			//	Returns `nil` for any error.

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

/*!
 In SQLite3, nested transaction offered as SAVEPOINT.
 BEGIN/COMMIT/ROLLBACK TRANSACTION command is offered because it's defined,
 but I don't recommen to use them because they don't offer nested transaction.
 
 Basically, these are convenient utility method for calling `-executeSQL:error:`
 method. Semantics of same arguments are same with the methods.
 */
@interface			EESQLiteDatabase (Transaction)

- (void)			beginTransaction		EESQLiteDeprecatedMethod;
- (void)			commitTransaction		EESQLiteDeprecatedMethod;
- (void)			rollbackTransaction		EESQLiteDeprecatedMethod;

- (BOOL)			beginTransactionWithError:(NSError**)error;			//	Nested call runs unconditionally. But it doesn't mean SQLite support nested transaction.
- (BOOL)			commitTransactionWithError:(NSError**)error;		//	Nested call runs unconditionally. But it doesn't mean SQLite support nested transaction.
- (BOOL)			rollbackTransactionWithError:(NSError**)error;		//	Nested call runs unconditionally. But it doesn't mean SQLite support nested transaction.

- (BOOL)			markSavepointWithName:(NSString*)savepointName error:(NSError**)error;
- (BOOL)			releaseSavepointOfName:(NSString*)savepointName error:(NSError**)error;
- (BOOL)			rollbackToSavepointOfName:(NSString*)savepointName error:(NSError**)error;

/*!
 Perform BEGIN/COMMIT/ROLLBACK transaction.
 
 @return
 Returns `YES` if the transaction finished with COMMIT.
 Returns `NO` if the transaction finished with ROLLBACK.
 So this is equal with the result of the tracsaction block.
 
 @discussion
 For any transaction command itself failure, this method
 will throw an exception.
 
 Nested Transaction
 ------------------
 SQLite doesn't support nested transaction. It supports only SAVEPOINT.
 So traditional BEGIN/COMMIT/ROLLBACK cannot be nested.
 This method will fail if there's any existing transaction.
 Not only fails, it throws an exception.
 */
- (BOOL)			executeTransactionBlock:(BOOL(^)(void))transactionBlock;
/*!
 Perform BEGIN/COMMIT/ROLLBACK transaction.
 
 @param
 transactionBlock
 This block MUST return `nil` to rollback transaction. Otherwise transaction will 
 be committed. 
 
 @return
 The value returned by `transactionBlock`.
 
 @discussion
 `transactionBlock` MUST return non-`nil` value to COMMIT transaction. Otherwise
 transaction will be ROLLBACK. If you don't have any value to return, use 
 `-executeTransactionBlock:` method instead of.
 
 If there's an error on issuing transaction command itself, it will throw an 
 exception. because nothing can be done at that point.
 
 Nested Transaction
 ------------------
 SQLite doesn't support nested transaction. It supports only SAVEPOINT.
 So traditional BEGIN/COMMIT/ROLLBACK cannot be nested.
 This method will fail if there's any existing transaction.
 Not only fails, it throws an exception.
 */
- (id)				objectByExecutingTransactionBlock:(id(^)(void))transactionBlock;
@end

@interface			EESQLiteDatabase (Status)
@property			(readonly,nonatomic)		BOOL			autocommitMode					EESQLiteDeprecatedMethod;			
@property			(readonly,nonatomic)		BOOL			isAutocommitMode;
@property			(readonly,nonatomic)		NSUInteger		usingMemorySizeCurrent;
@property			(readonly,nonatomic)		NSUInteger		usingMemorySizeAtPeak;
@end

@interface			EESQLiteDatabase (Utility)
+ (BOOL)			isValidIdentifierString:(NSString*)identifierString;
+ (NSString*)		stringWithEscapeForSQL:(NSString*)string;
@end














