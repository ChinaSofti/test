//
//  SVSpeedDownloadTest.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/4/27.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVSpeedDownloadTest : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (id)initWithUrl:(NSURL *)url WithTestStatus:(TestStatus)status;

// 开始测试
- (void)startTest;

// 更新测试状态
- (void)updateStatus:(TestStatus)status;

// 更新内部测试状态
- (void)updateInnerStatus:(TestStatus)status;

// 获取下载大小
- (long long)getSize;

@end
