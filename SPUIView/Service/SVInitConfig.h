//
//  SVInitConfig.h
//  SpeedPro
//
//  Created by JinManli on 16/5/17.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVInitConfig : NSObject

// 配置是否初始化成功
@property BOOL isSuccess;

// 带宽服务器配置是否初始化成功
@property BOOL initServerIsSuccess;

/**
 *  单例对象
 */
+ (instancetype)sharedManager;

/**
 *  重新初始化数据 - 启动界面和重载界面调用
 */
- (void)loadResouceFromServer;

/**
 *  重新初始化数据 - 定期检查，定时器调用此方法
 */
- (void)loadResouceForTimer;

@end
