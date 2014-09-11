//
//  ____internals____.h
//  CocoaSQLite
//
//  Created by Hoon H. on 2014/06/24.
//  Copyright (c) 2014 Eonil Company. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "EESQLiteCommon.h"
#include <sqlite3.h>






BOOL			EESQLiteIsDebuggingMode();

void			EESQLiteAssert(BOOL condition, NSString* message);
void			EESQLiteExcept(NSString* reason) __attribute__((noreturn));		//!	Throws an exception unconditionally.
void			EESQLiteExceptIfThereIsAnError(NSError* error);					//!	Except if `error` is not `nil`.

void			EESQLiteExceptIfIdentifierIsInvalid(NSString* identifier);





void			EESQLiteExceptWithReturnCodeForDatabase(int returnCode, sqlite3* db) __attribute__((noreturn));			//!	This function will create error even for the successful return-code such as `SQLITE_OK`.
void			EESQLiteExceptIfReturnCodeIsNotOK(int result, sqlite3* db);













#pragma mark	-	Getting Raw Pointers (implementations are on each class files)

typedef struct sqlite3	sqlite3;
typedef struct sqlite3_stmt	sqlite3_stmt;
@class	EESQLiteDatabase;
@class	EESQLiteStatement;

sqlite3* const			eesqlite3____get_raw_db_object_from(EESQLiteDatabase* db);
sqlite3_stmt* const		eesqlite3____get_raw_stmt_object_from(EESQLiteStatement* stmt);
















#pragma mark	-	Dynamic Assertion Utilities (Copied from Universe)

/*!
 Detect Xcode default macro for debugging.
 */
#if	DEBUG
#define EESQLITE_DEBUG_MODE			1
#else
#define	EESQLITE_DEBUG_MODE			0
#endif

#ifndef EESQLITE_DEBUG_MODE		
#error	"`EESQLITE_DEBUG_MODE` Macro symbol has not been detected. You must define it. See MANUAL for details."
#endif

#define	EONIL_DEBUG_MODE			EESQLITE_DEBUG_MODE



#if EONIL_DEBUG_MODE
static BOOL const	USE_DEBUGGING_ASSERTIONS	=	YES;
#else
static BOOL const	USE_DEBUGGING_ASSERTIONS	=	NO;
#endif


#define	EESQLITE3_ERROR_LOG(...)							{ eesqlite3____error_log(([NSString stringWithFormat:__VA_ARGS__])); }
#define EESQLITE3_FORBIDDEN_METHOD()						{ EESQLITE3_ERROR_LOG(@"Calling of this method has been forbidden. Do not call this method."); [self doesNotRecognizeSelector:_cmd]; abort(); };
#define EESQLITE3_DELETED_METHOD()							{ EESQLITE3_ERROR_LOG(@"This method semantically deleted. Do not call this method.%@", @""); [self doesNotRecognizeSelector:_cmd]; abort(); };
#define EESQLITE3_UNIMPLEMENTED_METHOD()					{ EESQLITE3_ERROR_LOG(@"This method should be exists here, but has not yet been implemented. Please contact the developer.%@", @""); [self doesNotRecognizeSelector:_cmd]; abort(); };

#if		EONIL_DEBUG_MODE
void	eesqlite3____error_log(NSString* message);
void	EESQLITE3_DEBUG_ASSERT(BOOL cond);
void	EESQLITE3_DEBUG_ASSERT_WITH_MESSAGE(BOOL cond, NSString* message);
#define	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(obj,type)				EESQLITE3_DEBUG_ASSERT([obj isKindOfClass:[type class]])
#define	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE_OR_NIL(obj,type)		EESQLITE3_DEBUG_ASSERT([obj isKindOfClass:[type class]] || obj == nil)
void	EESQLITE3_UNREACHABLE_CODE() EESQLITE3_NON_RETURNING_METHOD;
#else
#define	eesqlite3____error_log(message)
#define	EESQLITE3_DEBUG_ASSERT(cond)
#define	EESQLITE3_DEBUG_ASSERT_WITH_MESSAGE(cond,message)
#define	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE(obj,type)
#define	EESQLITE3_DEBUG_ASSERT_OBJECT_TYPE_OR_NIL(obj,type)
#define	EESQLITE3_UNREACHABLE_CODE()							__builtin_unreachable()
#endif




























