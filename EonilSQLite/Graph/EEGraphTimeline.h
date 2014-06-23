//
//  EEGraphTimeline.h
//  Spacetime
//
//  Created by Hoon Hwangbo on 6/24/13.
//  Copyright (c) 2013 Eonil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EEGraphSnapshot.h"




@class		EEGraphOp;
@class		EEGraphEvent;

@protocol	EEGraphKeymaker;

@protocol	EEGraphTimeline;
@protocol	EEGraphMutableTimeline;






typedef
enum
EEGraphElementType
{
	EEGraphElementTypeVertex,
	EEGraphElementTypeEdge,
}
EEGraphElementType;

typedef
enum
EEGraphOperation
{
	EEGraphOperationAdd,
	EEGraphOperationRemove,
}
EEGraphOperation;






@interface	EEGraphOp : NSObject
@property	(readonly,nonatomic,strong)		EEGraphEvent*		event;
@property	(readonly,nonatomic,assign)		EEGraphElementType	type;
@property	(readonly,nonatomic,assign)		EEGraphOperation	operation;
@property	(readonly,nonatomic,assign)		NSUInteger			targetID;			
@property	(readonly,nonatomic,assign)		NSUInteger			originID;			//	If target is vertex, this is always `0` which means `nil`.
@property	(readonly,nonatomic,assign)		NSUInteger			destinationID;		//	If target is vertex, this is always `0` which means `nil`.
@property	(readonly,nonatomic,copy)		NSData*				data;
@end

@interface	EEGraphEvent : NSObject
@property	(readonly,nonatomic,strong)		id<EEGraphTimeline>	timeline;
@property	(readonly,nonatomic,copy)		NSString*			name;
@property	(readonly,nonatomic,copy)		NSArray*			ops;
@end








@protocol	EEGraphTimeline
@property	(readonly,nonatomic,copy)		id<EEGraphSnapshot>	present;			//!	Represents current accumulated state.
@property	(readonly,nonatomic,strong)		NSArray*			history;			//!	Array of `EEGraphEvent`. Latter is recent.
@property	(readonly,nonatomic,strong)		NSArray*			destiny;			//!	Array of `EEGraphEvent`. Latter is recent.
@end

/*!
 Mutations must be applied to a snapshot exposed via `present` property.
 */
@protocol	EEGraphMutableTimeline <EEGraphTimeline>
- (void)	scheduleDestiny:(EEGraphEvent*)event;
- (void)	replayDestiny;
- (void)	rewindHistory;
- (void)	forgetHistory;
- (void)	clearAllHistory;
- (void)	clearAllDestiny;
@end














/*!
 Default in-memory implementation of graph-timeline.
 Stores logs in-memory. Snapshot store is separated.
 */
@interface	EEGraphTimeline : NSObject <EEGraphTimeline>

@end













