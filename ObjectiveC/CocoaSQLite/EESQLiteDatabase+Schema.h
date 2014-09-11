//
//  EESQLiteDatabase+Schema.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//



#import "EESQLiteDatabase.h"





@interface EESQLiteDatabase (Schema)
- (NSArray*)		allRawSchema;									//	Only for debugging purpose.
- (NSArray*)		allTableNames;
- (NSArray*)		allColumnNamesOfTable:(NSString*)tableName;
- (NSArray*)		tableInformationForName:(NSString*)tableName;

/*!
 @example
 See this SQL statement.
 
	CREATE TABLE IF NOT EXIST t(x INTEGER PRIMARY KEY ASC, y, z);
 
 Above SQL command is equal to below method call.
 
	[db addTableWithExpression:@"t" withColumnExpression:@[@"x INTEGER PRIMARY KEY", @"y", @"z"] isTemporary:NO onlyWhenNotExist:YES];
 
 @param
 tableExpression
 Table expression. This is usually just a table name.
 
 @param
 columnExpressions
 An array contains column-definition expressions for each columns.
 The expresisons will not be escaped at all. It's your responsibility to make it safe.
 Definition of single column is enough with only its name.
 If you want to specify more constrains, see here:
 http://www.sqlite.org/lang_createtable.html
 
 @note
 If you don't supply any column-definition, this method is no-op.
 */
- (void)			addTableWithExpession:(NSString*)tableExpression withColumnExpressions:(NSArray*)columnExpressions isTemporary:(BOOL)temporary onlyWhenNotExist:(BOOL)ifNotExist;
/*!
 @param	rowIDAliasColumnName	Can be @c nil to use default oid column.
 */
- (void)			addTableWithName:(NSString*)tableName withColumnNames:(NSArray*)columnNames rowIDAliasColumnName:(NSString*)rowIDAliasColumnName;
- (void)			addTableWithName:(NSString*)tableName withColumnNames:(NSArray*)columnNames;
- (void)			removeTableWithName:(NSString*)tableName;
@end













