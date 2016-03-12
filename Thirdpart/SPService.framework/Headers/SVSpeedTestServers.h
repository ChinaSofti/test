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
- (void)setDefaultServerURL:(SVSpeedTestServer *)server;

/**
 *  设置缺省SpeedTestServer
 *
 *  @return 缺省SpeedTestServer
 */
- (SVSpeedTestServer *)getDefaultServer;


/**
 *  获取所有SpeedTest Server
 *
 *  @return 所有SpeedTest Server
 */
- (NSArray *)getAllServer;

@end
