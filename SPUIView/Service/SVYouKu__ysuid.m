//
//  TSYouKu__ysuid.m
//  TaskService
//
//  Created by Rain on 1/31/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVTimeUtil.h"
#import "SVYouKu__ysuid.h"

@implementation SVYouKu__ysuid


+ (NSString *)getYsuid:(int)length
{

    NSString *ts = [SVTimeUtil currentTimeStamp];
    return [ts stringByAppendingString:@"abc"];
}

@end
