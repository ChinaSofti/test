//
//  SVSearchCountryTest.m
//  SpeedPro
//
//  Created by JinManli on 16/5/12.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVSearchCountry.h"
#import <XCTest/XCTest.h>

@interface SVSearchCountryTest : XCTestCase

@end

@implementation SVSearchCountryTest

- (void)testExampleSearchSuccess
{
    NSString *searchResult = [SVSearchCountry searchCountryWithCountryAbbreviation:@"fi"];
    NSAssert ([searchResult isEqualToString:@"https://tools-speedpro.huawei.com"],
              @"获取地域url失败");
}

- (void)testExampleSearchFail
{
    NSString *searchResult = [SVSearchCountry searchCountryWithCountryAbbreviation:@"aaa"];
    NSAssert ([searchResult isEqualToString:@"https://58.60.106.188:12210"],
              @"获取默认的url失败");
}

- (void)testExampleSearchNull
{
    NSString *searchResult = [SVSearchCountry searchCountryWithCountryAbbreviation:@""];
    NSAssert ([searchResult isEqualToString:@"https://58.60.106.188:12210"],
              @"国家码为空");
}

@end
