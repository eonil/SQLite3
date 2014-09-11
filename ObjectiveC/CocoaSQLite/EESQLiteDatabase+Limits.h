//
//  EESQLiteDatabase+Limits.h
//  CocoaSQLite
//
//  Created by Hoon H. on 2014/06/24.
//  Copyright (c) 2014 Eonil Company. All rights reserved.
//

#import "EESQLiteDatabase.h"

@interface	EESQLiteDatabase (Limits)
@property	(readwrite,nonatomic,assign)		NSInteger			numberOfParameterVariable;				///<	SQLITE_LIMIT_VARIABLE_NUMBER
@end
