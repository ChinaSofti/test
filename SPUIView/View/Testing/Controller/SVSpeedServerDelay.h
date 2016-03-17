//
//  SVGetSpeedServer.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/17.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVSpeedServerDelay : NSObject <NSURLConnectionDataDelegate>

// 是否测试结束
@property BOOL finished;

// 获取服务器时延
- (void)getserverDelay:(NSURL *)serverUrl;

@end
