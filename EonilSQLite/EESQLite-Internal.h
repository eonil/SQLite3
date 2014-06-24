//
//  EESQLite+Internal.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "EESQLiteDatabase.h"



/*
 This file is deprecated. Move all to `____internals____.h` file gradually.
 */




void			EESQLiteExceptWithReturnCodeForDatabase(int returnCode, sqlite3* db) __attribute__((noreturn));			//!	This function will create error even for the successful return-code such as `SQLITE_OK`.
void			EESQLiteExceptIfReturnCodeIsNotOK(int result, sqlite3* db);








