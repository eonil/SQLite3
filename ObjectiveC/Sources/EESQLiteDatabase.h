//
//  EESQLiteDatabase.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				"EESQLiteCommon.h"
#import				"EESQLiteRowIDList.h"



/*!
 An SQLite3 database.
 
 @discussion
 Any method that exeutes SQL command will be performed with implicit transaction
 if you don't perform explicit transaction.
 (except the method call the explicit transaction itself such as `beginTransactionWithError:`).
 
 You need to manage all transactions yourself.
 
 @classdesign
 This class is not intended to be subclassed. Do not subclass this class.
 */
@interface			EESQLiteDatabase : NSObject

- (void)			executeSQL:(NSString*)command;											//	Throws an exception for any internal error. If you need to catch parsing error, you should use explicit `EESQLiteStatement` object and related methods.
- (NSArray*)		statementsByParsingSQL:(NSString*)command;								//	Returns `nil` for any error.
- (NSArray*)		statementsByParsingSQL:(NSString*)command error:(NSError**)error;		//	Returns `nil` for any error.

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
- (id)				initAsPersistentDatabaseOnDiskAtPath:(NSString*)pathToDatabase error:(NSError**)error;

+ (EESQLiteDatabase*)	temporaryDatabaseInMemory;
+ (EESQLiteDatabase*)	temporaryDatabaseOnDisk;
+ (EESQLiteDatabase*)	persistentDatabaseOnDiskAtPath:(NSString*)pathToDatabase;								//	This path cannot start with `:` character.
+ (BOOL)				createEmptyPersistentDatabaseOnDiskAtPath:(NSString *)path;								//	YES if creation succeeded. NO for all otherwise.
+ (BOOL)				createEmptyPersistentDatabaseOnDiskAtPath:(NSString *)path error:(NSError**)error;		//	YES if creation succeeded. NO for all otherwise.

@end

/*!
 In SQLite3, nested transaction offered as SAVEPOINT.
 BEGIN/COMMIT/ROLLBACK TRANSACTION command is offered because it's defined,
 but I don't recommend to use them because they don't offer nested transaction.
 
 Basically, these are convenient utility method for calling `-executeSQL:error:`
 method. Semantics of same arguments are same with the methods.
 */
@interface			EESQLiteDatabase (Transaction)

- (void)			beginTransaction;			//	Nested call runs unconditionally. But it doesn't mean SQLite support nested transaction.
- (void)			commitTransaction;			//	Nested call runs unconditionally. But it doesn't mean SQLite support nested transaction.
- (void)			rollbackTransaction;		//	Nested call runs unconditionally. But it doesn't mean SQLite support nested transaction.

- (void)			markSavepointWithName:(NSString*)savepointName;
- (void)			releaseSavepointOfName:(NSString*)savepointName;
- (void)			rollbackToSavepointOfName:(NSString*)savepointName;

///*!
// Perform BEGIN/COMMIT/ROLLBACK transaction.
// 
// @param
// transactionBlock
// This block MUST return whether to commit or rollback the transaction.
// Return `YES` to commit transaction.
// Return `NO` to rollback transaction.
// 
// @return
// Returns `YES` if the transaction finished with COMMIT.
// Returns `NO` if the transaction finished with ROLLBACK.
// So this is equal with the result of the tracsaction block.
// 
// @discussion
// This method implemented by calling `-objectByExecutingTransactionBlock:` 
// method. See the method description for more details.
// */
//- (BOOL)			executeTransactionBlock:(BOOL(^)(void))transactionBlock;
//
///*!
// Perform BEGIN/COMMIT/ROLLBACK transaction.
// 
// @param
// transactionBlock
// This block MUST return `nil` to rollback transaction.
// Otherwise transaction will be committed.
// 
// @return
// The value returned by `transactionBlock`.
// 
// @discussion
// `transactionBlock` MUST return non-`nil` value to COMMIT transaction. Otherwise
// transaction will be ROLLBACK. If you don't have any value to return, use 
// `-executeTransactionBlock:` method instead of.
// 
// If there's an error on issuing transaction command itself, it will throw an 
// exception. because nothing can be done at that point.
// 
// Exception Handlings
// -------------------
// Supplied operation block will be executed with wrapping by `@try...@finally` block. 
// Any exception will trigger ROLLBACK in `@finally` block. If there's no exception,
// your return value will select the trasaction result.
// This method does not `@catch` any exception, so exceptions will be thrown again.
// Don't be confused with debugger's current breaking stack trace. See first-thrown 
// stack-trace of the exception object to investigate where the problems come.
// 
// Nested Transaction
// ------------------
// SQLite doesn't support nested transaction. It supports only SAVEPOINT.
// So traditional BEGIN/COMMIT/ROLLBACK cannot be nested.
// This method will fail if there's any existing transaction.
// Not only fails, but also throws an exception.
// 
// This prohibition is because of partiall rollback.
// If you rollback inside transaction, and commit outmost transaction, the
// rollback part shouldn't be applied, and other outer part should be.
// But without nested transaction, it's impossible to implement, so I don't
// offer nested transaction feature with tranditional semantic methods.
// 
// Anyway the partial rollback is known as possible with SAVEPOINT feature,
// but unfourtunately, I don't know well about how it behaves. And it needs
// explicit name argument. If you relly want partial rollback, use SAVEPOINT
// feature.
// */
//- (id)				objectByExecutingTransactionBlock:(id(^)(void))transactionBlock;
@end

@interface			EESQLiteDatabase (Status)
@property			(readonly,nonatomic)		BOOL			autocommitMode					EESQLITE3_DEPRECATED_METHOD;
@property			(readonly,nonatomic)		BOOL			isAutocommitMode;
@property			(readonly,nonatomic)		NSUInteger		usingMemorySizeCurrent;
@property			(readonly,nonatomic)		NSUInteger		usingMemorySizeAtPeak;
@end

@interface			EESQLiteDatabase (Utility)
+ (BOOL)			isValidIdentifierString:(NSString*)identifierString;
+ (NSString*)		stringWithEscapeForSQL:(NSString*)string;
@end














