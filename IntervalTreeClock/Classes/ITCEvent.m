//
//  ITCEvent.m
//  IntervalTreeClock
//
//  Created by Andrew Mackenzie-Ross on 6/03/2014.
//  Copyright (c) 2014 Happy Inspector. All rights reserved.
//

#import "ITCEvent.h"

@implementation ITCEvent

- (instancetype)initWithValue:(NSInteger)value {
    self = [super init];
    if (!self) return nil;

    _value = value;

    return self;
}

- (instancetype)initWithValue:(NSInteger)value left:(ITCEvent *)left right:(ITCEvent *)right {
    self = [super init];
    if (!self) return nil;

    _left = [left copy];
    _right = [right copy];
    _value = value;

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[ITCEvent alloc] initWithValue:self.value left:self.left right:self.right];
}


- (instancetype)lift:(NSInteger)m {
    if (!self.left && !self.right) return [[ITCEvent alloc] initWithValue:(self.value + m)];
    return [[ITCEvent alloc] initWithValue:(self.value + m) left:self.left right:self.right];
}

- (instancetype)sink:(NSInteger)m {
    return [self lift:-m];
}

- (NSInteger)min {
    if (!self.left && !self.right) return self.value;
    return self.value + MIN([self.left min],[self.right min]);
}

- (NSInteger)max {
    if (!self.left && !self.right) return self.value;
    if (self.left && self.right) {
        return self.value + MAX([self.left max], [self.right max]);
    }
    [NSException raise:NSInternalInconsistencyException format:@"Each node must have either two children or no child."];
    return 0;
}

- (instancetype)normalize {
    if (!self.left && !self.right) return [[ITCEvent alloc] initWithValue:self.value];
    if (self.left && self.right && [self.left isValueOnly] && [self.right isValueOnly] && self.left.value == self.right.value) {
        return [[ITCEvent alloc] initWithValue:(self.value + self.left.value )];
    }
    if (self.left && self.right) {
        NSInteger m = MIN([self.left min], [self.right min]);
        return [[ITCEvent alloc] initWithValue:self.value + m left:[self.left sink:m] right:[self.right sink:m]];
    }
    [NSException raise:NSInternalInconsistencyException format:@"Each node must have either two children or no child."];
    return nil;
}

- (BOOL)isValueOnly {
    return !self.left && !self.right;
}

- (BOOL)innerLeq:(ITCEvent *)e2 {
    ITCEvent *e1 = self;
    if ([e1 isValueOnly]) return e1.value <= e2.value;
    if ([e2 isValueOnly]) {
        return e1.value <= e2.value &&
            [[e1.left lift:e1.value] innerLeq:e2] &&
            [[e1.right lift:e1.value] innerLeq:e2];
    }
    if (e1.left && e1.right && e2.left && e2.right) {
        return e1.value <= e2.value &&
            [[e1.left lift:e1.value] innerLeq:[e2.left lift:e2.value]] &&
            [[e1.right lift:e1.value] innerLeq:[e2.right lift:e2.value]];
    }
    [NSException raise:NSInternalInconsistencyException format:@"Each node must have either two children or no child."];
    return NO;
}

- (BOOL)leq:(ITCEvent *)e2 {
    return [self innerLeq:e2];
}

+ (instancetype)e0 {
    return [[ITCEvent alloc] initWithValue:0];
}


- (ITCEvent *)innerJoin:(ITCEvent *)e2 {
    ITCEvent *e1 = self;
    if ([e1 isValueOnly] && [e2 isValueOnly]) {
        return [[ITCEvent alloc] initWithValue:MAX(e1.value, e2.value)];
    }
    if ([e1 isValueOnly]) {
        return [[[ITCEvent alloc] initWithValue:e1.value left:[ITCEvent e0]  right:[ITCEvent e0]] innerJoin:e2];
    }
    if ([e2 isValueOnly]) {
        return [e1 innerJoin:[[ITCEvent alloc] initWithValue:e2.value left:[ITCEvent e0]  right:[ITCEvent e0]]];
    }
    if (e1.left && e1.right && e2.left && e2.right) {
        if (e1.value > e2.value) return [e2 innerJoin:e1];
        ITCEvent *left = [e1.left innerJoin:[e2.left lift:(e2.value - e1.value)]];
        ITCEvent *right = [e1.right innerJoin:[e2.right lift:(e2.value - e1.value)]];
        return [[[ITCEvent alloc] initWithValue:e1.value left:left right:right] normalize];
    }
    [NSException raise:NSInternalInconsistencyException format:@"Each node must have either two children or no child."];
    return nil;
}

- (ITCEvent *)join:(ITCEvent *)event2 {
    return [self innerJoin:event2];
}

- (BOOL)isEqual:(ITCEvent *)event {
    if (![event isKindOfClass:[self class]]) return NO;
    if (!self.left && event.left && !self.right && event.right) return NO;
    if (self.left && !event.left && self.right && !event.right) return NO;
    if ([self isValueOnly] && [event isValueOnly]) return self.value == event.value;
    if (self.left && self.right && event.left && event.right) {
        return self.value == event.value && [self.left isEqual:event.left] && [self.right isEqual:event.right];
    }
    return NO;
}

- (NSString *)description {
    if ([self isValueOnly]) return [@(self.value) stringValue];
    return [NSString stringWithFormat:@"(%@ , %@, %@)",@(self.value), self.left, self.right];
}

- (NSInteger)_maxDepth:(NSInteger)depth {
    if ([self isValueOnly]) return depth;
    return MAX([self.left _maxDepth:(depth + 1)],[self.right _maxDepth:(depth + 1)]);
}

- (NSInteger)maxDepth {
    return [self _maxDepth:0];
}

@end
