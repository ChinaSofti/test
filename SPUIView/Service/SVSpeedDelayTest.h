//
//  SVSpeedDelayTest.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/22.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVSpeedTestServer.h"

@interface SVSpeedDelayTest : NSObject

// 时延
@property double delay;

// 带宽测试服务器
@property SVSpeedTestServer *testServer;

// 测试完成
@property BOOL finished;

/**
 * 初始化测试参数
 * @param server 带宽测试服务器
 * @return 该类的实例
 */
- (id)initTestServer:(SVSpeedTestServer *)server;

/**
 * 开始测试
 */
- (void)startTest;

/**
 * 检查下载是否可用
 *
 * @return 是否可用
 */
- (BOOL)checkDownloadServer;

@end
