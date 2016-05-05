//
//  SVReloadingDataAlertViewManager.m
//  SpeedPro
//
//  Created by Rain on 5/5/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVAlertView.h"
#import "SVReloadingDataAlertViewManager.h"

@implementation SVReloadingDataAlertViewManager
{
    SVAlertView *_alertView;
}

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    static SVReloadingDataAlertViewManager *manager;
    @synchronized (self)
    {

        if (manager == nil)
        {
            manager = [[super allocWithZone:NULL] init];
        }
    }

    return manager;
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
    return [SVReloadingDataAlertViewManager sharedInstance];
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
    return [SVReloadingDataAlertViewManager sharedInstance];
}

- (void)showAlertView
{
    @synchronized (self)
    {
        if (_alertView && [_alertView isShowing])
        {
            return;
        }

        _alertView = [[SVAlertView alloc] init];
        [_alertView showAlertView];
    }
}


@end
