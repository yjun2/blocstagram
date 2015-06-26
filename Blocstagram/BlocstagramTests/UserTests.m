//
//  UserTests.m
//  Blocstagram
//
//  Created by Yong Jun on 6/26/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "User.h"

@interface UserTests : XCTestCase

@end

@implementation UserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTahtInitializationWorks {
    NSDictionary *sourceDictionary = @{@"id": @"8673309",
                                       @"username": @"d'oh",
                                       @"full_name": @"Homer Simpson",
                                       @"profile_picture": @"http://www.example.com/example.jpg"};
    
    User *testUser = [[User alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testUser.idNumber, sourceDictionary[@"id"], @"The id number should be equal");
    XCTAssertEqualObjects(testUser.userName, sourceDictionary[@"username"], @"The username should be equal");
    XCTAssertEqualObjects(testUser.fullName, sourceDictionary[@"full_name"], @"The fullname should be equal");
//    XCTAssertEqualObjects(testUser.profilePicture, [NSURL URLWithString:sourceDictionary[@"id"]], @"The profile picutre should be equal");
}

@end
