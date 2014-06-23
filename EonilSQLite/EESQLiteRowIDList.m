//
//  EESQLiteRowIDList.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import	"EESQLiteRowIDList.h"
#import "EESQLiteCommon.h"






@implementation		EESQLiteRowIDList
{
	@protected
	NSMutableData*	buffer;
}
- (NSUInteger)count
{
	return	[buffer length] / sizeof(EESQLiteRowID);
}
- (EESQLiteRowID)rowIDAtIndex:(NSUInteger)index
{
	EESQLiteRowID*	mem		=	(EESQLiteRowID*)[buffer bytes];
	EESQLiteRowID*	newmem	=	mem + index;
	return			*newmem;
}
- (EESQLiteRowID)lastRowID
{
	return	[self rowIDAtIndex:[self count] - 1];
}
- (id)init
{
	return	self	=	[self initWithRowIDs:NULL count:0];
}
- (id)initWithRowIDs:(EESQLiteRowID [])rowIDs count:(NSUInteger)count
{
	self	=	[super init];
	
	if (self)
	{
		buffer	=	[[NSMutableData alloc] initWithBytes:(const void *)rowIDs length:sizeof(EESQLiteRowID) * count];
	}
	
	return	self;
}
@end








@implementation		EESQLiteMutableRowIDList
- (void)appendRowIDs:(EESQLiteRowID [])rowIDs count:(NSUInteger)count
{
	[buffer appendBytes:(const void *)rowIDs length:sizeof(EESQLiteRowID) * count];
}
- (void)appendRowIDsFromList:(EESQLiteRowIDList *)list
{
	[buffer appendData:list->buffer];
}
- (void)appendRowID:(EESQLiteRowID)rowID
{
	[buffer appendBytes:(const void *)&rowID length:sizeof(EESQLiteRowID)];
}
@end























