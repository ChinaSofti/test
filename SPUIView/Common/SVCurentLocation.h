//
//  SVCurentLocation.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/5/23.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SVCurentLocation : NSObject <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locaManager;

/**
 * 获取定位信息
 */
- (void)getUserLocation;

/**
 * 单例模式
 */
+ (SVCurentLocation *)sharedInstance;

@end
