//
//  SVVideoTest.h
//  SPUIView
//
//  Created by Rain on 2/6/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//


#import "SVVideoTestContext.h"
#import "SVVideoTestResult.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SVVideoTestDelegate <NSObject>

@required
- (void)updateTestResultDelegate:(SVVideoTestContext *)testContext
                      testResult:(SVVideoTestResult *)testResult;

@end

@interface SVVideoTest : NSObject

@property SVVideoTestResult *testResult;

@property SVVideoTestContext *testContext;

/**
 *  初始化视频测试对象，初始化必须放在UI主线程中进行
 *
 *  @param testId        测试ID
 *  @param showVideoView UIView 用于显示播放视频
 *
 *  @return 视频测试对象
 */
- (id)initWithView:(long)testId
     showVideoView:(UIView *)showVideoView
      testDelegate:(id<SVVideoTestDelegate>)testDelegate;

/**
 *  初始化TestContext
 */
- (BOOL)initTestContext;

/**
 *  开始测试
 */
- (BOOL)startTest;

/**
 *  停止测试
 */
- (BOOL)stopTest;
@end
