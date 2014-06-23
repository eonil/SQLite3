//
//  UniverseCommon.m
//  Spacetime
//
//  Created by Hoon H. on 14/5/26.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

#import "UniverseCommon.h"
#import "UniverseDoctor.h"




#if EONIL_DEBUG_MODE

void
_universe_error_log(NSString* message)
{
	NSLog(@"[Universe/Error/Log] %@", message);
}

void
UNIVERSE_DEBUG_ASSERT(BOOL cond)
{
	[UniverseDoctor panicIf:!cond withMessage:@"Debugging asertion failure!"];
}
void
UNIVERSE_DEBUG_ASSERT_WITH_MESSAGE(BOOL cond, NSString* message)
{
	[UniverseDoctor panicIf:!cond withMessage:message];
}

void
UNIVERSE_UNREACHABLE_CODE()
{
	[UniverseDoctor panicWithMessage:@"Unreacable code! (asserted for debugging)"];
	__builtin_unreachable();
}

#endif








NSString* const	UNIVERSE_DOCUMENT_AUTOSAVE_WINDOW_OUTER_SPLIT			=	@"UNIVERSE_DOCUMENT_AUTOSAVE_WINDOW_OUTER_SPLIT";
NSString* const	UNIVERSE_DOCUMENT_AUTOSAVE_WINDOW_INNER_SPLIT			=	@"UNIVERSE_DOCUMENT_AUTOSAVE_WINDOW_INNER_SPLIT";