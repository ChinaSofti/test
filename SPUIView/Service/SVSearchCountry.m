//
//  SVSearchCountry.m
//  SpeedPro
//
//  Created by JinManli on 16/5/12.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVSearchCountry.h"

// 元素为字典，每个字典存放一个地域的国家码和国家名
static NSArray *countryArr;

// 存放每个地域对应的url
static NSArray *regionArr;

@implementation SVSearchCountry

/**
 * 如果需要往countryArr里添加一个地域的国家码和国家名，需要往regionArr里添加一个url，并且索引必须一致
 */

/**
 * 获取地域的国家码和国家名数组
 */
+ (NSArray *)getCountryArr
{
    if (countryArr == nil)
    {
        countryArr = @[
            @{
                @"AL": @"Albania",
                @"AD": @"Andrra",
                @"AM": @"Armenia",
                @"AT": @"Austria",
                @"BY": @"Belarus",
                @"BE": @"Belgium",
                @"BA": @"Bosnia and Herzegovina",
                @"BG": @"Bulgaria",
                @"CH": @"Switzerland",
                @"CY": @"Cyprus",
                @"CZ": @"Czech Republic",
                @"DE": @"Germany",
                @"DK": @"Denmark",
                @"EE": @"Estonia",
                @"ES": @"Spain",
                @"FO": @"Faeroe Islands",
                @"FI": @"Finland",
                @"FR": @"France",
                @"GB": @"United Kingdom",
                @"GE": @"Georgia",
                @"GI": @"Gibraltar",
                @"GR": @"Greece",
                @"HU": @"Hungary",
                @"HR": @"Croatia",
                @"IE": @"Ireland",
                @"IS": @"Iceland",
                @"IT": @"Italy",
                @"LT": @"Lithuania",
                @"LU": @"Luxembourg",
                @"LV": @"Latvia"
            }
        ];
    }
    return countryArr;
}

/**
 * 获取对应地域的url
 */
+ (NSArray *)getRegionArr
{
    if (regionArr == nil)
    {
        regionArr = @[@"https://tools-speedpro.huawei.com"];
    }
    return regionArr;
}

/**
 * 根据给定的国家码，返回所在地域的url
 */
+ (NSString *)searchCountryWithCountryAbbreviation:(NSString *)countryAbbreviation
{
    if (countryAbbreviation.length == 0)
    {
        // 输入国家码为空，返回默认的url
        return @"https://58.60.106.188:12210";
    }

    // 转换为大写字符串
    countryAbbreviation = [countryAbbreviation uppercaseString];

    NSUInteger count = [self getCountryArr].count;

    // 遍历countryArr，判断是否包含输入的国家码
    for (int i = 0; i < count; i++)
    {
        NSDictionary *dic = [self getCountryArr][i];

        if ([[dic allKeys] containsObject:countryAbbreviation])
        {
            // 包含返回regionArr中相应下标的url
            return [self getRegionArr][i];
        }
    }
    // 不包含返回默认url
    return @"https://58.60.106.188:12210";
}

@end
