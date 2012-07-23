//
//  EEDocumentStore.m
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				"EEDocumentStore.h"
#import				"EESQLiteDatabase.h"
#import				"EESQLiteDatabase+CommandExecution.h"
#import				"EESQLiteDatabase+Schema.h"
#import				"EESQLiteDatabase+SimpleQuery.h"
#import				"EESQLiteStatement.h"


#define				ID_COLUMN				@"rid"
#define				CODE_COLUMN				@"code"
#define				PAYLOAD_COLUMN			@"payload"




NSString* const		EEDocumentStoreErrorDomain = @"EEDocumentStoreErrorDomain";










inline
static 
NSError*
EEDocumentStoreInvalidValueForPropertyListError(NSError* underlyingError)
{
	NSDictionary*	info	=	[NSDictionary dictionaryWithObjectsAndKeys:
								 @"The value cannot be stored as Property List format.", NSLocalizedDescriptionKey,
								 underlyingError, NSUnderlyingErrorKey,
								 nil];
	
	return	[NSError errorWithDomain:EEDocumentStoreErrorDomain code:1 userInfo:info];
}











@interface			EEDocumentStoreSection ()
- (id)				initWithDatabase:(EESQLiteDatabase*)database tableName:(NSString*)tableName;
@end





















@implementation		EEDocumentStore
{
	EESQLiteDatabase*	db;
	NSMutableSet*		secs;
}
- (NSSet *)allSections
{
	return	secs;
}
- (EEDocumentStoreSection *)sectionForName:(NSString *)sectionName
{
	for (EEDocumentStoreSection* sec in secs)
	{
		if ([[sec name] isEqualToString:sectionName])
		{
			return	sec;
		}
	}
	return	nil;
}
- (void)createSectionForName:(NSString *)sectionName
{
	NSMutableArray*		colnms		=	[NSMutableArray arrayWithObjects:CODE_COLUMN, PAYLOAD_COLUMN, nil];
	[db addTableWithName:sectionName withColumnNames:colnms];
	
	EEDocumentStoreSection*	sec	=	[[EEDocumentStoreSection alloc] initWithDatabase:db tableName:sectionName];
	[secs addObject:sec];
}
- (void)deleteSectionForName:(NSString *)sectionName
{
	EEDocumentStoreSection*	sec	=	[self sectionForName:sectionName];
	[secs removeObject:sec];
	
	[db removeTableWithName:sectionName];
}






- (NSString *)description
{
	return	[NSString stringWithFormat:@"<%@>(db = %@)", NSStringFromClass([self class]), db];
}
- (id)initWithSQLiteDatabase:(EESQLiteDatabase*)database
{
	self	=	[super init];
	
	if (self)
	{
		db		=	database;
		secs	=	[NSMutableSet set];
		
		for (NSString* tbl in [db allTableNames])
		{
			EEDocumentStoreSection*	sec	=	[[EEDocumentStoreSection alloc] initWithDatabase:db tableName:tbl];
			
			[secs addObject:sec];
		}
	}
	
	return	self;
}
- (id)init
{
	return	self	=	[self initWithSQLiteDatabase:[EESQLiteDatabase temporaryDatabaseInMemory]];
}
- (id)initWithStorageAtPath:(NSString *)path
{
	return	self	=	[self initWithSQLiteDatabase:[EESQLiteDatabase persistentDatabaseOnDiskAtPath:path]];
}


+ (EEDocumentStore *)documentStoreAtPath:(NSString *)pathToDocumentStore
{
	return	[[self alloc] initWithSQLiteDatabase:[EESQLiteDatabase persistentDatabaseOnDiskAtPath:pathToDocumentStore]];
}
+ (EEDocumentStore *)documentStoreInMemory
{
	return	[[self alloc] initWithSQLiteDatabase:[EESQLiteDatabase temporaryDatabaseInMemory]];
}

@end





























































@implementation		EEDocumentStoreSection
{
	EESQLiteDatabase*		db;
	NSString*				tbl;
}
- (NSString *)name
{
	return			tbl;
}
- (id)				EEDocumentStoreSectionPropertyListValueFromData:(NSData*)data error:(NSError *__autoreleasing *)error
{
	return			[NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:error];
}
- (NSData*)			EEDocumentStoreSectionDataFromPropertyListValue:(id)value error:(NSError *__autoreleasing *)error
{
	return			[NSPropertyListSerialization dataWithPropertyList:value format:NSPropertyListBinaryFormat_v1_0 options:0 error:error];
}

- (NSDictionary *)dictionaryValueForCode:(NSString *)code
{
	return	[self dictionaryValueForCode:code error:NULL];
}
- (NSDictionary *)dictionaryValueForCode:(NSString *)code error:(NSError *__autoreleasing *)error;
{
	NSString*	cmd		=	[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@';", tbl, CODE_COLUMN, code];
	NSArray*	list	=	[db arrayOfRowsByExecutingSQL:cmd];
	
	if ([list count] == 0)
	{
		return	nil;
	}
	else
	{
		NSData*		payload	=	[[list lastObject] objectForKey:PAYLOAD_COLUMN];
		id			value	=	[self EEDocumentStoreSectionPropertyListValueFromData:payload error:NULL];
		return		value;
	}
}
- (void)setDictionaryValue:(NSDictionary *)dictionaryValue forCode:(NSString *)code
{
	[self setDictionaryValue:dictionaryValue forCode:code error:NULL];
}
- (BOOL)setDictionaryValue:(NSDictionary *)dictionaryValue forCode:(NSString *)code error:(NSError *__autoreleasing *)error
{	
	NSError*		inerr	=	nil;
	NSData*			payload	=	[self EEDocumentStoreSectionDataFromPropertyListValue:dictionaryValue error:&inerr];
	
	if (inerr != nil)
	{
		if (error != NULL) 
		{
			*error	=	inerr;
		}
	}
	else 
	{
		[db executeTransactionBlock:^BOOL
		{
			NSDictionary*	olddoc	=	[self dictionaryValueForCode:code];
			NSDictionary*	newdoc	=	[NSDictionary dictionaryWithObjectsAndKeys:
										 payload, PAYLOAD_COLUMN,
										 code, CODE_COLUMN,
										 [olddoc objectForKey:ID_COLUMN], ID_COLUMN,
										 nil];
			
			if (olddoc == nil)
			{
				NSError*		operr	=	nil;

				[db insertDictionaryValue:newdoc intoTable:tbl error:&operr];
				
				return			operr	==	nil;
			}
			else 
			{
				NSError*		operr	=	nil;
				NSString*		filtexp	=	[NSString stringWithFormat:@"'%@' = '%@'", ID_COLUMN, [newdoc objectForKey:ID_COLUMN]];
				
				[db updateTable:tbl withDictionaryValue:newdoc filteringSQLExpression:filtexp error:&operr];
				
				return			operr	==	nil;
			}
		}];
	}
	
	return	YES;
}




- (NSUInteger)hash
{
	return	[tbl hash];
}
- (BOOL)isEqual:(id)object
{
	EEDocumentStoreSection*		other	=	object;
	
	return	[db isEqual:other->db] && [tbl isEqualToString:other->tbl];
}

- (id)initWithDatabase:(EESQLiteDatabase *)database tableName:(NSString *)tableName
{
	self	=	[super init];
	
	if (self)
	{
		db		=	database;
		tbl		=	tableName;
	}
	
	return	self;
}
@end








