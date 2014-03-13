//
//  ITCEvent.h
//  IntervalTreeClock
//
//  Created by Andrew Mackenzie-Ross on 6/03/2014.
//  Copyright (c) 2014 Happy Inspector. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITCEvent : NSObject

- (instancetype)initWithValue:(NSInteger)value;
- (instancetype)initWithValue:(NSInteger)value left:(ITCEvent *)left right:(ITCEvent *)right;
@property (nonatomic, copy, readonly) ITCEvent *left;
@property (nonatomic, copy, readonly) ITCEvent *right;
@property (nonatomic, readonly) NSInteger value;

- (NSInteger)maxDepth;
- (ITCEvent *)join:(ITCEvent *)event2;
- (BOOL)leq:(ITCEvent *)e2;
- (instancetype)normalize;

- (BOOL)isValueOnly;
- (NSInteger)max;
- (NSInteger)min;
@end
