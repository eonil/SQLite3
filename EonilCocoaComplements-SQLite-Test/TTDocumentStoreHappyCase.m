//
//  TTDocumentStoreHappyCase.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				"TTDocumentStoreHappyCase.h"
#import				"EEDocumentStore.h"




@implementation		TTDocumentStoreHappyCase
- (void)setUp
{
	[super setUp];
}
- (void)tearDown
{
	[super tearDown];
}






- (void)testCreatingdocumentStore
{
	EEDocumentStore*	docs	=	[[EEDocumentStore alloc] init];
	
	STAssertNotNil(docs, @"New instance must be created.");
}
- (void)testInsertingNewDocument
{
	EEDocumentStore*	store	=	[[EEDocumentStore alloc] init];
	
	[store createSectionForName:@"Section1"];
		
	EEDocumentStoreSection*	section1	=	[store sectionForName:@"Section1"];
	NSDictionary*			val1		=	[NSDictionary dictionaryWithObjectsAndKeys:@"1st", @"A", @"2nd", @"B", nil];
	[section1 setDictionaryValue:val1 forCode:@"T001"];
	
	NSDictionary*			val2		=	[section1 dictionaryValueForCode:@"T001"];
	
	STAssertTrue([val1 isEqual:val2], @"In/out values must be equal.");
}
- (void)testInsertingManyRandomDocuments
{
	EEDocumentStore*	store	=	[EEDocumentStore documentStoreInMemory];
	
	[store createSectionForName:@"Section1"];
	
	NSUInteger				samples		=	128;
	EEDocumentStoreSection*	section1	=	[store sectionForName:@"Section1"];
	NSMutableArray*			codelist	=	[NSMutableArray arrayWithCapacity:samples];
	NSMutableArray*			vallist1	=	[NSMutableArray arrayWithCapacity:samples];
	NSMutableArray*			vallist2	=	[NSMutableArray arrayWithCapacity:samples];
	
	
	for (NSUInteger i=0; i<samples; i++)
	{
		NSString*			code		=	[NSString stringWithFormat:@"T:%lld", (long long)i];
		NSDictionary*		val			=	[NSDictionary dictionaryWithObjectsAndKeys:
											 TTMakeRandomLongLongNumber(),		@"field1",
											 TTMakeRandomDoubleNumber(),		@"field2",
											 TTMakeRandomString(),				@"field3",
											 TTMakeRandomData(),				@"field4",
											 nil];
		
		[vallist1 addObject:val];
		[codelist addObject:code];
		[section1 setDictionaryValue:val forCode:code];
	}
	
	for (NSString* code in codelist)
	{
		NSDictionary*		val			=	[section1 dictionaryValueForCode:code];
		[vallist2 addObject:val];
	}

	STAssertTrue([vallist1 isEqual:vallist2], @"In/out values must be equal.");
}

@end



















