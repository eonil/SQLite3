//
//  ____internals____.h
//  CocoaSQLite
//
//  Created by Hoon H. on 2014/06/24.
//  Copyright (c) 2014 Eonil Company. All rights reserved.
//


typedef struct sqlite3	sqlite3;
typedef struct sqlite3_stmt	sqlite3_stmt;
@class	EESQLiteDatabase;
@class	EESQLiteStatement;

sqlite3* const			eesqlite3____get_raw_db_object_from(EESQLiteDatabase* db);
sqlite3_stmt* const		eesqlite3____get_raw_stmt_object_from(EESQLiteStatement* stmt);
