//
//  SVUrlTools.m
//  SpeedPro
//
//  Created by JinManli on 16/5/13.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVUrlTools.h"

// 服务器baseUrl
static NSString *baseUrl = @"https://tools-speedpro.huawei.com/";

@implementation SVUrlTools

/**
 * 获取上传测试结果的url
 */
+ (NSString *)getResultUploadUrl
{
    return [NSString stringWithFormat:@"%@proresult/upload?i=%d", baseUrl, arc4random ()];
}

/**
 * 通过语言获取配置的url
 */
+ (NSString *)getProconfigUrlWithLang:(NSString *)lang
{
    return [NSString stringWithFormat:@"%@proconfig/distribute?lang=%@&i=%d", baseUrl, lang, arc4random ()];
}

/**
 * 通过mobileid获取上传日志的url
 */
+ (NSString *)getLogUploadUrlWithMobileid:(NSString *)mobileid
{
    return [NSString stringWithFormat:@"%@prolog/upload?mobileid=%@&i=%d", baseUrl, mobileid, arc4random ()];
}

@end
