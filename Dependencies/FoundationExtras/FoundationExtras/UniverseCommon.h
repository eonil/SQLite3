//
//  UniverseCommon.h
//  Spacetime
//
//  Created by Hoon H. on 14/5/26.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

#ifdef	__cplusplus
extern "C"
{
#endif

	
#ifdef	__cplusplus
//#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
//#import <QuartzCore/QuartzCore.h>
#else
@import Foundation;
@import QuartzCore;
#endif

	
	
	






#if EONIL_DEBUG_MODE
static BOOL const	USE_DEBUGGING_ASSERTIONS	=	YES;
#else
static BOOL const	USE_DEBUGGING_ASSERTIONS	=	NO;
#endif

#define UNIVERSE_UNAVAILABLE_METHOD							__attribute__((unavailable))
#define UNIVERSE_DEPRECATED_METHOD							__attribute__((deprecated))
#define UNIVERSE_NON_RETURNING_METHOD						__attribute__((noreturn))

#define	UNIVERSE_ERROR_LOG(...)								{ _universe_error_log(([NSString stringWithFormat:__VA_ARGS__])); }
#define UNIVERSE_FORBIDDEN_METHOD()							{ UNIVERSE_ERROR_LOG(@"Calling of this method has been forbidden. Do not call this method."); [self doesNotRecognizeSelector:_cmd]; abort(); };
#define UNIVERSE_DELETED_METHOD()							{ UNIVERSE_ERROR_LOG(@"This method semantically deleted. Do not call this method.%@", @""); [self doesNotRecognizeSelector:_cmd]; abort(); };
#define UNIVERSE_UNIMPLEMENTED_METHOD()						{ UNIVERSE_ERROR_LOG(@"This method should be exists here, but has not yet been implemented. Please contact the developer.%@", @""); [self doesNotRecognizeSelector:_cmd]; abort(); };

#if		EONIL_DEBUG_MODE
void	_universe_error_log(NSString* message);
void	UNIVERSE_DEBUG_ASSERT(BOOL cond);
void	UNIVERSE_DEBUG_ASSERT_WITH_MESSAGE(BOOL cond, NSString* message);
#define	UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(obj,type)			UNIVERSE_DEBUG_ASSERT([obj isKindOfClass:[type class]])
#define	UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE_OR_NIL(obj,type)	UNIVERSE_DEBUG_ASSERT([obj isKindOfClass:[type class]] || obj == nil)
void	UNIVERSE_UNREACHABLE_CODE() UNIVERSE_NON_RETURNING_METHOD;
#else
#define	_universe_error_log(message)
#define	UNIVERSE_DEBUG_ASSERT(cond)
#define	UNIVERSE_DEBUG_ASSERT_WITH_MESSAGE(cond,message)
#define	UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(obj,type)
#define	UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE_OR_NIL(obj,type)
#define	UNIVERSE_UNREACHABLE_CODE()							__builtin_unreachable()
#endif




extern NSString* const	UNIVERSE_DOCUMENT_AUTOSAVE_WINDOW_OUTER_SPLIT;
extern NSString* const	UNIVERSE_DOCUMENT_AUTOSAVE_WINDOW_INNER_SPLIT;


	
	
	
#ifdef __cplusplus
}
#endif