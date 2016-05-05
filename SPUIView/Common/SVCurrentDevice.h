//
//  SVCurrentDevice.h
//  SpeedPro
//
//  Created by Rain on 3/26/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVCurrentDevice : NSObject


/**
 *  获取当前手机型号
 *
 *  @return 手机型号。 i386 和 x86_64 对应的是模拟器
 */
+ (NSString *)deviceType;


+ (NSString *)getIPAddress;

/**
 *  获取WiFi网络名称。
 *  注意：该方法只在真机可用，真机可用正常获取WiFi名称
 *
 *  @return WiFi网络名称
 */
+ (NSString *)getWifiName;

@end
