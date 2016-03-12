//
//  SVSpeedTest2.h
//  SpeedPro
//
//  Created by 李灏 on 16/3/11.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVSpeedTestContext.h"
#import "SVSpeedTestResult.h"
#import <Foundation/Foundation.h>

@protocol SVSpeedTestDelegate <NSObject>

@required
- (void)updateTestResultDelegate:(SVSpeedTestContext *)testContext
                      testResult:(SVSpeedTestResult *)testResult;

@end


@interface SVSpeedTest : NSObject

/**
 *  初始化网页测试对象，初始化必须放在UI主线程中进行
 *
 *  @param testId        测试ID
 *  @param showVideoView UIView 用于显示网页
 *
 *  @return 视频测试对象
 */
- (id)initWithView:(long)testId
     showSpeedView:(UIView *)showSpeedView
      testDelegate:(id<SVSpeedTestDelegate>)testDelegate;

// 初始化测试数据
- (BOOL)initTestContext;

// 开始测试
- (BOOL)startTest;

// 停止测试
- (BOOL)stopTest;


@end
