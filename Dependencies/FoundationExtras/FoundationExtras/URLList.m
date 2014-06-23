//
//  URLList.m
//  FoundationExtras
//
//  Created by Hoon H. on 2014/06/15.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

#import "URLList.h"
#import "StringUtil1.h"

@implementation URLList
{
	NSArray*	_arr;
}
+ (instancetype)instantiation
{
	return	[[self alloc] init];
}
+ (instancetype)instantiationWithURL:(NSURL *)url
{
	return	[self instantiationWithURLs:@[url]];
}
+ (instancetype)instantiationWithURLs:(NSArray *)urls
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(urls, NSArray);
		for (id u1 in urls)
		{
			UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(u1, NSURL);
		}
	}
	
	////
	
	return	[[[self class] alloc] ____initWithURLs:urls];
}
- (NSUInteger)count
{
	return	_arr.count;
}
- (NSURL *)urlAtIndex:(NSUInteger)index
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT(index != NSNotFound);
	}
	
	////
	
	return	[_arr objectAtIndex:index];
}
- (NSURL *)firstURL
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT(_arr.count > 0);
	}
	
	////
	
	return	_arr[0];
}
- (NSURL *)lastURL
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT(_arr.count > 0);
	}
	
	////
	
	return	_arr.lastObject;
}
- (instancetype)copy
{
	return	self;
}
- (id)____initWithURLs:(NSArray*)urls
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(urls, NSArray);
		for (id url in urls)
		{
			UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(url, NSURL);
		}
	}
	
	////
	
	self	=	[super init];
	if (self)
	{
		_arr	=	[urls copy];
	}
	return	self;
}
- (id)init
{
	self	=	[super init];
	if (self)
	{
		_arr	=	@[];
	}
	return	self;
}
- (URLList *)listByAddingURL:(NSURL *)url
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(url, NSURL);
	}
	
	////
	
	NSArray*	a2	=	[_arr arrayByAddingObject:url];
	return	[[self class] instantiationWithURLs:a2];
}
- (instancetype)listByAddingURLs:(NSArray *)urls
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(urls, NSArray);
		for (id url in urls)
		{
			UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(url, NSURL);
		}
	}
	
	////
	
	NSArray*	a2	=	[_arr arrayByAddingObjectsFromArray:urls];
	return	[[self class] instantiationWithURLs:a2];
}
- (URLList *)listByInsertingURL:(NSURL *)url atIndex:(NSUInteger)index
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT(index != NSNotFound);
		UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(url, NSURL);
	}
	
	////
	
	NSMutableArray*	a1	=	[_arr mutableCopy];
	[a1 insertObject:url atIndex:index];

	
	return	[[self class] instantiationWithURLs:a1];
}
- (URLList *)listByRemovingURLAtIndex:(NSUInteger)index
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
	}
	
	////
	
	NSMutableArray*	a1	=	[_arr mutableCopy];
	[a1 removeObjectAtIndex:index];
	
	return	[[self class] instantiationWithURLs:a1];
}
- (URLList *)listByRemovingURLsAtIndexes:(NSIndexSet *)indexes
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(indexes, NSIndexSet);
	}
	
	////
	
	NSMutableArray*	a1	=	[_arr mutableCopy];
	[a1 removeObjectsAtIndexes:indexes];
	
	return	[[self class] instantiationWithURLs:a1];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
	return	[_arr countByEnumeratingWithState:state objects:buffer count:len];
}
- (NSString *)description
{
	return	joinArrayItemDescriptionsWithIdentationAndHeading(_arr, NSStringFromClass([self class]));
}
@end








@implementation FileURLList
+ (instancetype)instantiationWithURL:(NSURL *)url
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT([url isFileURL]);
	}
	
	////
	
	return	[super instantiationWithURL:url];
}
+ (instancetype)instantiationWithURLs:(NSArray *)urls
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		for (NSURL* url in urls)
		{
			UNIVERSE_DEBUG_ASSERT([url isFileURL]);
		}
	}
	
	////
	
	return	[super instantiationWithURLs:urls];
}
- (instancetype)listByAddingURL:(NSURL *)url
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT([url isFileURL]);
	}
	
	////
	
	return	[super listByAddingURL:url];
}
- (instancetype)listByAddingURLs:(NSArray *)urls
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT_OBJECT_TYPE(urls, NSArray);
		for (NSURL* url in urls)
		{
			UNIVERSE_DEBUG_ASSERT([url isFileURL]);
		}
	}
	
	////
	
	return	[super listByAddingURLs:urls];
}
- (instancetype)listByInsertingURL:(NSURL *)url atIndex:(NSUInteger)index
{
	if (USE_DEBUGGING_ASSERTIONS)
	{
		UNIVERSE_DEBUG_ASSERT([url isFileURL]);
	}
	
	////
	
	return	[super listByInsertingURL:url atIndex:index];
}
@end
