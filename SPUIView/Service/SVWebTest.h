//
//  SVWebTest.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#import "SVWebTestResult.h"
#import <Foundation/Foundation.h>
#import <SPService/SPService.h>

@import WebKit;

@protocol SVWebTestDelegate <NSObject>

@required
- (void)updateTestResultDelegate:(SVWebTestContext *)testContext
                      testResult:(SVWebTestResult *)testResult;

@end

@interface SVWebTest : NSObject <WKNavigationDelegate>

// 测试结果
@property NSMutableDictionary *webTestResultDic;

// 测试上下文
@property SVWebTestContext *webTestContext;

/**
 *  初始化网页测试对象，初始化必须放在UI主线程中进行
 *
 *  @param testId        测试ID
 *  @param showVideoView UIView 用于显示网页
 *
 *  @return 视频测试对象
 */
- (id)initWithView:(long)testId
       showWebView:(UIView *)showWebView
      testDelegate:(id<SVWebTestDelegate>)testDelegate;

// 初始化测试数据
- (BOOL)initTestContext;

// 开始测试
- (BOOL)startTest;

// 停止测试
- (BOOL)stopTest;

@end
