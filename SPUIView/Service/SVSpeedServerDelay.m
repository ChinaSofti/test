//
//  SVGetSpeedServer.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/17.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVSpeedServerDelay.h"

@implementation SVSpeedServerDelay

@synthesize finished;

// 开始时间
double startTime;

- (void)getserverDelay:(NSURL *)serverUrl
{
    NSURLConnection *conn;
    @try
    {
        // 初始化参数
        finished = NO;

        // 建立连接
        NSString *delayUrl = [NSString stringWithFormat:@"http://%@:%@%@", [serverUrl host], [serverUrl port],
                                                        @"/speedtest/latency.txt"];
        NSURL *url = [[NSURL alloc] initWithString:delayUrl];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        // 记录开始时间
        startTime = [[NSDate date] timeIntervalSince1970] * 1000;

        // 开始连接
        [conn start];

        // 当时延为0或者没有超过3秒则一直等待
        while (!finished && ([[NSDate date] timeIntervalSince1970] * 1000 - startTime) < 3000)
        {
            // 如果响应时间还没有计算出来则等待5ms
            NSDate *interval = [NSDate dateWithTimeIntervalSinceNow:0.005];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:interval];
        }
    }
    @catch (NSException *exception)
    {
        SVError (@"Get speed server failed!cause:%@", exception);
    }
    @finally
    {
        if (conn)
        {
            // 关闭连接
            [conn cancel];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // 结束标志位
    finished = YES;
}

@end
