//
//  TSTimeUtil.m
//  TaskService
//
//  Created by Rain on 1/31/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVTimeUtil.h"

@implementation SVTimeUtil

/**
 *  获取当前系统秒级别时间戳
 *
 *  @return 当前系统秒级别时间戳
 */
+ (NSString *)currentTimeStamp
{
    double time = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeNum = [NSNumber numberWithDouble:time];
    return [NSString stringWithFormat:@"%zd", [timeNum longLongValue]];
}

/**
 *  获取当前毫秒时间戳
 *
 *  @return 毫秒时间戳
 */
+ (long long)currentMilliSecondStamp
{

    double time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSNumber *timeNum = [NSNumber numberWithDouble:time];
    return [timeNum longLongValue];
}

/**
 *  将毫秒值改成日期格式
 *  @param timeNum 毫秒时间戳
 *  @param formatStr 日期格式
 *  @return 日期字符串
 */
+ (NSString *)formatDateByMilliSecond:(long long)timeNum formatStr:(NSString *)formatStr
{
    NSNumber *time = [NSNumber numberWithLongLong:(timeNum / 1000)];
    NSDate *nd = [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formatStr];
    NSString *dateString = [dateFormat stringFromDate:nd];
    return dateString;
}

@end
