//
//  SVSpeedDownloadTest.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/4/27.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVSpeedDownloadTest.h"

@implementation SVSpeedDownloadTest
{
    // 下载地址
    NSURL *downloadUrl;

    // 整体测试状态(整个下载测试的状态)
    TestStatus _testStatus;

    // 下载状态(整个下载测试会多次下载文件，此状态是每次下载的状态)
    TestStatus _internalTestStatus;

    // 单次下载是否结束
    BOOL isFinished;

    // 下载大小
    long long downloadSize;
}

- (id)initWithUrl:(NSURL *)url WithTestStatus:(TestStatus)status
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    // 初始化参数
    downloadUrl = url;
    _testStatus = status;
    _internalTestStatus = TEST_TESTING;
    return self;
}

- (void)startTest
{
    SVInfo (@"Download-Thread start\n");

    // 创建request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadUrl];

    // 设置报文头
    [request setHTTPMethod:@"GET"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:downloadUrl.host forHTTPHeaderField:@"Host"];
    [request setValue:@"Close" forHTTPHeaderField:@"Connection"];
    [request setValue:@"gzip, deflate, sdch" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"zh-CN,zh;q=0.8" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"Mozilla/5.0 (iPhone Simulator; U; CPU iPhone OS 6 like Mac OS X; en-us) "
                      @"AppleWebKit/532.9 (KHTML, like Gecko) Mobile/8B117"
    forHTTPHeaderField:@"User-Agent"];

    SVInfo (@"download request %@", request);

    while (_testStatus == TEST_TESTING && _internalTestStatus == TEST_TESTING)
    {
        isFinished = NO;

        // 建立连接
        NSURLConnection *conn =
        [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [conn start];

        while (_testStatus == TEST_TESTING && _internalTestStatus == TEST_TESTING && !isFinished)
        {
            // 每次等待100毫秒，直到下载结束
            NSDate *interval = [NSDate dateWithTimeIntervalSinceNow:0.1];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:interval];
        }

        // 关闭连接
        [conn cancel];
    }
}

// 更新测试状态
- (void)updateStatus:(TestStatus)status
{
    _testStatus = status;
}

// 更新内部测试状态
- (void)updateInnerStatus:(TestStatus)status
{
    _internalTestStatus = status;
}

// 获取下载大小
- (long long)getSize
{
    return downloadSize;
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error)
    {
        SVError (@"download connect error, error:%@", error);

        // 发送错误信息
        [self sendErrorNotice];
    }

    isFinished = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 记录下载大小
    if (data)
    {
        downloadSize += [data length];
    }
}

// 下载结束
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    isFinished = YES;
}

- (void)sendErrorNotice
{
    // 创建一个消息对象
    NSNotification *notice =
    [NSNotification notificationWithName:@"networkStatusError" object:nil userInfo:nil];

    //发送消息
    [[NSNotificationCenter defaultCenter] postNotification:notice];
}

@end
