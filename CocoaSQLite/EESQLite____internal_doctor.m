//
//  UniverseDoctor.m
//  Spacetime
//
//  Created by Hoon H. on 14/5/26.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

#import "EESQLite____internal_doctor.h"
#import "EESQLiteException.h"









static NSString* const		REASON_UNKNOWN	=	@"Reason unknown";



EESQLITE3_NON_RETURNING_METHOD
static void
universe_panic(NSString* message)
{
	NSString*				reason	=	[NSString stringWithFormat:@"[CORRUPTION/PANIC] %@", message];
	EESQLiteException*		exc		=	[[EESQLiteException alloc] initWithName:@"CORRUPTION/PANIC" reason:reason userInfo:nil];
	NSLog(@"%@", exc);
	@throw	exc;
}








@implementation EESQLite____internal_doctor
+ (void)panic
{
	universe_panic(REASON_UNKNOWN);
}
+ (void)panicWithMessage:(NSString *)message
{
	universe_panic(message);
}
+ (void)panicIf:(BOOL)condition
{
	if (condition)
	{
		universe_panic(REASON_UNKNOWN);
	}
}
+ (void)panicIf:(BOOL)condition withMessage:(NSString *)message
{
	if (condition)
	{
		universe_panic(message);
	}
}
@end







