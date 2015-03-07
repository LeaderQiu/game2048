//
//  game2048Tests.m
//  game2048Tests
//
//  Created by Jason on 15/1/26.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface game2048Tests : XCTestCase

@end

@implementation game2048Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testABC {
    int a = 1, b = 2;
    int c = a + b;
    
    NSAssert(c == 3, @"c 的结果有问题");
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
