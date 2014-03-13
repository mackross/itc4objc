//
//  ITCID.m
//  IntervalTreeClock
//
//  Created by Andrew Mackenzie-Ross on 6/03/2014.
//  Copyright (c) 2014 Happy Inspector. All rights reserved.
//

#import "ITCID.h"

@interface ITCID () <NSCopying>

@property (nonatomic) ITCID *left;
@property (nonatomic) ITCID *right;
@property (nonatomic) NSInteger value;

@end

@implementation ITCID

+ (ITCID *)ID0 {
    static ITCID *ID0 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ID0 = [[self alloc] initWithValue:0];
    });
    return ID0;
}

+ (ITCID *)ID1 {
    static ITCID *ID1 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ID1 = [[self alloc] initWithValue:1];
    });
    return ID1;
}

- (instancetype)initWithValue:(NSInteger)value {
    self = [super init];
    if (!self) return nil;

    _value = value;

    return self;
}

- (instancetype)initWithLeft:(ITCID *)left right:(ITCID *)right {
    self = [super init];
    if (!self) return nil;

    _left = left;
    _right = right;
    _value = -1;

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ITCID *copy = [[ITCID alloc] init];
    copy.left = [self.left copy];
    copy.right = [self.right copy];
    copy.value = self.value;
    return copy;
}


- (BOOL)isEqual:(ITCID *)obj {
    if (![obj isKindOfClass:[self class]]) return NO;
    if ((!self.left && obj.left) || (self.left && !obj.left)) return NO;
    if ((!self.right && obj.right) || (self.right && !obj.right)) return NO;
    if (!self.left && !obj.right && !self.right && !obj.right) return self.value == obj.value;
    if (self.left && obj.left && self.right && obj.right) return [self.left isEqual:obj.left] && [self.right isEqual:obj.right];
    return NO;
}

- (instancetype)normalize {
    ITCID *copy = [self copy];
    copy.right = [copy.right normalize];
    copy.left = [copy.left normalize];
    if (!copy.left && !copy.right) {
        if (copy.value == 0) return [[ITCID ID0] copy];
        if (copy.value == 1) return [[ITCID ID1] copy];
    }
    if ([copy.left isEqual:[ITCID ID0]] && [copy.right isEqual:[ITCID ID0]]) return [[ITCID ID0] copy];
    if ([copy.left isEqual:[ITCID ID1]] && [copy.right isEqual:[ITCID ID1]]) return [[ITCID ID1] copy];
    return copy;
}

- (NSArray *)split {
    if ([self isEqual:[ITCID ID0]]) return @[[[ITCID ID0] copy],[[ITCID ID0] copy]];
    if ([self isEqual:[ITCID ID1]]) return @[
                                             [[ITCID alloc] initWithLeft:[[ITCID ID1] copy] right: [[ITCID ID0] copy]],
                                             [[ITCID alloc] initWithLeft:[[ITCID ID0] copy] right: [[ITCID ID1] copy]]
                                             ];
    if ([self.left isEqual:[ITCID ID0]]) {
        NSArray *rightSplit = [self.right split];
        return @[
                 [[ITCID alloc] initWithLeft:[[ITCID ID0] copy] right:rightSplit[0]],
                  [[ITCID alloc] initWithLeft:[[ITCID ID0] copy] right:rightSplit[1]]
                 ];
    }
    if ([self.right isEqual:[ITCID ID0]]) {
        NSArray *leftSplit = [self.left split];
        return @[
                 [[ITCID alloc] initWithLeft:leftSplit[0] right:[[ITCID ID0] copy]],
                 [[ITCID alloc] initWithLeft:leftSplit[1] right:[[ITCID ID0] copy]]
                 ];
    }
    return @[
             [[ITCID alloc] initWithLeft:self.left right:[[ITCID ID0] copy]],
             [[ITCID alloc] initWithLeft:[[ITCID ID0] copy] right:self.right]
             ];
}

- (instancetype)sum:(ITCID *)obj {
    NSParameterAssert(obj);
    if ([self isEqual:[ITCID ID0]]) return obj;
    if ([obj isEqual:[ITCID ID0]]) return self;
    ITCID *sumLeft = [self.left sum:obj.left];
    ITCID *sumRight = [self.right sum:obj.right];
    ITCID *sum = [[ITCID alloc] initWithLeft:sumLeft right:sumRight];
    return [sum normalize];
}

- (NSString *)description {
    if (!self.left && !self.right) return [@(self.value) stringValue];
    if ([self.left isEqual:[ITCID ID0]]) {
        return [NSString stringWithFormat:@"(0, %@)",self.right];
    }
    if ([self.right isEqual:[ITCID ID0]]) {
        return [NSString stringWithFormat:@"(%@, 0)",self.left];
    }
    return [NSString stringWithFormat:@"(%@, %@)", self.left, self.right];
}

@end
