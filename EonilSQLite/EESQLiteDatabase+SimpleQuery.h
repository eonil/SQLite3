//
//  EESQLiteDatabase+SimpleQuery.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EESQLiteCommon.h"
#import "EESQLiteDatabase.h"

/*!
 Query utility methods designed for simplicity using Property List types.
 
 @classdesign
 All methods defined in this category returns simple result.
 And returns `nil` if any error raised. 
 
 @discussion
 All *names* will be checked for ill-formed or not.
 But all *expressions* won't be checked at all. It's user's responsibility to make 
 expressions to be safe. (from such as SQL injection)
 
 @warning
 All of these operations doesn't use explicit tracsaction at all.
 So all of them are not atomic at all.
 If you want to make them as atomic operation, wrap them with explicit transaction.
 
 *	This behavior may change in future release to use transaction only when
	there's no active transactions. (by checking auto-commit mode)
 
 @exception
 All method in this category will throw an exception for wrong API use.
 
 */
@interface EESQLiteDatabase (SimpleQuery)

- (BOOL)				checkIntegrity;

- (BOOL)				containsRawID:(EESQLiteRowID)rowID inTable:(NSString*)tableName;		//	Returns `NO` if the table name is invalid.

- (NSArray*)			arrayOfAllRowsInTable:(NSString*)tableName;
- (NSArray*)			arrayOfRowsHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName limitCount:(NSUInteger)limitCount;	//	Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values. If you need large dataset, use -enumerate~ method series.
- (void)				enumerateAllRowsInTable:(NSString*)tableName block:(void(^)(NSDictionary* row, BOOL* stop))block;
/*!
 Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values.
 @return
 Returns `NO` for any erros while enumerating.
 
 @discussion
 If this method encounters any error while enumerating, enumeration will stop and return `NO`.
 Validity of already enumerated values are not defined.
 */
- (void)				enumerateRowsHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName limitCount:(NSUInteger)limitCount usingBlock:(void(^)(NSDictionary* row, BOOL* stop))block;
- (void)				enumerateRowsHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName usingBlock:(void(^)(NSDictionary* row, BOOL* stop))block;

//	Deprecated for better name.
- (void)				enumerateRowsHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName limitCount:(NSUInteger)limitCount block:(void(^)(NSDictionary* row, BOOL* stop))block EESQLITE3_DEPRECATED_METHOD;

- (NSDictionary*)		dictionaryFromRowHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName;								//	Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values.
- (NSDictionary*)		dictionaryFromRowHasID:(EESQLiteRowID)rowID inTable:(NSString*)tableName;														//	Result is defined only when the most safe row-ID column name `_ROWID_` is not used for general column name.
- (unsigned long long)	countOfAllRowsInTable:(NSString*)tableName;																						//	If the table name is invalid, returns 0.

/*!
 @discussion
 You can set `dictioaryValue` to nil, it'll be treated as empty dictionary.
 And this will insert a new row with only `NULL` values.
 */
- (EESQLiteRowID)		insertDictionaryValue:(NSDictionary*)dictionaryValue intoTable:(NSString*)tableName;
- (EESQLiteRowIDList*)	insertArrayOfDictionaryValues:(NSArray*)dictionaryValues intoTable:(NSString*)tableName;

/*!
 @param
 nullValue
 Null marker object. Columns contains this value will be set to `NULL`.
 This parameter will work for `nil` if you can contain `nil` in dictionary which is
 possible only at Core Foundation level.
 
 @discussion
 This method will UPDATE only values at spcified columns.
 If you don't put a value for a column, it won't be changed.
 So you can't set a column's value to `nil`. Because `NSDictionary` can't carry `nil`.
 To set a `NULL` to a column, set marker object instead of `nil`, and pass the value 
 to the last input argument. This method will set `NULL` for the column contains the
 null-marker object. I recommend to use `[NSNull null]` object.
 The value will be compared by sending `-isEqual:` method.
 
 @return
 Returns `YES` if the operation succeeds. `NO` for failure with any reason.
 */
- (void)				updateRowHasValue:(id)value atColumn:(NSString*)columnName inTable:(NSString*)tableName withDictionary:(NSDictionary*)newValue replacingValueAsNull:(id)nullValue;
- (void)				updateRowHasValue:(id)value atColumn:(NSString*)columnName inTable:(NSString*)tableName withDictionary:(NSDictionary*)newValue;	//	Execute above method with `nil` for last parameter.
- (void)				updateRowHasID:(EESQLiteRowID)rowID inTable:(NSString*)tableName withDictionary:(NSDictionary*)newValue;						//	Result is defined only when the most safe row-ID column name `_ROWID_` is not used for general column name.

- (void)				deleteAllRowsFromTable:(NSString*)tableName;
- (void)				deleteRowsHasValue:(id)value atColumn:(NSString*)columnName fromTable:(NSString*)tableName;				//	Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values.
- (void)				deleteRowHasID:(EESQLiteRowID)rowID fromTable:(NSString*)tableName;										//	Result is defined only when the most safe row-ID column name `_ROWID_` is not used for general column name.

/*
 This method is designed to delete and re-insert the row with new values.
 But it may cause a problem if there're some relations set.
 Possible implementation is removing existing value from existing row by inspecting 
 schema dynamically, may be very expecsive.
 And this operation also needs transaction support to work properly.
 */
//- (BOOL)				setRowHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName withDictionary:(NSDictionary*)newValue replacingValueAsNull:(id)nullValue;


/*!
 Performs an explicit transaction for multiple operations.
 This method will commit after all block command executed.
 Also rollbacks for any exceptions. Throwing an exception 
 is the only way to perform rollback. If you need some 
 performance-intensive code, use these methods diectly.
 
	 -[EESQLiteDatabase beginTransaction]
	 -[EESQLiteDatabase commitTransaction]
	 -[EESQLiteDatabase rollbackTransaction];
 
 @discussion

 Exception Handlings
 -------------------
 Supplied operation block will be executed with wrapping by `@try...@catch` block.
 Any exception will trigger ROLLBACK.

 This method `@catch` internal exception, and re-throw it after ROLLBACK.
 Debugger stack trace may indicate some other place than original catching frame.
 Don't be confused and see first-thrown stack-trace of the exception object to 
 investigate where the problems came.

 Nested Transaction
 ------------------
 SQLite doesn't support nested transaction. It supports only SAVEPOINT.
 So traditional BEGIN/COMMIT/ROLLBACK cannot be nested.
 This method will fail if there's any existing transaction.
 Not only fails, but also throws an exception.

 This prohibition is because of partiall rollback.
 If you rollback inside transaction, and commit outmost transaction, the
 rollback part shouldn't be applied, and other outer part should be.
 But without nested transaction, it's impossible to implement, so I don't
 offer nested transaction feature with tranditional semantic methods.

 Anyway the partial rollback is known as possible with SAVEPOINT feature,
 but unfourtunately, I don't know well about how it behaves. And it needs
 explicit name argument. If you relly want partial rollback, use SAVEPOINT
 feature.

 */
- (id)					objecyByPerformingTransactionUsingBlock:(id(^)(void))block;
- (void)				performTransactionUsingBlock:(void(^)(void))block;

@end

























