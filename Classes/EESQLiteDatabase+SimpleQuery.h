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
 Using methods such as `-executeTransactionBlock:usingSavepointName:`.
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

- (BOOL)				updateRowHasValue:(id)value atColumn:(NSString*)columnName inTable:(NSString*)tableName withDictionary:(NSDictionary*)newValue;	//	Returns `YES` if the operation succeeds. `NO` for failure with any reason.
- (BOOL)				updateRowHasID:(EESQLiteRowID)rowID inTable:(NSString*)tableName withDictionary:(NSDictionary*)newValue;						//	Returns `YES` if the operation succeeds. `NO` for failure with any reason.
- (BOOL)				deleteAllRowsInTable:(NSString*)tableName error:(NSError**)error;
- (BOOL)				deleteRowsHasValue:(id)value atColumn:(NSString*)columnName inTable:(NSString*)tableName error:(NSError**)error;				//	Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values.
- (BOOL)				deleteRowHasID:(EESQLiteRowID)rowID inTable:(NSString*)tableName error:(NSError**)error;										//	Result is defined only when the most safe row-ID column name `_ROWID_` is not used for general column name.

@end
