//
//  SVCurentLocation.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/5/23.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVCurentLocation.h"
#import "SVProbeInfo.h"

@implementation SVCurentLocation

/**
 * 定位回调代理
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currLocation = [locations lastObject];

    // 取出当前位置的坐标
    SVInfo (@"latitude : %f,longitude: %f", currLocation.coordinate.latitude, currLocation.coordinate.longitude);
    NSString *latStr = [NSString stringWithFormat:@"%f", currLocation.coordinate.latitude];
    NSString *lngStr = [NSString stringWithFormat:@"%f", currLocation.coordinate.longitude];

    // 记录坐标位置
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    [probeInfo setLatitude:latStr];
    [probeInfo setLongitude:lngStr];

    // 停止定位
    [_locaManager stopUpdatingLocation];

    //    // 反向解析，根据及纬度反向解析出地址
    //    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    //    CLLocation *location = [locations objectAtIndex:0];
    //    [geoCoder
    //    reverseGeocodeLocation:location
    //         completionHandler:^(NSArray *placemarks, NSError *error) {
    //
    //           for (CLPlacemark *place in placemarks)
    //           {
    //               // 取出当前位置的坐标
    //               SVInfo (@"latitude : %f,longitude: %f", currLocation.coordinate.latitude,
    //                       currLocation.coordinate.longitude);
    //               NSString *latStr = [NSString stringWithFormat:@"%f",
    //               currLocation.coordinate.latitude];
    //               NSString *lngStr = [NSString stringWithFormat:@"%f",
    //               currLocation.coordinate.longitude];
    //               NSDictionary *dict = [place addressDictionary];
    //               NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    //               [resultDic setObject:dict[@"SubLocality"] forKey:@"xian"];
    //               [resultDic setObject:dict[@"City"] forKey:@"shi"];
    //               [resultDic setObject:latStr forKey:@"wei"];
    //               [resultDic setObject:lngStr forKey:@"jing"];
    //               [resultDic setObject:dict[@"State"] forKey:@"sheng"];
    //               [resultDic setObject:dict[@"Name"] forKey:@"all"];
    //               [[NSUserDefaults standardUserDefaults] setObject:dict[@"SubLocality"]
    //                                                         forKey:@"XianUser"];
    //               [[NSUserDefaults standardUserDefaults] setObject:resultDic
    //               forKey:@"LocationInfo"];
    //               [[NSUserDefaults standardUserDefaults] synchronize];
    //           }
    //         }];
}

#pragma mark - 检测应用是否开启定位服务
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    switch ([error code])
    {
    case kCLErrorDenied:
        SVInfo (@"Location manager error : kCLErrorDenied");
        break;
    case kCLErrorLocationUnknown:
        SVInfo (@"Location manager error : kCLErrorLocationUnknown");
        break;
    default:
        break;
    }
}

/**
 * 用户变更了程序的定位服务状态
 */
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
    case kCLAuthorizationStatusNotDetermined:
        if ([manager respondsToSelector:@selector (requestAlwaysAuthorization)])
        {
            [manager requestWhenInUseAuthorization];
        }
        break;

    default:
        break;
    }
}

/**
 * 获取定位信息
 */
- (void)getUserLocation
{
    // 初始化定位管理类
    _locaManager = [[CLLocationManager alloc] init];

    // delegate
    _locaManager.delegate = self;

    // The desired location accuracy.//精确度
    _locaManager.desiredAccuracy = kCLLocationAccuracyBest;

    // Specifies the minimum update distance in meters.
    // 距离
    _locaManager.distanceFilter = kCLDistanceFilterNone;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [_locaManager requestWhenInUseAuthorization];
        //        [_locaManager requestAlwaysAuthorization];
    }

    // 开始定位
    [_locaManager startUpdatingLocation];
}

+ (SVCurentLocation *)sharedInstance
{
    static SVCurentLocation *instance = nil;
    @synchronized (self)
    {
        if (instance == nil)
        {
            instance = [[super allocWithZone:NULL] init];
        }
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
+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [SVCurentLocation sharedInstance];
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
    return [SVCurentLocation sharedInstance];
}

@end
