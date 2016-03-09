//
//  SVWebTest.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVWebTest.h"
#import <SPCommon/SVLog.h>
#import <SPService/SPService.h>

@implementation SVWebTest
{
    @private

    // 测试ID
    long _testId;

    //播放视频的 UIView 组建
    UIView *_showWebView;

    // 正在测试的url
    NSString *currentUrl;

    // 测试开始时间
    double startTime;

    // 测试总时间
    double totalTime;

    // 下载总大小
    long totalBytes;

    // 当前测试是否结束
    BOOL finished;

    // 当前测试结果
    SVWebTestResult *currentResult;

    // 计算下载速度的定时器
    NSTimer *caclSeedTimer;

    // 当前url的连接
    NSURLConnection *currentConn;

    // 每隔100毫秒推送一次结果
    id<SVWebTestDelegate> _testDelegate;

    // 测试状态
    TestStatus testStatus;

    // 显示网页的WebView
    UIWebView *_webView;
}

@synthesize webTestContext, webTestResultDic;


/**
 *  初始化网页测试对象，初始化必须放在UI主线程中进行
 *
 *  @param testId        测试ID
 *  @param showVideoView UIView 用于显示网页
 *
 *  @return 视频测试对象
 */
- (id)initWithView:(long)testId
     showVideoView:(UIView *)showWebView
      testDelegate:(id<SVWebTestDelegate>)testDelegate
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    _testId = testId;
    _showWebView = showWebView;
    _testDelegate = testDelegate;
    testStatus = TEST_TESTING;
    finished = NO;

    SVInfo (@"SVWebTest testID:%ld  showVideoView:%@", testId, showWebView);

    // 初始化UIWebView
    _webView = [[UIWebView alloc]
    initWithFrame:CGRectMake (0, 0, _showWebView.size.width, _showWebView.size.height)];
    [_showWebView addSubview:_webView];
    return self;
}

// 初始化测试数据
- (BOOL)initTestContext
{
    @try
    {
        // 初始化Test Context
        SVTestContextGetter *contextGetter = [SVTestContextGetter sharedInstance];
        webTestContext = [contextGetter getWebContext];

        if (!webTestContext)
        {
            SVError (@"webTest[testId=%ld] fail. there is no test context", _testId);
            return NO;
        }
        return YES;
    }
    @catch (NSException *exception)
    {
        SVError (@"init web test context fail:%@", exception);
        testStatus = TEST_ERROR;
        return NO;
    }
}

// 开始测试
- (BOOL)startTest
{
    @try
    {
        if (testStatus == TEST_TESTING)
        {
            //            NSArray *urls = @[
            //                @"http://www.12306.cn",
            //                @"http://www.taobao.com",
            //                @"http://www.youku.com",
            //                @"http://www.tudou.com"
            //            ];
            for (NSString *url in webTestContext.urlArray)
            {
                // 初始化数据
                totalTime = 0;
                totalBytes = 0;
                currentUrl = url;

                // 初始化TestResult
                currentResult = self.webTestResultDic[currentUrl];
                if (!currentResult)
                {
                    currentResult = [[SVWebTestResult alloc] init];
                    [currentResult setTestId:_testId];
                    [currentResult setTestTime:_testId];
                    [currentResult setTestUrl:currentUrl];
                }

                SVInfo (@"%@%@", @"Start Web Test！ Test Url:", currentUrl);

                // 测试的url
                NSURL *testUrl = [[NSURL alloc] initWithString:currentUrl];

                // 通过NSURLConnection加载页面，用于计算各种指标
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:testUrl
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:10];
                currentConn =
                [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                [currentConn scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                       forMode:NSDefaultRunLoopMode];

                // 记录测试开始时间
                startTime = [[NSDate date] timeIntervalSince1970] * 1000;

                // 加载页面，再WebView中显示
                [_webView loadRequest:request];

                // 开始连接
                [currentConn start];

                // 循环直到当前url测试结束，再执行下一个测试
                while (!finished)
                {
                    NSDate *interval = [NSDate dateWithTimeIntervalSinceNow:0.01];
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:interval];
                }

                // 每次测试结束等待1秒
                [NSThread sleepForTimeInterval:1];

                // 关闭定时器和url连接
                [self closeTimerAndConn];

                // 设置标志位
                finished = NO;
            }

            // 移除UIWebView
            dispatch_async (dispatch_get_main_queue (), ^{
              [_webView removeFromSuperview];
            });

            // 设置测试状态
            testStatus = TEST_FINISHED;
            webTestContext.testStatus = testStatus;

            // 计算平均值
            double sumResponseTime = 0.0;
            double sumTotalTime = 0.0;
            double sumDownloadSpeed = 0.0;
            for (SVWebTestResult *result in [self.webTestResultDic allValues])
            {
                sumResponseTime += [result responseTime];
                sumTotalTime += [result totalTime];
                sumDownloadSpeed += [result downloadSpeed];
            }
            NSUInteger count = [self.webTestResultDic count];
            [currentResult setResponseTime:(sumResponseTime / count)];
            [currentResult setTotalTime:(sumTotalTime / count)];
            [currentResult setDownloadSpeed:(sumDownloadSpeed / count)];

            // 将平均后的结果推送给前台
            [_testDelegate updateTestResultDelegate:self.webTestContext testResult:currentResult];
        }
    }
    @catch (NSException *exception)
    {
        SVError (@"webTest[testId=%ld] fail,cause:%@", _testId, exception);
        testStatus = TEST_ERROR;
        return NO;
    }
    return YES;
}

- (BOOL)stopTest
{
    @try
    {
        // 设置测试状态
        if (testStatus == TEST_TESTING)
        {
            testStatus = TEST_FINISHED;
            webTestContext.testStatus = testStatus;
        }

        // 关闭定时器和url连接
        [self closeTimerAndConn];
    }
    @catch (NSException *exception)
    {
        SVError (@"stop webTest[testId=%ld] fail,cause:%@", _testId, exception);
        testStatus = TEST_ERROR;
        return NO;
    }
}

// 重定向时调用
//- (NSURLRequest *)connection:(NSURLConnection *)connection
//             willSendRequest:(NSURLRequest *)request
//            redirectResponse:(NSURLResponse *)response
//{
//    NSLog (@"================================================");
//    NSLog (@"will send request\n%@", [request URL]);
//    NSLog (@"redirect response\n%@", [response URL]);
//
//    return request;
//}

// 接收第一个包时调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // 判断TestResult是否初始化
    if (!currentResult)
    {
        SVError (@"webTest[testUrl=%@] fail, currentResult is null.", currentUrl);
        return;
    }

    // 计算响应时间
    float responseTime = [[NSDate date] timeIntervalSince1970] * 1000 - startTime;
    [currentResult setResponseTime:responseTime];

    SVInfo (@"%@%@;%@%f", @"Test Url:", currentUrl, @"Response Time:", responseTime);

    // 启动计算下载速度的定时器，当前时间100ms后，每隔100ms执行一次
    caclSeedTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1]
                                             interval:0.1
                                               target:self
                                             selector:@selector (caclSpeed:)
                                             userInfo:@"Calculate Speed"
                                              repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:caclSeedTimer forMode:NSDefaultRunLoopMode];
}

// 分批接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 记录页面下载的总大小
    totalBytes = totalBytes + [data length];
}

// 页面加载结束时调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 判断TestResult是否初始化
    if (!currentResult)
    {
        SVError (@"webTest[testUrl=%@] fail, currentResult is null.", currentUrl);
        return;
    }

    // 计算总时间
    totalTime = [[NSDate date] timeIntervalSince1970] * 1000 - startTime;

    // 计算平均下载速度
    double avgSpeed = (totalBytes * 8 / 1024) / (totalTime / 1000);

    [currentResult setTotalTime:totalTime];
    [currentResult setDownloadSpeed:avgSpeed];

    // 记录日志
    SVInfo (@"%@%@;%@%f;%@%f", @"Test Url:", currentUrl, @"Total Time:", totalTime,
            @"Avg Dowanload Speed:", avgSpeed);

    // 向页面推送数据
    [_testDelegate updateTestResultDelegate:self.webTestContext testResult:currentResult];

    // 将结果放入字典
    [self.webTestResultDic setValue:currentResult forKey:currentUrl];

    // 当前url测试结束
    finished = YES;
}

// 加载页面失败时调用
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error)
    {
        SVError (@"request URL:%@ fail.  Error:%@", currentUrl, error);
        finished = YES;
    }
}

// 计算下载速度，每隔100ms计算一次
- (void)caclSpeed:(NSTimer *)timer
{
    // 判断TestResult是否初始化
    if (!currentResult)
    {
        SVError (@"webTest[testUrl=%@] fail, currentResult is null.", currentUrl);
        return;
    }

    // 加载时间
    double costTime = [[NSDate date] timeIntervalSince1970] * 1000 - startTime;

    // 计算平均下载速度
    double avgSpeed = (totalBytes * 8 / 1024) / (costTime / 1000);

    [currentResult setTotalTime:costTime];
    [currentResult setDownloadSpeed:avgSpeed];

    SVInfo (@"%@%@;%@%f;%@%f", @"Test Url:", currentUrl, @"Current Cost Time:", costTime,
            @"Current Dowanload Speed:", avgSpeed);

    // 向页面推送数据
    [_testDelegate updateTestResultDelegate:self.webTestContext testResult:currentResult];

    // 如果超过10S，则任务测试结束
    if (costTime >= 10000)
    {
        finished = YES;
    }
}


- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
         forAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection *)connection
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

// 关闭定时器和url连接
- (void)closeTimerAndConn
{
    // 关闭定时器
    if (caclSeedTimer)
    {
        [caclSeedTimer invalidate];
        caclSeedTimer = nil;
    }


    // 关闭连接
    if (currentConn)
    {
        [currentConn cancel];
        currentConn = nil;
    }
}

@end
