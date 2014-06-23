//
//  EEGraphEditor.h
//  Spacetime
//
//  Created by Hoon Hwangbo on 6/24/13.
//  Copyright (c) 2013 Eonil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EEGraphSnapshot.h"
#import "EEGraphTimeline.h"




@class		EEGraphVertexProxy;
@class		EEGraphEdgeProxy;






@interface	EEGraphEditor : NSObject
- (id)		initWithTimeline:(id<EEGraphMutableTimeline>)timeline;
@end

/*!
 @note
 Graph snapshot can store arbitrary graph, but editor supports only
 single rooted graph. The root vertex must have ID of 1.
 */
@interface	EEGraphEditor (EEGraphUtility)
- (EEGraphVertexProxy*)vertex;
- (EEGraphVertexProxy*)edge;
- (EEGraphVertexProxy*)vertexForID:(EEGraphVertex)vertexID;
- (EEGraphEdgeProxy*)edgeForID:(EEGraphEdge)edgeID;
@end







@interface	EEGraphVertexProxy : NSObject
@property	(readonly,nonatomic,strong)		EEGraphEditor*		editor;
@property	(readonly,nonatomic,assign)		EEGraphVertex		ID;
@property	(readwrite,nonatomic,copy)		NSData*				data;
- (BOOL)	isEqualToGraphVertexProxy:(EEGraphVertexProxy*)other;
- (EEGraphEdgeProxy*)edgeToVertex:(EEGraphVertexProxy*)other;
- (EEGraphEdgeProxy*)edgeFromVertex:(EEGraphVertexProxy*)other;
- (NSSet*)	allOutgoingEdges;
- (NSSet*)	allIncomingEdges;
- (EEGraphEdgeProxy*)constructEdgeToVertex:(EEGraphVertexProxy*)vertex;
- (EEGraphEdgeProxy*)constructEdgeFromVertex:(EEGraphVertexProxy*)vertex;
- (void)	destroyWithAllEdges;
@end

@interface	EEGraphVertexProxy (EEGraphEditorUtility)
- (EEGraphEdgeProxy*)anyEdgeWithData:(NSData*)data;				//!	Gets random edge which has the data.
- (EEGraphEdgeProxy*)anyIncomingEdgeWithData:(NSData*)data;
- (EEGraphEdgeProxy*)anyOutgoingEdgeWithData:(NSData*)data;
@end




@interface	EEGraphEdgeProxy : NSObject
@property	(readonly,nonatomic,strong)		EEGraphEditor*		editor;
@property	(readonly,nonatomic,assign)		EEGraphEdge			ID;
@property	(readwrite,nonatomic,copy)		NSData*				data;
- (BOOL)	isEqualToGraphEdgeProxy:(EEGraphEdgeProxy*)other;
- (EEGraphVertexProxy*)originVertex;
- (EEGraphVertexProxy*)destinationVertex;
- (void)	destroy;
@end


//@interface	EEGraphVertex (EEGraphUtility)
//- (NSSet*)	outgoingEdges;
//- (NSSet*)	incomingEdges;
//- (NSData*)	data;
//@end
//@interface	EEGraphEdge (EEGraphUtility)
//- (EEGraphVertex*)originVertex;
//- (EEGraphVertex*)destinationVertex;
//@end