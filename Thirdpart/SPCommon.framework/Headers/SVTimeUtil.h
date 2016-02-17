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
 *  获取当前系统时间戳
 *
 *  @return 当前系统时间戳
 */
+ (NSString *)currentTimeStamp;

/**
 *  获取当前毫秒时间戳
 *
 *  @return 毫秒时间戳
 */
+ (long)currentMilliSecondStamp;

@end
