//
//  TSContext.h
//  TaskService
//
//  Created by Rain on 1/28/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 测试执行状态
 */
typedef enum _TestStatus {
    // 未知状态
    TEST_UNKNOWN = 0,
    // 测试中
    TEST_TESTING = 1,
    // 测试中止
    TEST_INTERUPT = 2,
    // 测试失败
    TEST_ERROR = 3,
    // 测试完成
    TEST_FINISHED = 4

} TestStatus;


/**
 * 测试执行状态
 */
typedef enum _TestType {
    // 视频
    VIDEO = 0,
    // 网页
    WEB = 1,
    // 带宽
    BANDWIDTH = 2
} TestType;

@interface SVTestContext : NSObject
{
    NSData *_data;
}

// 测试状态
@property TestStatus testStatus;

/**
 *  初始化
 *
 *  @param data
 *
 *  @return 对象
 */
- (id)initWithData:(NSData *)data;

/**
 *  初始化后做一下操作。用于子类进行重写
 */
- (void)handleAfterInit;


@end
