//
//  vp_youget_test.m
//  vp.youget.test
//
//  Created by TYPCN on 2015/9/26.
//  Copyright © 2015 TYPCN. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "youget.h"

@interface vp_youget_test : XCTestCase{
    youget *yg;
}

@end

@implementation vp_youget_test

- (void)setUp {
    [super setUp];
    yg = [[youget alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParser {
    NSLog(@"%@",[yg processEvent:@"youget-resolveAddr" :@"http://www.tudou.com/albumplay/yjcmOqysUEc/aRiwzO5xYMU.html"]);

}

- (void)testDecrypt {
    
}

@end
