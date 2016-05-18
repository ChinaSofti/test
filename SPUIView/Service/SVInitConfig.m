//
//  SVInitConfig.m
//  SpeedPro
//
//  Created by JinManli on 16/5/17.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "JSONKit.h"
#import "SVHttpsTools.h"
#import "SVInitConfig.h"
#import "SVObjectTools.h"
#import "SVProbeInfo.h"
#import "SVSpeedTestServers.h"
#import "SVTestContextGetter.h"
#import "SVUrlTools.h"

@implementation SVInitConfig

/**
 *  单例对象
 */
+ (instancetype)sharedManager
{
    static SVInitConfig *instance;

    if (instance == nil)
    {
        instance = [[super allocWithZone:NULL] init];
    }

    return instance;
}

/**
 *  覆写allocWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SVInitConfig sharedManager];
}

/**
 *  覆写copyWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */

+ (instancetype)copyWithZone:(struct _NSZone *)zone
{
    return [SVInitConfig sharedManager];
}

/**
 *  重新初始化数据 - 定期检查，定时器调用此方法
 */
- (void)loadResouceForTimer
{
    SVTestContextGetter *contextGetter = [SVTestContextGetter sharedInstance];

    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    BOOL initServerIsSuccess = [servers reInitSpeedTestServer];

    // 初始化本机IP和运营商等信息
    BOOL initIPIsSuccess = [contextGetter initIPAndISP];

    // 判断IP信息是否初始化成功，如果成功则向服务器请求配置服务器地址
    if (initIPIsSuccess)
    {
        [self initServerInfoWithISP:[[SVIPAndISPGetter sharedInstance] getIPAndISP]];
    }

    // 从服务器请求Test Context Data相关信息
    [contextGetter requestContextDataFromServer];

    // 解析服务器返回的Test Context Data
    BOOL parseDataIsSuccess = [contextGetter parseContextData];

    self.isSuccess = initServerIsSuccess && initIPIsSuccess && parseDataIsSuccess;
}

/**
 *  重新初始化数据 - 启动界面和重载界面调用
 */
- (void)loadResouceFromServer
{
    [self loadResouceForTimer];
    [[SVTestContextGetter sharedInstance] setCompleted:YES];
}

/**
 * 初始化配置服务器信息
 *
 * @param ipAndISP ip归属地信息
 */
- (void)initServerInfoWithISP:(SVIPAndISP *)ipAndISP
{
    // 将ip归属地信息转换为json
    NSString *jsonStr = [SVObjectTools getJSON:ipAndISP options:0];

    // 初始化URL
    NSURL *url = [[NSURL alloc] initWithString:[SVUrlTools getResponseServerUrl]];

    // 初始化URLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPBody:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:10];
    [request setHTTPMethod:@"POST"];

    // 设置Content-Type
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    // 连接服务器发送结果
    SVHttpsTools *httpsTools = [[SVHttpsTools alloc] init];
    [httpsTools sendRequest:request
          completionHandler:^(NSData *responseData, NSError *error) {
            // 上报结果失败
            if (error)
            {
                SVError (@"Get server info failed. error:%@ ", error);
                return;
            }

            // 将返回的结果转换成字典，并存储
            NSDictionary *serverInfo = [[JSONDecoder decoder] objectWithData:responseData];
            SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
            [probeInfo setServerInfo:serverInfo];
          }];
}

@end
