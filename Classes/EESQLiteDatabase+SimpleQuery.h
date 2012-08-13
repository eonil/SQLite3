//
//  EESQLiteDatabase+SimpleQuery.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EESQLiteSymbols.h"
#import "EESQLiteDatabase.h"

/*!
 Query utility methods designed for simplisity.
 All methods defined in this category returns simple result.
 And returns `nil` if any error raised. 
 
 @discussion
 All *names* will be checked for ill-formed or not.
 But all *expressions* won't be checked at all. It's user's responsibility to make expressions to be safe.
 
 @warning
 All of these operations doesn't use explicit tracsaction at all.
 So all of them are not atomic at all.
 If you want to make them as atomic operation, wrap them with explicit transaction.
 */
@interface EESQLiteDatabase (SimpleQuery)

- (BOOL)				checkIntegrity;
- (BOOL)				containsRawID:(EESQLiteRowID)rowID inTable:(NSString*)tableName;		//	Returns `NO` if the table name is invalid.

- (NSArray*)			arrayOfAllRowsInTable:(NSString*)tableName;
- (NSArray*)			arrayOfRowsHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName limitCount:(NSUInteger)limitCount;	//	Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values.
- (BOOL)				enumerateAllRowsInTable:(NSString*)tableName block:(void(^)(NSDictionary* row, BOOL* stop))block;
/*!
 Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values.
 @return
 Returns `NO` for any erros while enumerating.
 
 @discussion
 If this method encounters any error while enumerating, enumeration will stop and return `NO`.
 Validity of already enumerated values are not defined.
 */
- (BOOL)				enumerateRowsHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName limitCount:(NSUInteger)limitCount block:(void(^)(NSDictionary* row, BOOL* stop))block;


- (NSDictionary*)		dictionaryFromRowHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName;								//	Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values.
- (NSDictionary*)		dictionaryFromRowHasID:(EESQLiteRowID)rowID inTable:(NSString*)tableName;														//	Result is defined only when the most safe row-ID column name `_ROWID_` is not used for general column name.
- (unsigned long long)	countOfAllRowsInTable:(NSString*)tableName;																						//	If the table name is invalid, returns 0.

/*!
 @discussion
 You can set `dictioaryValue` to nil, it'll be treated as empty dictionary.
 And this will insert a new row with only `NULL` values.
 */
- (EESQLiteRowID)		insertDictionaryValue:(NSDictionary*)dictionaryValue intoTable:(NSString*)tableName error:(NSError**)error;
- (EESQLiteRowIDList*)	insertArrayOfDictionaryValues:(NSArray*)dictionaryValues intoTable:(NSString*)tableName error:(NSError**)error;

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
- (BOOL)				updateRowHasValue:(id)value atColumn:(NSString*)columnName inTable:(NSString*)tableName withDictionary:(NSDictionary*)newValue replacingValueAsNull:(id)nullValue;
- (BOOL)				updateRowHasValue:(id)value atColumn:(NSString*)columnName inTable:(NSString*)tableName withDictionary:(NSDictionary*)newValue;	//	Execute above method with `nil` for last parameter. Returns `YES` if the operation succeeds. `NO` for failure with any reason.
- (BOOL)				updateRowHasID:(EESQLiteRowID)rowID inTable:(NSString*)tableName withDictionary:(NSDictionary*)newValue;						//	Result is defined only when the most safe row-ID column name `_ROWID_` is not used for general column name. Returns `YES` if the operation succeeds. `NO` for failure with any reason.

- (BOOL)				deleteAllRowsInTable:(NSString*)tableName error:(NSError**)error;																//	Returns `YES` if the operation succeeds. `NO` for failure with any reason.
- (BOOL)				deleteRowsHasValue:(id)value atColumn:(NSString*)columnName inTable:(NSString*)tableName error:(NSError**)error;				//	Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values. Returns `YES` if the operation succeeds. `NO` for failure with any reason.
- (BOOL)				deleteRowHasID:(EESQLiteRowID)rowID inTable:(NSString*)tableName error:(NSError**)error;										//	Result is defined only when the most safe row-ID column name `_ROWID_` is not used for general column name. Returns `YES` if the operation succeeds. `NO` for failure with any reason.

@end
























