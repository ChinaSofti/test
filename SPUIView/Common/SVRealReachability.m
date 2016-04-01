//
//  SVRealReachability.m
//  SpeedPro
//
//  Created by Rain on 3/7/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "RealReachability.h"
#import "SVLog.h"
#import "SVRealReachability.h"

@implementation SVRealReachability
{
    BOOL _isStartMonitor;
    SVRealReachabilityStatus _realStatus;
}

static NSMutableArray *delegates;

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    static SVRealReachability *reachability;
    @synchronized (self)
    {
        if (reachability == nil)
        {
            reachability = [[super allocWithZone:NULL] init];
            delegates = [[NSMutableArray alloc] init];
            [reachability registerMonitory];
        }
    }

    return reachability;
}

- (void)registerMonitory
{
    [GLobalRealReachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (networkChanged:)
                                                 name:@"kRealReachabilityChangedNotification"
                                               object:nil];
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
    return [SVRealReachability sharedInstance];
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
    return [SVRealReachability sharedInstance];
}

/**
 *  新增加代理，用于网络状态变更时实时通知
 *
 *  @param delegate 代理
 */
- (void)addDelegate:(id<SVRealReachabilityDelegate>)delegate
{
    @synchronized (delegates)
    {
        [delegates addObject:delegate];
    }
}

/**
 *  移除代理
 *
 *  @param delegate 代理
 */
- (void)removeDelegate:(id<SVRealReachabilityDelegate>)delegate
{
    @synchronized (delegates)
    {
        [delegates removeObject:delegate];
    }
}

- (void)networkChanged:(NSNotification *)notification
{
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];

    _realStatus = SV_RealStatusNotReachable;
    SVInfo (@"currentStatus:%@", @(status));
    if (status == RealStatusNotReachable)
    {
        _realStatus = SV_RealStatusNotReachable;
    }

    if (status == RealStatusViaWiFi)
    {
        _realStatus = SV_RealStatusViaWiFi;
    }

    if (status == RealStatusViaWWAN)
    {
        _realStatus = SV_RealStatusViaWWAN;
    }

    WWANAccessType accessType = [GLobalRealReachability currentWWANtype];
    if (status == RealStatusViaWWAN)
    {
        if (accessType == WWANType2G)
        {
            _realStatus = SV_WWANType2G;
        }
        else if (accessType == WWANType3G)
        {
            _realStatus = SV_WWANType3G;
        }
        else if (accessType == WWANType4G)
        {
            _realStatus = SV_WWANType4G;
        }
        else
        {
            _realStatus = SV_WWANTypeUnknown;
        }
    }

    @synchronized (delegates)
    {
        for (id<SVRealReachabilityDelegate> delegate in delegates)
        {
            [delegate networkStatusChange:_realStatus];
        }
    }
}


- (SVRealReachabilityStatus)getNetworkStatus
{
    if (!_realStatus)
    {
        return SV_WWANTypeUnknown;
    }

    return _realStatus;
}

@end
