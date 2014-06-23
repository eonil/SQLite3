//
//  UniverseDoctor.h
//  Spacetime
//
//  Created by Hoon H. on 14/5/26.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

//#import "UniverseCommon.h"
#import "EESQLiteCommon.h"

//
/////*!
//// Resoverable exception.
//// Usually happen by bad input.
//// 
//// @note
//// I don't like this name. Figure out better one.
//// */
////@interface	UniverseCancellation : EESQLiteException
////@end
//
///*!
// Unrecoverable exception.
// This means program state is already corrupted, and cannot continue execution.
// */
//@interface	UniverseCorruption : EESQLiteException
//@end










@interface	EESQLite____internal_doctor : NSObject
//+ (void)	except EESQLITE_NON_RETURNING_METHOD;
//+ (void)	exceptWithMessage:(NSString*)message EESQLITE_NON_RETURNING_METHOD;
//+ (void)	exceptIf:(BOOL)condition;
//+ (void)	exceptIf:(BOOL)condition withMessage:(NSString*)message;
+ (void)	panic EESQLITE_NON_RETURNING_METHOD;
+ (void)	panicWithMessage:(NSString*)message EESQLITE_NON_RETURNING_METHOD;
+ (void)	panicIf:(BOOL)condition;
+ (void)	panicIf:(BOOL)condition withMessage:(NSString*)message;
@end
