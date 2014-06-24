//
//  UniverseDoctor.h
//  Spacetime
//
//  Created by Hoon H. on 14/5/26.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

#import "EESQLiteCommon.h"











@interface	EESQLite____internal_doctor : NSObject
+ (void)	panic EESQLITE3_NON_RETURNING_METHOD;
+ (void)	panicWithMessage:(NSString*)message EESQLITE3_NON_RETURNING_METHOD;
+ (void)	panicIf:(BOOL)condition;
+ (void)	panicIf:(BOOL)condition withMessage:(NSString*)message;
@end
