//
//  SVUrlTools.h
//  SpeedPro
//
//  Created by JinManli on 16/5/13.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVUrlTools : NSObject

/**
 * 获取请求配置服务器的url
 */
+ (NSString *)getResponseServerUrl;

/**
 * 获取上传测试结果的url
 */
+ (NSString *)getResultUploadUrl;

/**
 * 通过语言获取配置的url
 */
+ (NSString *)getProconfigUrlWithLang:(NSString *)lang;

/**
 * 通过mobileid获取上传日志的url
 */
+ (NSString *)getLogUploadUrlWithMobileid:(NSString *)mobileid;

@end
