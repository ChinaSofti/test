//
//  SVSpeedDelayTest.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/22.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVSpeedDelayTest.h"

#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>

const int DELAY_BUFFER_SIZE = 1024;

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
    self.delay = 0.0f;
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
    currentAddr.sin_addr.s_addr = inet_addr ([[self getIPWithHostName:testUrl.host] UTF8String]);

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
    int ret = connect (fd, (struct sockaddr *)&currentAddr, sizeof (struct sockaddr));
    if (-1 == ret)
    {
        free (buff);
        buff = NULL;
        SVInfo (@"delayTest connect error, fd = %d, ret = %d", fd, ret);
        return;
    }

    // 计算时延
    long len = write (fd, [request UTF8String], [request length] + 1);
    SVInfo (@"delayTest read len = %ld", len);
    double startTime = [[NSDate date] timeIntervalSince1970] * 1000;
    read (fd, buff, DELAY_BUFFER_SIZE);
    self.delay = [[NSDate date] timeIntervalSince1970] * 1000 - startTime;

    // 关闭socket连接，释放内存
    ret = close (fd);
    free (buff);
    buff = NULL;
    SVInfo (@"delayTest close socket, fd = %d, ret = %d", fd, ret);

    // 测试完成
    self.finished = YES;
}

/**
 * 根据host获取对应的ip地址
 * @param hostName host地址
 * @return IP地址
 */
- (NSString *)getIPWithHostName:(const NSString *)hostName
{
    NSString *strIPAddress = @"0.0.0.0";

    if (!hostName)
    {
        return strIPAddress;
    }

    const char *hostN = [hostName UTF8String];
    struct hostent *phot;

    if (!hostN)
    {
        return strIPAddress;
    }

    phot = gethostbyname (hostN);

    if (!phot || !phot->h_addr_list)
    {
        return strIPAddress;
    }

    struct in_addr ip_addr;

    memcpy (&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = { 0 };
    inet_ntop (AF_INET, &ip_addr, ip, sizeof (ip));

    strIPAddress = [NSString stringWithUTF8String:ip];

    return strIPAddress;
}

@end
