//
//  EESQLiteStatement.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				<Foundation/Foundation.h>








/*!
 @abstract
 Prepared statement.
 
 @discussion
 This is essentially a proxy object for compiled byte-code program in SQLite engine.
 
 @warning
 You MUST deallocate this object before hosting `EESQLiteDatabase` object
 deallocates. Because SQLite3 checks all the statements are finalized when
 it is dying. If any of them are still remains, it will raise an error,
 `EESQLiteDatabase` object will detect it and throw an exception.
 
 I recommend `@autoreleasepool` block to make it sure to be deallocated.
 */
@interface			EESQLiteStatement : NSObject
@property			(readonly,nonatomic)		NSString*		SQL;
/*!
 @abstract
 Steps processing of SQL command.
 
 @result
 Returns iterability.
 `YES` if the command need to be stepped more. Normally, this returned because 
 execution is not finished and has more steps to go.
 `NO` if the command finished, and cannot be iterated anymore.
 
 You can continue stepping only while this method returns `YES`.
 */
- (BOOL)			step;

/*!
 @abstract
 Reset internal state of this statement to re-use.
 
 @discussion
 If you want to issue same command without re-compiling it again, 
 you can use this method to re-use it.
 */
- (void)			reset;

@end











@interface			EESQLiteStatement (Querying)

- (NSUInteger)		dataCount;

////				Access as raw storage class.
////				If you try to read with different type with actual value stored in,
////				SQLite3 will try to convert values. Obviously not good for performance.
////				See here for conversion table:
////				http://www.sqlite.org/c3ref/column_blob.html
////
////				String access method supports only UTF-8. 
////				This means if the source data is stored in UTF-16, conversion will 
////				be occur and performance will be degraded.
////				Of course, SQLite3 supports UTF-16. No support for UTF-16 is my decision
////				to simplify class.
- (long long)		longLongValueForColumnIndex:(NSInteger)columnIndex;
- (NSInteger)		integerValueForColumnIndex:(NSInteger)columnIndex;		//	Size of `NSInteger` can be vary by the system.
- (double)			doubleValueForColumnIndex:(NSInteger)columnIndex;
- (NSString*)		stringValueForColumnIndex:(NSInteger)columnIndex;		//	Returning string is copied value.
- (NSData*)			dataValueForColumnIndex:(NSInteger)columnIndex;			//	Returning data is copied value.
- (BOOL)			isNullAtColumnIndex:(NSInteger)columnIndex;

/*!
 @abstract
 Read whole current row as dictionary.
 
 @discussion
 Access as collected and automatically typed object.
 Each field can be one of `NSData`, `NSString` or `NSNumber` which
 contains integral or floating point numbers.
 SQLite's `NULL` will be replaced with specified value.
 You can specify `nil` for replacement, and the field with `nil` value
 will not be stored in dictionary.
 String or binary data copied before return. So it's safe to keep them.
 This is a lot slower than access by raw storage class methods.
 */
- (NSDictionary*)	dictionaryValueReplacingNullsWithValue:(id)nullValue;
- (NSDictionary*)	dictionaryValue;	//	Set `nullValue` as `nil`.



@end










/*!
 Basically you should pass correctly typed non-nil value when you use typed set method.
 */
@interface			EESQLiteStatement (Mutation)

- (NSUInteger)		parameterCount;

- (void)			setInt64Value:(int64_t)value forParameterIndex:(NSInteger)parameterIndex;
- (void)			setLongLongValue:(long long)value forParameterIndex:(NSInteger)parameterIndex;
- (void)			setIntegerValue:(NSInteger)value forParameterIndex:(NSInteger)parameterIndex;		//	Size of `NSInteger` can be vary by the system.
- (void)			setDoubleValue:(double)value forParameterIndex:(NSInteger)parameterIndex;
- (void)			setStringValue:(NSString*)value forParameterIndex:(NSInteger)parameterIndex;
- (void)			setDataValue:(NSData*)value forParameterIndex:(NSInteger)parameterIndex;
- (void)			setNullForParameterIndex:(NSInteger)parameterIndex;

/*!
 If the `value` is `nil`, the parameter will be set to `NULL`.
 */
- (void)			setValue:(id)value forParameterIndex:(NSInteger)parameterIndex;
- (void)			setValue:(id)value forParameterName:(NSString*)parameterName;
//- (void)			setValuesFromArray:(NSArray*)valuesArray;
//- (void)			setDictionaryValue:(NSDictionary*)dictionaryValue;

- (void)			clearParametersValues;

@end










