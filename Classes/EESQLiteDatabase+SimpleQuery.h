//
//  EESQLiteDatabase+SimpleQuery.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import "EESQLiteDatabase.h"

/*!
 Query utility methods designed for simplisity.
 All methods defined in this category returns simple result.
 And returns `nil` if any error raised. 
 
 @discussion
 All *names* will be checked for ill-formed or not.
 But all *expressions* won't be checked at all. It's user's responsibility to make expressions to be safe.
 */
@interface EESQLiteDatabase (SimpleQuery)
- (NSArray*)			arrayOfAllRowsInTable:(NSString*)tableName;
- (NSArray*)			arrayOfRowsHasValue:(id)value atColumne:(NSString*)columnName inTable:(NSString*)tableName limitCount:(NSUInteger)limitCount;	//	Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values.
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
- (void)				updateTable:(NSString*)tableName withDictionaryValue:(NSDictionary*)dictionaryValue filteringSQLExpression:(NSString*)filteringExpression error:(NSError**)error;
- (void)				deleteValuesFromTable:(NSString*)tableName withFilteringSQLExpression:(NSString*)filteringExpression error:(NSError**)error;

- (void)				deleteAllRowsInTable:(NSString*)tableName;
- (void)				deleteRowsHasValue:(id)value atColumn:(NSString*)columnName inTable:(NSString*)tableName;			//	Result is defined only for `NSString` or `NSNumber`(with integral or floating-point number) values.
- (void)				deleteRowHasID:(EESQLiteRowID)rowID inTable:(NSString*)tableName;									//	Result is defined only when the most safe row-ID column name `_ROWID_` is not used for general column name.
@end
