//
//  EEGraphDatabase.h
//  Spacetime
//
//  Created by Hoon Hwangbo on 6/23/13.
//  Copyright (c) 2013 Eonil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEGraphTimeline.h"




/*!
 On-disk implementation of graph using SQLite3.
 */
@interface 	EEGraphDatabase : NSObject
@property	(readonly,nonatomic,strong)		id<EEGraphSnapshot>		snapshot;
@property	(readonly,nonatomic,strong)		id<EEGraphTimeline>		timeline;
@property	(readonly,nonatomic,strong)		NSDictionary*			parameters;
@end
