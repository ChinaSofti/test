//
//  SVSpeedDownloadTest.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/4/27.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVSpeedTest.h"
#import "SVSpeedTestResult.h"
#import <Foundation/Foundation.h>

@interface SVSpeedDownloadTest : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (id)initWithUrl:(NSURL *)url
     WithDelegate:(id)currDelegate
       WithTestId:(long long)testId
   WithTestResult:(SVSpeedTestResult *)testResult
   WithTestContet:(SVSpeedTestContext *)testContext
   WithTestStatus:(TestStatus)status;

// 开始测试
- (void)startTest;

// 更新测试状态
- (void)updateStatus:(TestStatus)status;

@end
