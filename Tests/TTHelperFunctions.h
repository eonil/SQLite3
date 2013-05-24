//
//  TTHelperFunctions.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 5/25/13.
//  Copyright (c) 2013 Eonil Company. All rights reserved.
//

#import <Foundation/Foundation.h>




inline static void
TTAssertNoException(void (^block)())
{
	NSException*	test	=	nil;
	@try
	{
		block();
	}
	@catch (NSException* exc)
	{
		test	=	exc;
	}
	
	NSCAssert(test == nil, @"Should be no exception.");
}
inline static void
TTAssertAnException(void (^block)())
{
	NSException*	test	=	nil;
	@try
	{
		block();
	}
	@catch (NSException* exc)
	{
		test	=	exc;
	}
	
	NSCAssert(test != nil, @"Should be an exception.");
}


