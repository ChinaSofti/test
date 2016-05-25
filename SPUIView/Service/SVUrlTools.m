//
//  SVUrlTools.m
//  SpeedPro
//
//  Created by JinManli on 16/5/13.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVConfigServerURL.h"
#import "SVProbeInfo.h"
#import "SVUrlTools.h"

// 服务器baseUrl
// static NSString *baseUrl = @"https://tools-speedpro.huawei.com/";

@implementation SVUrlTools

/**
 * 获取请求配置服务器的url
 */
+ (NSString *)getResponseServerUrl
{
    return [NSString stringWithFormat:@"%@/proresult/responseServer", [self getRootServer]];
}

/**
 * 获取上传测试结果的url
 */
+ (NSString *)getResultUploadUrl
{
    return [NSString stringWithFormat:@"%@/proresult/upload?i=%d", [self getServerHost], arc4random ()];
}

/**
 * 通过语言获取配置的url
 */
+ (NSString *)getProconfigUrlWithLang:(NSString *)lang
{
    return [NSString stringWithFormat:@"%@/proconfig/distribute?lang=%@&i=%d", [self getServerHost],
                                      lang, arc4random ()];
}

/**
 * 通过mobileid获取上传日志的url
 */
+ (NSString *)getLogUploadUrlWithMobileid:(NSString *)mobileid
{
    return [NSString stringWithFormat:@"%@/prolog/upload?mobileid=%@&i=%d", [self getServerHost],
                                      mobileid, arc4random ()];
}

/**
 * 获取服务器域名
 */
+ (NSString *)getServerHost
{
    // 获取默认域名
    NSString *serverHost = [[SVConfigServerURL sharedInstance] getConfigServerUrl];

    // 获取服务器域名，如果服务器信息为空，则使用默认地址
    NSDictionary *serverInfo = [[SVProbeInfo sharedInstance] getServerInfo];
    if (!serverInfo)
    {
        return serverHost;
    }

    NSDictionary *server = [serverInfo valueForKey:@"server"];
    if (!server)
    {
        return serverHost;
    }

    NSString *serverIp = [server valueForKey:@"serverIp"];
    if (!serverIp)
    {
        return serverHost;
    }

    NSString *serverPort = [server valueForKey:@"serverPort"];
    if (!serverPort)
    {
        return serverHost;
    }

    return [NSString stringWithFormat:@"https://%@:%@", serverIp, serverPort];
}

/**
 * 获取根服务器
 */
+ (NSString *)getRootServer
{
    // 加载配置文件
    NSError *error;
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"serverConfig" ofType:@"conf"];
    NSData *configData = [[NSData alloc] initWithContentsOfFile:configPath
                                                        options:NSDataReadingMappedIfSafe
                                                          error:&error];
    if (error)
    {
        SVError (@"Read serverConfig.conf failed! error:%@", error);
        return nil;
    }

    NSMutableDictionary *configDic = [self getDicWithData:configData];

    return [NSString stringWithFormat:@"https://%@:%@", [configDic valueForKey:@"rootHost"],
                                      [configDic valueForKey:@"rootPort"]];
}

/**
 * 将文件内容解析为字典
 */
+ (NSMutableDictionary *)getDicWithData:(NSData *)fileData
{
    NSMutableDictionary *configDic = [[NSMutableDictionary alloc] init];
    NSString *contents = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSArray *lineArray = [contents componentsSeparatedByString:@"\n"];
    for (NSString *lineStr in lineArray)
    {
        NSArray *params = [lineStr componentsSeparatedByString:@":"];
        if ([params count] != 2)
        {
            continue;
        }

        [configDic setObject:params[1] forKey:params[0]];
    }
    return configDic;
}

@end
