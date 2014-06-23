//
//  URLList.h
//  FoundationExtras
//
//  Created by Hoon H. on 2014/06/15.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

#import "BasicObject.h"

/*!
 Strogly typed array of @c NSURL .
 */
@interface	URLList : BasicObject <NSFastEnumeration>
@property	(readonly,nonatomic,assign)		NSUInteger		count;
- (NSURL*)	urlAtIndex:(NSUInteger)index;
- (NSURL*)	firstURL;
- (NSURL*)	lastURL;
+ (instancetype)instantiation;
+ (instancetype)instantiationWithURL:(NSURL*)url;
+ (instancetype)instantiationWithURLs:(NSArray*)urls;
- (instancetype)copy;
- (instancetype)listByAddingURL:(NSURL*)url;
- (instancetype)listByAddingURLs:(NSArray*)urls;
- (instancetype)listByInsertingURL:(NSURL *)url atIndex:(NSUInteger)index;		///	@param	@c index Shouldn't be @c NSNotFound .
- (instancetype)listByRemovingURLAtIndex:(NSUInteger)index;
- (instancetype)listByRemovingURLsAtIndexes:(NSIndexSet*)indexes;
@end

/*!
 Strongly typed array of @c NSURL .
 
 @note
 Internally this just adds type assertions.
 */
@interface FileURLList : URLList
@end
