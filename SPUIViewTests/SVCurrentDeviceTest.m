//
//  SVCurrentDeviceTest.m
//  SpeedPro
//
//  Created by Rain on 5/4/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVCurrentDevice.h"
#import <XCTest/XCTest.h>

@interface SVCurrentDeviceTest : XCTestCase

@end

@implementation SVCurrentDeviceTest


- (void)testExample
{
    NSString *wifiName = [SVCurrentDevice getWifiName];
    NSLog (@"WiFi Name:%@", wifiName);
    //    NSAssert(wifiName, @"wifiName");
}


@end
