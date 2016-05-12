//
//  SVSearchCountry.h
//  SpeedPro
//
//  Created by JinManli on 16/5/12.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVSearchCountry : NSObject

/**
 * 根据给定的国家码，返回国家所在地域的url
 */
+ (NSString *)searchCountryWithCountryAbbreviation:(NSString *)countryAbbreviation;

@end
