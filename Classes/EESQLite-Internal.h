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







sqlite3*
EESQLiteDatabaseGetCorePointerToSQLite3(EESQLiteDatabase* database);














