////
////  EEDocumentStore.h
////  EonilCocoaComplements-SQLite
////
////  Created by Hoon Hwangbo on 1/22/12.
////  Copyright (c) 2012 Eonil Company. All rights reserved.
////
//
//
//typedef				long long		EEDocumentID;
//
//extern
//NSString* const		EEDocumentStoreErrorDomain;
//
//
//@class				EEDocumentStore;
//@class				EEDocumentStoreSection;
//
///*!
// A simple document store based on SQLite3 engine.
// 
// @deprecated
// This class is deprecated. Do not use this.
// Preserved for legacy code support purpose.
// 
// @warning
// This class is designed to be a full abstraction layer on top of SQLite3 database.
// This means you should not touch or access the underlying SQLite3 database directly
// becaue it will break the abstraction, and will bring internal state inconsistency
// which means database corruption. Nothing is doable on corrupted database.
// 
// @discussion 
// All document will have automatic rowid in SQLite3.
// And also, all document will have document *code* for each document.
// This is also a Primary key, which is slower than rowid, but a lot flexible.
// */
//@interface			EEDocumentStore : NSObject
//
//- (NSSet*)						allSections;
//- (EEDocumentStoreSection*)		sectionForName:(NSString*)sectionName;
//- (void)						createSectionForName:(NSString*)sectionName;
//- (void)						deleteSectionForName:(NSString*)sectionName;
//
//- (id)					init;											//	Makes a new temporary, in-memory store.
//- (id)					initWithStorageAtPath:(NSString*)path;			//	Makes a new persistent, on-disk store.
//
//+ (EEDocumentStore*)	documentStoreAtPath:(NSString*)pathToDocumentStore;
//+ (EEDocumentStore*)	documentStoreInMemory;
//
//@end
//
//
//
//
//
///*!
// @discussion
// All value used in document must be able to be stored as *Property List* format.
// This means, only specific data typed are allowed. If the value contains any of 
// non-compatible value, the operation will be no-op or return `nil`.
// If you use method with error argument, you can check the error.
// */
//@interface			EEDocumentStoreSection : NSObject
//@property			(readonly,nonatomic)	NSString*		name;
//- (NSDictionary*)	dictionaryValueForCode:(NSString*)code;
//- (void)			setDictionaryValue:(NSDictionary*)dictionaryValue forCode:(NSString*)code;
//
//@end
//
//
//
//
//
//
//
//
//
//
///*!
// Proposal for new design.
// @classdesign
// Document store stores binary data with integer ID and tags.
// ID is an integer key and it is actually ROWID.
// Tag is a string column contains arbtrary text. This is exist to help searching 
// an entry by storing text-based metadata because binary content itself is not 
// searchable. Anyway if you need more regular metadata, you must use regular SQLite
// table directly.
//*/
//
//
//
//
//
//
//
//
//
//
//
