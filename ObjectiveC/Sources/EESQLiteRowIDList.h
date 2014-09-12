//
//  EESQLiteRowIDList.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/23/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef				long long		EESQLiteRowID;






@interface			EESQLiteRowIDList : NSObject
@property			(readonly,nonatomic)			NSUInteger		count;
- (EESQLiteRowID)	rowIDAtIndex:(NSUInteger)index;
- (EESQLiteRowID)	lastRowID;
- (id)				initWithRowIDs:(EESQLiteRowID[])rowIDs count:(NSUInteger)count;
@end

@interface			EESQLiteMutableRowIDList : EESQLiteRowIDList
- (void)			appendRowIDs:(EESQLiteRowID[])rowIDs count:(NSUInteger)count;
- (void)			appendRowIDsFromList:(EESQLiteRowIDList*)list;
- (void)			appendRowID:(EESQLiteRowID)rowID;
@end



