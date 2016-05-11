//
//  SVSpeedDelayTest.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/22.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVHttpsTools.h"
#import "SVSpeedDelayTest.h"
#import <arpa/inet.h>

const int DELAY_BUFFER_SIZE = 512;

@implementation SVSpeedDelayTest
{
    // 建立socket需要的request
    NSString *request;

    // 建立socket需要的参数
    struct sockaddr_in currentAddr;
}
@synthesize delay, testServer, finished;


/**
 * 初始化测试参数
 * @param server 带宽测试服务器
 */
- (id)initTestServer:(SVSpeedTestServer *)server
{
    // 初始化对象
    self = [super init];
    if (!self)
    {
        return nil;
    }

    // 初始化server
    self.testServer = server;
    self.delay = -1;
    self.finished = NO;

    // 初始化测试参数
    NSURL *url = [NSURL URLWithString:server.serverURL];
    NSURL *testUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", url.host, url.port,
                                                                     @"/speedtest/latency.txt"]];

    // 连接请求
    request = [NSString
    stringWithFormat:@"%@ %@ HTTP/1.1\r\nAccept: %@\r\nHost: %@\r\nConnection: "
                     @"%@\r\nAccept-Encoding:gzip, deflate, sdch "
                     @"\r\nAccept-Language:zh-CN,zh;q=0.8\r\nUser-Agent:Mozilla/5.0 (iPhone "
                     @"Simulator; U; CPU iPhone OS 6 like Mac OS X; en-us) AppleWebKit/532.9 "
                     @"(KHTML, like Gecko) Mobile/8B117\r\n\r\n",
                     @"GET", testUrl.path, @"*/*", testUrl.host, @"Close"];
    SVInfo (@"delayTest request %@", request);

    // 初始化建立socket连接的参数
    memset (&currentAddr, 0, sizeof (currentAddr));
    currentAddr.sin_len = sizeof (currentAddr);
    currentAddr.sin_family = AF_INET;
    currentAddr.sin_addr.s_addr = INADDR_ANY;
    currentAddr.sin_port = htons ([testUrl.port intValue]);
    currentAddr.sin_addr.s_addr = inet_addr ([[SVHttpsTools getIPWithHostName:testUrl.host] UTF8String]);

    return self;
}

/**
 * 开始测试
 */
- (void)startTest
{
    // 建立socket连接
    char *buff = (char *)malloc (DELAY_BUFFER_SIZE * sizeof (char));
    memset (buff, '\0', DELAY_BUFFER_SIZE);
    int fd = socket (AF_INET, SOCK_STREAM, 0);

    // 设置超时时间
    struct timeval timeout = { 2, 0 }; // 2s
    setsockopt (fd, SOL_SOCKET, SO_SNDTIMEO, (const char *)&timeout, sizeof (timeout));
    setsockopt (fd, SOL_SOCKET, SO_RCVTIMEO, (const char *)&timeout, sizeof (timeout));

    // 开始连接
    __block int ret = -1;
    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      ret = connect (fd, (struct sockaddr *)&currentAddr, sizeof (struct sockaddr));
    });

    // 等待连接成功，如果超过两秒，则认为超时
    double startTime = [[NSDate date] timeIntervalSince1970] * 1000;
    while (ret == -1 && ([[NSDate date] timeIntervalSince1970] * 1000 - startTime) < 2000)
    {
        [NSThread sleepForTimeInterval:0.001];
    }
    if (-1 == ret)
    {
        // 关闭socket连接，释放内存
        ret = close (fd);
        free (buff);
        buff = NULL;
        SVInfo (@"delayTest connect timeout, fd = %d, ret = %d", fd, ret);
        return;
    }

    // 计算时延
    long len = write (fd, [request UTF8String], [request length] + 1);
    SVInfo (@"delayTest read len = %ld", len);
    startTime = [[NSDate date] timeIntervalSince1970] * 1000;
    read (fd, buff, DELAY_BUFFER_SIZE);
    self.delay = [[NSDate date] timeIntervalSince1970] * 1000 - startTime;

    // 如果超时，则将时延设为-1
    if (self.delay >= 2000)
    {
        self.delay = -1;
    }

    // 关闭socket连接，释放内存
    ret = close (fd);
    free (buff);
    buff = NULL;
    SVInfo (@"delayTest close socket, fd = %d, ret = %d", fd, ret);

    // 测试完成
    self.finished = YES;
}

@end
