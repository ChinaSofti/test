//
//  SVAppVersionCheckerTest.m
//  SpeedPro
//
//  Created by Rain on 4/21/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVAppVersionChecker.h"
#import <XCTest/XCTest.h>

@interface SVAppVersionCheckerTest : XCTestCase

@end

@implementation SVAppVersionCheckerTest


- (void)testGetCurrentVersion
{
    NSString *version = [SVAppVersionChecker currentVersion];
    NSLog (@"current version:%@", version);
    NSAssert (version, @"version mustn't be null!");
}

- (void)testGetCurrentVersionInAppStore
{
    NSString *version = [SVAppVersionChecker currentVersionInAppStore];
    NSLog (@"current version:%@", version);
    NSAssert (version, @"version mustn't be null!");
}


- (void)testHasNewVersion
{
    BOOL hasNewVersion = [SVAppVersionChecker hasNewVersion];
    NSLog (@"has new version:%d", hasNewVersion);
    NSAssert (hasNewVersion, @"there is no new version. please check current version and current "
                             @"version in appstore");
}

@end
