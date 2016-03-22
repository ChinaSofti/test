//
//  SVRealReachability.h
//  SpeedPro
//
//  Created by Rain on 3/7/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, SVRealReachabilityStatus) {
    SV_WWANTypeUnknown = -1, /// maybe iOS6
    SV_RealStatusNotReachable = 0,
    SV_RealStatusViaWWAN = 1,
    SV_RealStatusViaWiFi = 2,
    SV_WWANType2G = 3,
    SV_WWANType3G = 4,
    SV_WWANType4G = 5
};

@protocol SVRealReachabilityDelegate <NSObject>

@required

- (void)networkStatusChange:(SVRealReachabilityStatus)status;

@end

@interface SVRealReachability : NSObject


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
 *  新增加代理，用于网络状态变更时实时通知
 *
 *  @param delegate 代理
 */
- (void)addDelegate:(id<SVRealReachabilityDelegate>)delegate;

/**
 *  移除代理
 *
 *  @param delegate 代理
 */
- (void)removeDelegate:(id<SVRealReachabilityDelegate>)delegate;

/**
 *  获取网络实时状态
 *
 *  @return 网络实时状态
 */
- (SVRealReachabilityStatus)getNetworkStatus;

@end
