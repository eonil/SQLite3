//
//  EEGraphSnapshot.h
//  Spacetime
//
//  Created by Hoon Hwangbo on 6/24/13.
//  Copyright (c) 2013 Eonil. All rights reserved.
//

#import <Foundation/Foundation.h>









//@class		EEGraphVertex;
//@class		EEGraphEdge;

typedef		int64_t								EEGraphComponentID;			//!	Only positive values are valid.
typedef		struct EEGraphVertex				EEGraphVertex;
typedef		struct EEGraphEdge					EEGraphEdge;
typedef		struct EEGraphVertexStatePassing	EEGraphVertexStatePassing;
typedef		struct EEGraphEdgeStatePassing		EEGraphEdgeStatePassing;

@protocol	EEGraphVertexSet;
@protocol	EEGraphEdgeSet;
@protocol	EEGraphSnapshot;
@protocol	EEGraphSnapshotOptimization;
@protocol	EEGraphMutableSnapshot;



struct
EEGraphVertex
{
	EEGraphComponentID	ID;
};

struct
EEGraphEdge
{
	EEGraphComponentID	ID;
};

struct
EEGraphVertexStatePassing
{
	__unsafe_unretained	NSData*	data;
};
struct
EEGraphEdgeStatePassing
{
	EEGraphEdge	from;
	EEGraphEdge	to;
	__unsafe_unretained	NSData*	data;
};

@protocol	EEGraphVertexSet
@property	(readonly,nonatomic,assign)		NSUInteger		numberOfVertexes;
- (EEGraphVertex)vertexAtIndex:(NSUInteger)index;
@end

@protocol	EEGraphEdgeSet
@property	(readonly,nonatomic,assign)		NSUInteger		numberOfEdges;
- (EEGraphEdge)edgeAtIndex:(NSUInteger)index;
@end


@protocol	EEGraphSnapshot
@property	(readonly,nonatomic,assign)		NSUInteger		numberOfVertexes;
@property	(readonly,nonatomic,assign)		NSUInteger		numberOfEdges;
- (EEGraphVertexStatePassing)stateForVertex:(EEGraphVertex)vertex;
- (EEGraphEdgeStatePassing)stateForEdge:(EEGraphEdge)edge;
@end

@protocol	EEGraphSnapshotOptimization
- (NSUInteger)lengthOfDataOfVertex:(EEGraphVertex)vertex;
- (NSUInteger)lengthOfDataOfEdge:(EEGraphEdge)edge;
- (NSData*)	dataOfVertex:(EEGraphVertex)vertex;
- (NSData*)	dataOfVertex:(EEGraphVertex)vertex range:(NSRange)range;
- (NSData*)	dataOfEdge:(EEGraphEdge)edge;
- (NSData*)	dataOfEdge:(EEGraphEdge)edge range:(NSRange)range;
- (EEGraphVertex)originVertexOfEdge:(EEGraphEdge)edge;
- (EEGraphVertex)destinationVertexOfEdge:(EEGraphEdge)edge;
- (id <EEGraphEdgeSet>)edgesFromVertex:(EEGraphVertex)vertex;
- (id <EEGraphEdgeSet>)edgesToVertex:(EEGraphVertex)vertex;
@end



/*!
 All mutator operations should be atomic.
 */
@protocol	EEGraphMutableSnapshot <EEGraphSnapshot>
- (EEGraphVertex)addVertexWithState:(EEGraphVertexStatePassing)state;
- (EEGraphEdge)addEdgeWithState:(EEGraphEdgeStatePassing)state;
- (void)	removeVertex:(EEGraphVertex)vertex;
- (void)	removeEdge:(EEGraphEdge)edge;
//- (void)	setState:(EEGraphVertexStatePassing)state forVertex:(EEGraphVertex)vertex;
//- (void)	setState:(EEGraphEdgeStatePassing)state forEdge:(EEGraphEdge)edge;
//- (void)	setOriginVertex:(EEGraphVertex)vertex;
//
//- (void)	setOriginVertex:(EEGraphVertex)vertex ofEdge:(EEGraphEdge)edge;
//- (void)	setDestinationVertex:(EEGraphVertex)vertex ofEdge:(EEGraphEdge)edge;
//- (void)	setData:(NSData*)data ofVertex:(EEGraphVertex)vertex;
//- (void)	setData:(NSData*)data ofEdge:(EEGraphEdge)edge;
//@optional
//- (BOOL)	performAtomicOperationUsingBlock:(BOOL(^)())block;		//!	@param	block	Return `YES` to commit, `NO` to rollback.	@result	The result of the block.
@end
//
//




















/*!
 Default in-memory implementation of graph snapshot.
 */
@interface	EEGraphSnapshot : NSObject <EEGraphSnapshot>
- (id)		initWithSnapshot:(id <EEGraphSnapshot>)other;
- (BOOL)	isEqualToSnapshot:(id <EEGraphSnapshot>)snapshot;
@end

@interface	EEGraphSnapshot (EEGraphSnapshotOptimization) <EEGraphSnapshotOptimization>
@end


@interface	EEGraphSnapshot (EEGraphSnapshotExtras)
//+ (BOOL)equalityOfSnapshot:(id<EEGraphSnapshot>)g0 andSnapshot:(id<EEGraphSnapshot>)g1;
//+ (NSDictionary*)allVertexDataOfSnapshot:(id<EEGraphSnapshot>)snapshot;						//!	NSNumber(EEGraphComponentID) -> NSData
//+ (NSDictionary*)allEdgeDataOfSnapshot:(id<EEGraphSnapshot>)snapshot;						//!	NSNumber(EEGraphComponentID) -> NSData
@end





@interface	EEGraphComponentIDSet : NSObject <EEGraphVertexSet, EEGraphEdgeSet>
- (id)		initWithComponentIDArray:(EEGraphComponentID const*)componentIDArray count:(NSUInteger)count;
@end















