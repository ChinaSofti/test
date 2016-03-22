//
//  SVSpeedTestServers.h
//  SpeedPro
//
//  Created by Rain on 3/10/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVSpeedTestServer.h"
#import <Foundation/Foundation.h>

@interface SVSpeedTestServers : NSObject
{
    NSMutableArray *_queue;
}

@property NSString *clientIP;
@property NSString *isp;
@property NSString *lat;
@property NSString *lon;

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance;

/**
 *  覆写allocWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)allocWithZone:(struct _NSZone *)zone;

/**
 *  覆写copyWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)copyWithZone:(struct _NSZone *)zone;


/**
 *  设置缺省SpeedTestServer
 *
 *  @param server SpeedTestServer的URL
 */
- (void)setDefaultServer:(SVSpeedTestServer *)server;

/**
 *  设置缺省SpeedTestServer
 *
 *  @return 缺省SpeedTestServer
 */
- (SVSpeedTestServer *)getDefaultServer;

/**
 *  设置是否是自动模式
 *
 *  @param isAuto 是否是自动模式
 */
- (void)setAuto:(BOOL)isAuto;

/**
 *  是否是自动模式
 *
 *  @return 是否是自动模式
 */
- (BOOL)isAuto;

/**
 *  获取所有SpeedTest Server
 *
 *  @return 所有SpeedTest Server
 */
- (NSArray *)getAllServer;

/**
 *  初始化所有SpeedTestServer
 */
- (void)initSpeedTestServer;

@end
