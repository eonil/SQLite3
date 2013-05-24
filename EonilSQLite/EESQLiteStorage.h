//
//  EESQLiteStorage.h
//  EonilSQLite
//
//  Created by Hoon Hwangbo on 5/24/13.
//  Copyright (c) 2013 Eonil Company. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Simple access to SQLite database.
 
 All method of this class will throw an exception for any underlying errors.
 */
@interface 	EESQLiteStorage : NSObject
@end

@interface	EESQLiteStorage (EESQLiteFactory)
+ (id)		storageInMemory;
+ (id)		storageAtPath:(NSString*)path;
@end

@interface	EESQLiteStorageSection : NSObject
- (NSUInteger)countOfAllItems;
- (NSArray*)arrayOfAllItems;
- (NSArray*)arrayOfItems;
- (NSDictionary*)itemForID;
@end
