//
//  ITCID.h
//  IntervalTreeClock
//
//  Created by Andrew Mackenzie-Ross on 6/03/2014.
//  Copyright (c) 2014 Happy Inspector. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITCID : NSObject
- (instancetype)initWithValue:(NSInteger)value;
- (instancetype)initWithLeft:(ITCID *)left right:(ITCID *)right;
+ (ITCID *)ID0;
+ (ITCID *)ID1;
@property (nonatomic, copy, readonly) ITCID *left;
@property (nonatomic, copy, readonly) ITCID *right;
@property (nonatomic, readonly) NSInteger value;
- (NSArray *)split;
- (instancetype)normalize;
- (instancetype)sum:(ITCID *)obj;
@end
