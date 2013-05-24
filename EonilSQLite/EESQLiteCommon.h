//
//  EESQLiteCommon.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright 2012 Eonil Company. All rights reserved.
//


#define			EESQLiteDeprecatedMethod			__attribute__((deprecated))

typedef 		struct sqlite3 sqlite3;

inline BOOL
EESQLiteIsDebuggingMode();

inline void
EESQLiteAssert(BOOL condition, NSString* message);

/*!
 Throws an exception unconditionally.
 */
inline void
EESQLiteExcept(NSString* reason) __attribute__((noreturn));





/*!
 This function will create error even for the successful return-code such as `SQLITE_OK`.
 */
inline void
EESQLiteExceptWithReturnCodeForDatabase(int returnCode, sqlite3* db) __attribute__((noreturn));




inline void
EESQLiteExceptIfReturnCodeIsNotOK(int result, sqlite3* db);

inline void
EESQLiteExceptIfThereIsAnError(NSError* error);		//	Except if `error` is not `nil`.

inline void
EESQLiteExceptIfIdentifierIsInvalid(NSString* identifier);











