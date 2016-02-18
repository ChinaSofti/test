//
//  SVAdvancedSetting.h
//  SPUIView
//
//  Created by Rain on 2/17/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVAdvancedSetting : NSObject


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
 *  设置屏幕尺寸
 *
 *  @param screenSize 屏幕尺寸
 */
- (void)setScreenSize:(float)screenSize;

/**
 *  查询屏幕尺寸
 *
 *  @return 屏幕尺寸
 */
- (NSString *)getScreenSize;

@end
