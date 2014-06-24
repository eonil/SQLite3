//
//  EESQLiteStatement_Internal.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				<sqlite3.h>
#import				"EESQLiteDatabase.h"

@interface			EESQLiteStatement (Internal)
@property			(readonly,nonatomic)			NSString*			sourceCommand;
@property			(readonly,nonatomic)			sqlite3_stmt*		rawstmt;
- (id)				initWithDB:(sqlite3*)db sql:(const char *)sql byte:(int)byte tail:(const char **)tail error:(NSError**)error;

/*!
 @return
 Array of compiled SQL command statement objects.
 `nil` for case of no command or compilation error.
 In `error` case, the error argument will set to proper error object.	
 */
+ (NSArray*)		statementsWithSQLString:(NSString*)sqlString database:(EESQLiteDatabase*)database error:(NSError**)error;
@end
