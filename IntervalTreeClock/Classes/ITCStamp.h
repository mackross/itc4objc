//
//  ITCStamp.h
//  IntervalTreeClock
//
//  Created by Andrew Mackenzie-Ross on 7/03/2014.
//  Copyright (c) 2014 Happy Inspector. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ITCID, ITCEvent;
@interface ITCStamp : NSObject <NSCopying>

- (instancetype)initWithID:(ITCID *)identifier event:(ITCEvent *)event;
@property (nonatomic, readonly) ITCID *identifier;
@property (nonatomic, readonly) ITCEvent *event;
- (NSArray *)fork;
- (NSArray *)peek;
- (instancetype)join:(ITCStamp *)stamp;
- (NSArray *)send;
- (ITCStamp *)touch;
- (ITCStamp *)receive:(ITCStamp *)stamp;
- (NSArray *)sync:(ITCStamp *)stamp;
- (BOOL)leq:(ITCStamp *)stamp;
@end
