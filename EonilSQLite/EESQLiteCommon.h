//
//  EESQLiteCommon.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 7/23/12.
//  Copyright 2012 Eonil Company. All rights reserved.
//


#define			EESQLiteDeprecatedMethod			__attribute__((deprecated))

//typedef 		struct sqlite3 sqlite3;

BOOL			EESQLiteIsDebuggingMode();

void			EESQLiteAssert(BOOL condition, NSString* message);
void			EESQLiteExcept(NSString* reason) __attribute__((noreturn));		//!	Throws an exception unconditionally.
void			EESQLiteExceptIfThereIsAnError(NSError* error);					//!	Except if `error` is not `nil`.

void			EESQLiteExceptIfIdentifierIsInvalid(NSString* identifier);








#define	EONIL_DEBUG_MODE			EESQLITE_DEBUG



#if EONIL_DEBUG_MODE
static BOOL const	USE_DEBUGGING_ASSERTIONS	=	YES;
#else
static BOOL const	USE_DEBUGGING_ASSERTIONS	=	NO;
#endif

#define EESQLITE_UNAVAILABLE_METHOD							__attribute__((unavailable))
#define EESQLITE_DEPRECATED_METHOD							__attribute__((deprecated))
#define EESQLITE_NON_RETURNING_METHOD						__attribute__((noreturn))

#define	UNIVERSE_ERROR_LOG(...)								{ _universe_error_log(([NSString stringWithFormat:__VA_ARGS__])); }
#define UNIVERSE_FORBIDDEN_METHOD()							{ UNIVERSE_ERROR_LOG(@"Calling of this method has been forbidden. Do not call this method."); [self doesNotRecognizeSelector:_cmd]; abort(); };
#define UNIVERSE_DELETED_METHOD()							{ UNIVERSE_ERROR_LOG(@"This method semantically deleted. Do not call this method.%@", @""); [self doesNotRecognizeSelector:_cmd]; abort(); };
#define UNIVERSE_UNIMPLEMENTED_METHOD()						{ UNIVERSE_ERROR_LOG(@"This method should be exists here, but has not yet been implemented. Please contact the developer.%@", @""); [self doesNotRecognizeSelector:_cmd]; abort(); };

#if		EONIL_DEBUG_MODE
void	_universe_error_log(NSString* message);
void	UNIVERSE_DEBUG_ASSERT(BOOL cond);
void	UNIVERSE_DEBUG_ASSERT_WITH_MESSAGE(BOOL cond, NSString* message);
#define	UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(obj,type)				UNIVERSE_DEBUG_ASSERT([obj isKindOfClass:[type class]])
#define	UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE_OR_NIL(obj,type)		UNIVERSE_DEBUG_ASSERT([obj isKindOfClass:[type class]] || obj == nil)
void	UNIVERSE_UNREACHABLE_CODE() EESQLITE_NON_RETURNING_METHOD;
#else
#define	_universe_error_log(message)
#define	UNIVERSE_DEBUG_ASSERT(cond)
#define	UNIVERSE_DEBUG_ASSERT_WITH_MESSAGE(cond,message)
#define	UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(obj,type)
#define	UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE_OR_NIL(obj,type)
#define	UNIVERSE_UNREACHABLE_CODE()							__builtin_unreachable()
#endif






