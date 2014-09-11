//
//  EESQLiteDatabase+Limits.m
//  CocoaSQLite
//
//  Created by Hoon H. on 2014/06/24.
//  Copyright (c) 2014 Eonil Company. All rights reserved.
//

#import "EESQLiteDatabase+Limits.h"
#import "____internals____.h"
#include <sqlite3.h>

@implementation EESQLiteDatabase (Limits)
- (NSInteger)numberOfParameterVariable
{
	/*!
	 @note	Negative value means *no change*.
	 @ref	http://www.sqlite.org/c3ref/limit.html
	 */
	return	sqlite3_limit(eesqlite3____get_raw_db_object_from(self), SQLITE_LIMIT_VARIABLE_NUMBER, -1);
}
- (void)setNumberOfParameterVariable:(NSInteger)numberOfParameterVariable
{
	EESQLITE3_DEBUG_ASSERT(numberOfParameterVariable >= 0);
	EESQLITE3_DEBUG_ASSERT(numberOfParameterVariable <= INT_MAX);
	
	////
	
	int	v2	=	(int)numberOfParameterVariable;
	sqlite3_limit(eesqlite3____get_raw_db_object_from(self), SQLITE_LIMIT_VARIABLE_NUMBER, v2);
}
@end
