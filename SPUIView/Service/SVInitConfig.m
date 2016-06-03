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

// 初始化IP归属地信息是否成功
static BOOL initIPIsSuccess;

// 初始化配置服务器是否成功
static BOOL initResponseServerIsSucess;

// 解析配置信息是否成功
static BOOL parseDataIsSuccess;

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
        instance.initServerIsSuccess = NO;
        instance.isSuccess = NO;
        initIPIsSuccess = NO;
        parseDataIsSuccess = NO;
        initResponseServerIsSucess = NO;
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
    // 初始化带宽服务器列表
    if (!_initServerIsSuccess)
    {
        SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
        _initServerIsSuccess = [servers initSpeedTestServer];
    }

    SVTestContextGetter *contextGetter = [SVTestContextGetter sharedInstance];

    // 初始化本机IP和运营商等信息
    if (!initIPIsSuccess)
    {
        initIPIsSuccess = [contextGetter initIPAndISP];
    }

    // 向服务器请求配置服务器地址
    if (!initResponseServerIsSucess)
    {
        [self initServerInfoWithISP:[[SVIPAndISPGetter sharedInstance] getIPAndISP]];
    }

    if (!parseDataIsSuccess)
    {
        // 从服务器请求Test Context Data相关信息
        [contextGetter requestContextDataFromServer];

        // 解析服务器返回的Test Context Data
        parseDataIsSuccess = [contextGetter parseContextData];
    }

    // 只有四个都成功，才算是初始化成功
    self.isSuccess = _initServerIsSuccess && initIPIsSuccess && parseDataIsSuccess && initResponseServerIsSucess;
}

/**
 *  重新初始化数据 - 启动界面和重载界面调用
 */
- (void)loadResouceFromServer
{
    [self loadResouceForTimer];
    [[SVTestContextGetter sharedInstance] setCompleted:YES];

    // 如果测试成功，则直接返回
    if (self.isSuccess)
    {
        SVInfo (@"Load resource from server successed.");
        return;
    }

    // 如果测试失败，则启动线程重试3次
    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      int retryCount = 0;
      while (!self.isSuccess && retryCount < 3)
      {
          [self loadResouceForTimer];
          retryCount++;
      }
    });
}

/**
 * 初始化配置服务器信息
 *
 * @param ipAndISP ip归属地信息
 * @return 初始化是否成功
 */
- (void)initServerInfoWithISP:(SVIPAndISP *)ipAndISP
{
    // 如果ip归属地信息为空则返回失败
    if (!ipAndISP)
    {
        SVError (@"Init response server failed. ipAndISP is null.");

        // 设置状态为失败
        initResponseServerIsSucess = NO;
        return;
    }

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
                SVError (@"Get response server info failed. error:%@ ", error);

                // 设置状态为失败
                initResponseServerIsSucess = NO;
                return;
            }

            // 将返回的结果转换成字典，并存储
            NSDictionary *serverInfo = [[JSONDecoder decoder] objectWithData:responseData];
            SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
            [probeInfo setServerInfo:serverInfo];

            // 设置状态为成功
            initResponseServerIsSucess = YES;
          }];
}

@end
