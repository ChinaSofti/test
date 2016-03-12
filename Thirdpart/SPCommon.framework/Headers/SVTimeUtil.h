//
//  TSTimeUtil.h
//  TaskService
//
//  Created by Rain on 1/31/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVTimeUtil : NSObject


/**
 *  获取当前系统秒级别时间戳
 *
 *  @return 当前系统秒级别时间戳
 */
+ (NSString *)currentTimeStamp;

/**
 *  获取当前毫秒时间戳
 *
 *  @return 毫秒时间戳
 */
+ (long)currentMilliSecondStamp;

/**
 *  将毫秒值改成日期格式
 *  @param timeNum 毫秒时间戳
 *  @param formatStr 日期格式
 *  @return 日期字符串
 */
+ (NSString *)formatDateByMilliSecond:(long)timeNum formatStr:(NSString *)formatStr;

@end
