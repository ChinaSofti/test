//
//  SVSpeedTestServers.m
//  SpeedPro
//
//  Created by Rain on 3/10/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//
#import "SVHttpsTools.h"
#import "SVLog.h"
#import "SVSpeedTestServers.h"
#import "SVSpeedTestServersParser.h"

@implementation SVSpeedTestServers
{
    NSMutableArray *_serverArray;
    SVSpeedTestServer *_server;
    BOOL _auto;
}

static NSString *SPEEDTEST_SERVER_QUERY_URL = @"https://www.speedtest.net/api/android/config.php";

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    static SVSpeedTestServers *servers;
    @synchronized (self)
    {
        if (servers == nil)
        {
            servers = [[super allocWithZone:NULL] init];
            //            dispatch_async (dispatch_get_global_queue
            //            (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //              [servers initSpeedTestServer];
            //            });
        }
    }

    return servers;
}

/**
 *  覆写allocWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [SVSpeedTestServers sharedInstance];
}

/**
 *  覆写copyWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [SVSpeedTestServers sharedInstance];
}

- (void)initSpeedTestServer
{
    if (_serverArray && _serverArray.count > 0)
    {
        return;
    }

    [self reInitSpeedTestServer];

    // 如果请求失败，一直请求，直到请求成功
    dispatch_async (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      while (_serverArray == nil || _serverArray.count == 0)
      {
          [self reInitSpeedTestServer];
          [NSThread sleepForTimeInterval:10];
      }
    });
}


/**
 *  重新初始化所有SpeedTestServer
 */
- (void)reInitSpeedTestServer
{
    [_serverArray removeAllObjects];
    _server = nil;

    SVInfo (@"start request speed test server list.");
    SVHttpsTools *getter =
    [[SVHttpsTools alloc] initWithURLNSString:SPEEDTEST_SERVER_QUERY_URL WithCert:NO];
    NSData *reponseData = [getter getResponseData];
    if (!reponseData)
    {
        SVError (@"request speed test server list fail.");
        return;
    }

    // 记录日志
    //    SVInfo (@"%@", [[NSString alloc] initWithData:reponseData encoding:NSUTF8StringEncoding]);

    SVSpeedTestServersParser *parser = [[SVSpeedTestServersParser alloc] initWithData:reponseData];
    NSArray *array = [parser parse];

    _serverArray = [[NSMutableArray alloc] init];
    _serverArray = [[NSMutableArray alloc] initWithArray:array];
    SVSpeedTestServer *server = [_serverArray objectAtIndex:0];
    _server = server;
    _auto = YES;

    _clientIP = parser.clientIP;
    _isp = parser.isp;
    _lat = parser.lat;
    _lon = parser.lon;
}

/**
 *  设置缺省SpeedTestServer
 *
 *  @param serverURL SpeedTestServer
 */
- (void)setDefaultServer:(SVSpeedTestServer *)server
{
    _server = server;
}

/**
 *  设置缺省SpeedTestServer
 *
 *  @return 缺省SpeedTestServer
 */
- (SVSpeedTestServer *)getDefaultServer
{
    return _server;
}

/**
 *  设置是否是自动模式
 *
 *  @param isAuto 是否是自动模式
 */
- (void)setAuto:(BOOL)isAuto
{
    _auto = isAuto;
}

/**
 *  是否是自动模式
 *
 *  @return 是否是自动模式
 */
- (BOOL)isAuto
{
    return _auto;
}

/**
 *  获取所有SpeedTest Server
 *
 *  @return 所有SpeedTest Server
 */
- (NSArray *)getAllServer
{
    return _serverArray;
}

@end
