//
//  ITCStamp.m
//  IntervalTreeClock
//
//  Created by Andrew Mackenzie-Ross on 7/03/2014.
//  Copyright (c) 2014 Happy Inspector. All rights reserved.
//

#import "ITCStamp.h"
#import "ITCEvent.h"
#import "ITCID.h"

@interface ITCGrowResult : NSObject
- (instancetype)initWithEvent:(ITCEvent *)event c:(NSInteger)c;
@property (nonatomic, copy, readonly) ITCEvent *event;
@property (nonatomic, readwrite) NSInteger c;
@end

@implementation ITCStamp

- (id)init {
    return [self initWithID:nil event:nil];
}

- (instancetype)initWithID:(ITCID *)identifier event:(ITCEvent *)event {
    self = [super init];
    if (!self) return nil;

    _identifier = identifier ?: [[ITCID alloc] initWithValue:1];
    _event = event ?: [[ITCEvent alloc] initWithValue:0];
    return self;
}

- (NSArray *)fork {
    NSArray *result = [self.identifier split];
    return @[ [[ITCStamp alloc] initWithID:result[0] event:self.event],
              [[ITCStamp alloc] initWithID:result[1] event:self.event] ];
}

- (NSArray *)peek {
    return @[
             [[ITCStamp alloc] initWithID:self.identifier event:self.event],
             [[ITCStamp alloc] initWithID:[[ITCID alloc] initWithValue:0] event:self.event]
    ];
}

- (instancetype)join:(ITCStamp *)stamp {
    return [[ITCStamp alloc] initWithID:[self.identifier sum:stamp.identifier] event:[self.event join:stamp.event]];
}

+ (ITCEvent *)fill:(ITCID *)identifier event:(ITCEvent *)event {
    if ([identifier isEqual:[ITCID ID0]]) return event;
    if ([identifier isEqual:[ITCID ID1]]) return [[ITCEvent alloc] initWithValue:[event max]];
    if ([event isValueOnly]) return [[ITCEvent alloc] initWithValue:event.value];
    if (identifier.left && [identifier.left isEqual:[ITCID ID1]]) {
        ITCEvent *eventRight = [ITCStamp fill:identifier.right event:event.right];
        NSInteger max = MAX([event.left max], [eventRight min]);
        return [[[ITCEvent alloc] initWithValue:event.value left:[[ITCEvent alloc] initWithValue:max] right:eventRight] normalize];
    }
    if (identifier.right && [identifier.right isEqual:[ITCID ID1]]) {
        ITCEvent *eventLeft = [ITCStamp fill:identifier.left event:event.left];
        NSInteger max = MAX([event.right max], [eventLeft min]);
        return [[ITCEvent alloc] initWithValue:event.value left:eventLeft right:[[ITCEvent alloc] initWithValue:max]];
    }
    return [[ITCEvent alloc] initWithValue:event.value left:[ITCStamp fill:identifier.left event:event.left] right:[ITCStamp fill:identifier.right event:event.right]];

}

+ (ITCGrowResult *)grow:(ITCID *)identifier event:(ITCEvent *)event {
    if ([identifier isEqual:[ITCID ID1]] && [event isValueOnly]) {
        return [[ITCGrowResult alloc] initWithEvent:[[ITCEvent alloc] initWithValue:(event.value + 1)] c:0];
    }
    if ([event isValueOnly]) {
        ITCGrowResult *er = [ITCStamp grow:identifier event:[[ITCEvent alloc] initWithValue:event.value left:[[ITCEvent alloc] initWithValue:0] right:[[ITCEvent alloc] initWithValue:0]]];
        er.c = er.c + [event maxDepth] + 1;
        return er;
    }
    if (identifier.left && [identifier.left isEqual:[ITCID ID0]]) {
        ITCGrowResult *er = [ITCStamp grow:identifier.right event:event.right];
        ITCEvent *e = [[ITCEvent alloc] initWithValue:event.value left:event.left right:er.event];
        return [[ITCGrowResult alloc] initWithEvent:e c:(er.c + 1)];
    }
    if (identifier.right && [identifier.right isEqual:[ITCID ID0]]) {
        ITCGrowResult *er = [ITCStamp grow:identifier.left event:event.left];
        ITCEvent *e = [[ITCEvent alloc] initWithValue:event.value left:er.event right:event.right];
        return [[ITCGrowResult alloc] initWithEvent:e c:(er.c + 1)];

    }
    ITCGrowResult *left = [ITCStamp grow:identifier.left event:event.left];
    ITCGrowResult *right = [ITCStamp grow:identifier.right event:event.right];

    if (left.c < right.c) {
        ITCEvent *e = [[ITCEvent alloc] initWithValue:event.value left:left.event right:event.right];
        return [[ITCGrowResult alloc] initWithEvent:e c:(left.c + 1)];
    } else {
        ITCEvent *e = [[ITCEvent alloc] initWithValue:event.value left:event.left right:right.event];
        return [[ITCGrowResult alloc] initWithEvent:e c:(right.c + 1)];

    }

}

- (ITCStamp *)touch {
    ITCEvent *e = [ITCStamp fill:self.identifier event:self.event];
    if (![self.event isEqual:e]) {
        return [[ITCStamp alloc] initWithID:self.identifier event:e];
    } else {
        ITCGrowResult *gr = [ITCStamp grow:self.identifier event:self.event];
        return [[ITCStamp alloc] initWithID:self.identifier event:gr.event];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%@, %@)",self.identifier, self.event];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[ITCStamp alloc] initWithID:[self.identifier copy] event:[self.event copy]];
}


- (BOOL)isEqual:(ITCStamp *)obj {
    if (![obj isKindOfClass:[self class]]) return NO;
    BOOL eventEqual = (!self.event && !obj.event) || [self.event isEqual:obj.event];
    BOOL idEqual = (!self.identifier && !obj.identifier) || [self.identifier isEqual:obj.identifier];
    return eventEqual && idEqual;
}

- (NSArray *)send {
    return [[self.event copy] peek];
}

- (ITCStamp *)receive:(ITCStamp *)stamp {
    return [[[self copy] join:[stamp copy]] touch];
}

- (NSArray *)sync:(ITCStamp *)stamp {
    return [[[self copy] join:[stamp copy]] fork];
}

- (BOOL)leq:(ITCStamp *)stamp {
    return [self.event leq:stamp.event];
}

@end

@implementation ITCGrowResult

- (instancetype)initWithEvent:(ITCEvent *)event c:(NSInteger)c {
    self = [super init];
    if (!self) return nil;

    _event = event;
    _c = c;
    
    return self;
}

@end
