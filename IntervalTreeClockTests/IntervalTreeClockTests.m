//
//  IntervalTreeClockTests.m
//  IntervalTreeClockTests
//
//  Created by Andrew Mackenzie-Ross on 6/03/2014.
//  Copyright (c) 2014 Happy Inspector. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ITCID.h"
#import "ITCEvent.h"
#import "ITCStamp.h"

static inline ITCEvent* Eventv(NSInteger x) {
    return [[ITCEvent alloc] initWithValue:x];
}

static inline ITCEvent* Event(NSInteger x, ITCEvent *left, ITCEvent *right) {
    return [[ITCEvent alloc] initWithValue:x left:left right:right];
}

@interface IntervalTreeClockTests : XCTestCase

@end

@implementation IntervalTreeClockTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIDNorm
{
    ITCID *inner1 = [[ITCID alloc] initWithLeft:[[ITCID ID1] copy] right:[[ITCID ID1] copy]];
    ITCID *inner2 = [[ITCID alloc] initWithLeft:[[ITCID ID1] copy] right:inner1];

    ITCID *normalized = [inner2 normalize];
    XCTAssertEqualObjects([ITCID ID1], normalized);
}

- (void)testEventNorm {
    XCTAssertEqualObjects(Eventv(3), [Event(2, Eventv(1), Eventv(1)) normalize], @"oh oh");
    NSLog(@" %@ -- %@",Event(4, Event(0, Eventv(1), Eventv(0)), Eventv(1)), [Event(2, Event(2, Eventv(1), Eventv(0)), Eventv(3)) normalize]);
    XCTAssertEqualObjects(Event(4, Event(0, Eventv(1), Eventv(0)), Eventv(1)), [Event(2, Event(2, Eventv(1), Eventv(0)), Eventv(3)) normalize], @"oh oh");
}

- (void)testAll {
    ITCStamp *stamp = [[ITCStamp alloc] init];
    NSArray *fork1 = [stamp fork];
    NSLog(@"fork1: %@",fork1);
    ITCStamp *event1 = [fork1[0] touch];
    NSLog(@"event1: %@", event1);
    ITCStamp *event2 = [[fork1[1] touch] touch];
    NSLog(@"event2: %@",event2);
    NSArray *fork2 = [event1 fork];
    NSLog(@"fork2: %@", fork2);
    ITCStamp *event11 = [fork2[0] touch];
    NSLog(@"event11: %@", event11);
    ITCStamp *join1 = [(ITCStamp *)fork2[1] join:event2];
    NSLog(@"join1: %@",join1);
    NSArray *fork22 = [join1 fork];
    NSLog(@"fork22: %@",fork22);
    ITCStamp *join2 = [(ITCStamp *)fork22[0] join:event11];
    NSLog(@"join2: %@",join2);
    ITCStamp *event3 = [join2 touch];
    NSLog(@"event3: %@",event3);
    ITCID *ide = [[ITCID alloc] initWithLeft:[[ITCID ID1] copy] right:[[ITCID ID0] copy]];
    XCTAssertEqualObjects([[ITCStamp alloc] initWithID:ide event:Eventv(2)], event3, @"oh oh");
}

- (void)testLeq {
    NSArray *s  = [[[ITCStamp alloc] init] fork];
    ITCStamp *s1 = s[0];
    ITCStamp *s2 = s[1];
    XCTAssertFalse([s1 isEqual:s2], @"OK");
    XCTAssertTrue([s1 leq:s2], @"OK");
    XCTAssertTrue([s2 leq:s1], @"OK");

    XCTAssertFalse([[s1 touch] leq:s2], @"OK");
    XCTAssertFalse([[s1 touch] leq:[s2 touch]], @"OK");
    XCTAssertTrue([s1 leq:[s2 touch]], @"OK");

    XCTAssertTrue([s1 leq:s2], @"OK");
    s1 = [s1 touch];
    s1 = [[s1 fork][1] touch];
    XCTAssertTrue([s2 leq:s1], @"OK");
    XCTAssertFalse([s1 leq:s2], @"OK");

    s2 = [s2 touch];
    XCTAssertFalse([s1 leq:s2], @"OK");
    XCTAssertFalse([s2 leq:s1], @"OK");

    ITCStamp *s3 = [[s2 join:s1] touch];
    XCTAssertTrue([s2 leq:s3], @"OK");
    XCTAssertTrue([s1 leq:s3], @"OK");
    NSLog(@"--- %@",s3);

    
}

@end
