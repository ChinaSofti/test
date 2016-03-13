//
//  SVSpeedTestResult.h
//  SpeedPro
//
//  Created by 李灏 on 16/3/11.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPService/SVTestResult.h>
@interface SVSpeedTestResult : SVTestResult

// 测试时间
@property double testTime;

// 服务器IP
@property NSString *ipAddress;

// 服务器归属地
@property SVIPAndISP *isp;

// 时延
@property double delay;

// 上传速度
@property double uploadSpeed;

// 下载速度
@property double downloadSpeed;

// true:上传的结果
// false:下载的结果
@property BOOL isUpload;

// true:最终的结果
// false:每次采样的结果
@property BOOL isSummeryResult;

// true:秒级结果
// false:非秒级结果
@property BOOL isSecResult;

@end
