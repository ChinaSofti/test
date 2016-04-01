//
//  SVUvMOSCalculater.h
//  SPUIView
//
//  Created by Rain on 2/10/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVVideoTestContext.h"
#import "SVVideoTestResult.h"
#import "SVVideoTestSample.h"
#import "UvMOS_Outer_Api.h"
#import <Foundation/Foundation.h>

@interface SVUvMOSCalculator : NSObject

/**
 *  初始化UvMOS值计算器
 *
 *  @param testContext Test Context
 *  @param testResult Test Result
 *
 *  @return UvMOS值计算器
 */
- (id)initWithTestContextAndResult:(SVVideoTestContext *)testContext
                        testResult:(SVVideoTestResult *)testResult;

//- (void)registeService;

/**
 *  开始卡顿和卡顿结束
 *
 *  @param status     卡顿状态
 *  @param iTimeStamp 从开始播放视频到现在
 */
- (void)update:(UvMOSPlayStatus)status time:(int)iTimeStamp;

/**
 *  计算视频样本的U-vMOS值
 *
 *  @param sample     测试视频样本
 *  @param iTimeStamp 从开始播放视频到现在
 */
- (void)calculateUvMOS:(SVVideoTestSample *)sample time:(int)iTimeStamp;

- (void)unRegisteService;
@end
