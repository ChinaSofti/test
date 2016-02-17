//
//  VideoPlayer.h
//  TaskService
//
//  Created by Rain on 1/21/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVUvMOSCalculator.h"
#import "SVVideoTest.h"
#import "SVVideoTestContext.h"
#import "SVVideoTestResult.h"
#import "Vitamio.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *
 * 视频播放器对象
 *
 */
@interface SVVideoPlayer : NSObject <VMediaPlayerDelegate>

// 视频显示依赖的UIView
@property UIView *showOnView;

// UvMOS计算
@property SVUvMOSCalculator *uvMOSCalculator;

// 视频测试Context
@property SVVideoTestContext *testContext;

// 视频测试结果
@property SVVideoTestResult *testResult;


/**
 *  初始化视频播放器对象
 *
 *  @param showOnView 视频在指定的UIView上进行展示并进行播放
 *
 *  @return 视频播放器对象
 */
- (id)initWithView:(UIView *)showOnView testDelegate:(id<SVVideoTestDelegate>)testDelegate;


/**
 *  播放视频
 */
- (void)play;

/**
 *  停止视频播放
 */
- (void)stop;

/**
 *  是否完成播放
 *
 *  @return TRUE 完成
 */
- (BOOL)isFinished;

@end
