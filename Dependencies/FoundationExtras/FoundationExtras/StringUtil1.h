//
//  StringUtil1.h
//  DupeDetector
//
//  Created by Hoon H. on 2014/06/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

#import <Foundation/Foundation.h>


//NSString*	indentLines(NSString* s1);
//NSString*	joinArrayItemDescriptionsWithIdentationAndHeading(NSArray* objects, NSString* heading);
//NSString*	joinDictionaruPairDescriptionsWithIndentationAndHeading(NSDictionary* pairs, NSString* heading);
//NSString*	formatAsHex(NSUInteger v);



static inline NSString*
indentLines(NSString* s1)
{
	NSArray*	ls1	=	[s1 componentsSeparatedByString:@"\n"];
	NSArray*	ls2		=	@[];
	for (NSString* s2 in ls1)
	{
		NSString*	s3	=	[@"\t" stringByAppendingString:s2];
		ls2	=	[ls2 arrayByAddingObject:s3];
	}
	
	NSString*	s4	=	[ls2 componentsJoinedByString:@"\n"];
	return	s4;
}



static inline NSString*
joinArrayItemDescriptionsWithIdentationAndHeading(NSArray* objects, NSString* heading)
{
	NSString*	s1	=	@"";
	for (id o2 in objects)
	{
		s1	=	[s1 stringByAppendingString:[o2 description]];
		s1	=	[s1 stringByAppendingString:@"\n"];
	}
	NSString*	s3	=	indentLines(s1);
	NSString*	s4	=	[[heading stringByAppendingString:@"\n"] stringByAppendingString:s3];
	return		s4;
}



static inline NSString*
joinDictionaruPairDescriptionsWithIndentationAndHeading(NSDictionary* pairs, NSString* heading)
{
	NSArray*	lns	=	@[];
	for (id k in pairs)
	{
		id			v		=	pairs[k];
		
		NSString*	kdesc	=	[k description];
		NSString*	vdesc	=	[v description];
		NSString*	kvdesc	=	[NSString stringWithFormat:@"%@: %@", kdesc, vdesc];
		
		lns	=	[lns arrayByAddingObject:kvdesc];
	}
	return	joinArrayItemDescriptionsWithIdentationAndHeading(lns, heading);
}



static inline NSString*
formatAsHex(NSUInteger v)
{
	return	[NSString stringWithFormat:@"%zx", (unsigned long)v];
}


