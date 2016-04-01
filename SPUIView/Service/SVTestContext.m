//
//  TSContext.m
//  TaskService
//
//  Created by Rain on 1/28/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVTestContext.h"

@implementation SVTestContext

@synthesize testStatus;

/**
 *  初始化
 *
 *  @param data
 *
 *  @return 对象
 */
- (id)initWithData:(NSData *)data
{
    self = [super init];
    _data = data;
    [self handleAfterInit];
    return self;
}

/**
 *  初始化后做一下操作。用于子类进行重写
 */
- (void)handleAfterInit
{
}


@end
