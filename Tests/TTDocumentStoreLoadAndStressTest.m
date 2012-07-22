//
//  TTDocumentStoreLoadAndStressTest.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				"TTDocumentStoreLoadAndStressTest.h"
#import				"EEDocumentStore.h"

@implementation		TTDocumentStoreLoadAndStressTest

- (void)testMemoryLeak
{
	EEDocumentStore*		store	=	[EEDocumentStore documentStoreInMemory];
	
	NSUInteger				seclen	=	1024;
	NSUInteger				doclen	=	1024;
	
	for (NSUInteger i=0; i<seclen; i++)
	{
		NSString*	secnm	=	[NSString stringWithFormat:@"Section %llu", (unsigned long long)i];
		
		[store createSectionForName:secnm];	
		
		EEDocumentStoreSection*	sec	=	[store sectionForName:secnm];
		
		for (NSUInteger D=0; D<doclen; D++)
		{
			NSString*			code		=	[NSString stringWithFormat:@"D:%llu", (unsigned long long)i];
			NSDictionary*		val			=	[NSDictionary dictionaryWithObjectsAndKeys:
												 TTMakeRandomLongLongNumber(),		@"field1",
												 TTMakeRandomDoubleNumber(),		@"field2",
												 TTMakeRandomString(),				@"field3",
												 TTMakeRandomData(),				@"field4",
												 nil];
			
			[sec setDictionaryValue:val forCode:code];
		}
		
		NSLog(@"store = %@, #%llu/%llu", store, (unsigned long long)i, (unsigned long long)seclen);
	}
}

@end
