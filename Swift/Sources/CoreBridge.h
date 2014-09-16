//
//  CoreBridge.h
//  EonilSQLite3
//
//  Created by Hoon H. on 9/15/14.
//
//

#pragma once
#import <sqlite3.h>



/*
 Calls `sqlite3_bind_text` with `SQLITE_TRANSIENT` which is almost impossible to represent in Swift code.
 */
static inline int
CoreBridge____sqlite3_bind_text_transient(sqlite3_stmt* a, int b, const char* c, int d)
{
	return	sqlite3_bind_text(a, b, c, d, SQLITE_TRANSIENT);
}

/*
 Calls `sqlite3_bind_blob` with `SQLITE_TRANSIENT` which is almost impossible to represent in Swift code.
 */
static inline int
CoreBridge____sqlite3_bind_blob_transient(sqlite3_stmt* a, int b, const void* c, int d)
{
	return	sqlite3_bind_blob(a, b, c, d, SQLITE_TRANSIENT);
}
