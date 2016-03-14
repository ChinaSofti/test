//
//  SVWebTest.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVNetworkTrafficMonitor.h"
#import "SVWebTest.h"
#import <SPCommon/SVDBManager.h>
#import <SPCommon/SVLog.h>
#import <SPService/SPService.h>

@import WebKit;

@implementation SVWebTest
{
    @private

    // 测试ID
    long _testId;

    //播放视频的 UIView 组建
    UIView *_showWebView;

    // 正在测试的url
    NSString *currentUrl;

    // 当前的流量
    double currentBytes;

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

    // 每隔100毫秒推送一次结果
    id<SVWebTestDelegate> _testDelegate;

    // 测试状态
    TestStatus testStatus;

    // 显示网页的WebView
    WKWebView *_webView;
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
       showWebView:(UIView *)showWebView
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
    _webView = [[WKWebView alloc]
    initWithFrame:CGRectMake (0, 0, _showWebView.size.width, _showWebView.size.height)];
    [_webView setNavigationDelegate:self];
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

        // 初始化测试字典
        self.webTestResultDic = [[NSMutableDictionary alloc] init];
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
            for (NSString *url in webTestContext.urlArray)
            {
                // 初始化数据
                totalTime = 0;
                totalBytes = 0;
                currentUrl = url;
                currentBytes = [[SVNetworkTrafficMonitor getDataCounters] doubleValue];

                // 初始化TestResult
                currentResult = [self.webTestResultDic objectForKey:currentUrl];
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

                // 记录测试开始时间
                startTime = [[NSDate date] timeIntervalSince1970] * 1000;

                // 加载页面，在WebView中显示
                [_webView loadRequest:request];

                // 启动计算下载速度的定时器，当前时间100ms后，每隔100ms执行一次
                caclSeedTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1]
                                                         interval:0.1
                                                           target:self
                                                         selector:@selector (caclSpeed:)
                                                         userInfo:@"Calculate Speed"
                                                          repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:caclSeedTimer forMode:NSDefaultRunLoopMode];

                // 循环直到当前url测试结束，再执行下一个测试
                while (!finished)
                {
                    NSDate *interval = [NSDate dateWithTimeIntervalSinceNow:0.01];
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:interval];
                }

                // 每次测试结束等待1秒
                [NSThread sleepForTimeInterval:3];

                // 关闭定时器和url连接
                [self closeTimer];

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

            // 推送最后一次结果
            [self pushLastResult];

            // 持久化详细结果
            [self persistSVDetailResultModel];
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
        [self closeTimer];
    }
    @catch (NSException *exception)
    {
        SVError (@"stop webTest[testId=%ld] fail,cause:%@", _testId, exception);
        testStatus = TEST_ERROR;
        return NO;
    }
}

// 推送最后一次结果
- (void)pushLastResult
{
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
    if (count > 0)
    {
        [currentResult setResponseTime:(sumResponseTime / count)];
        [currentResult setTotalTime:(sumTotalTime / count)];
        [currentResult setDownloadSpeed:(sumDownloadSpeed / count)];
    }

    // 将平均后的结果推送给前台
    [_testDelegate updateTestResultDelegate:self.webTestContext testResult:currentResult];
}


// 接收第一个包时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    // 判断TestResult是否初始化
    if (!currentResult)
    {
        SVError (@"webTest[testUrl=%@] fail, currentResult is null.", currentUrl);
        return;
    }

    // 计算响应时间
    float responseTime = ([[NSDate date] timeIntervalSince1970] * 1000 - startTime) / 1000;
    [currentResult setResponseTime:responseTime];

    SVInfo (@"%@%@;%@%f", @"Test Url:", currentUrl, @"Response Time:", responseTime);
}

// 页面加载结束时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // 判断TestResult是否初始化
    if (!currentResult)
    {
        SVError (@"webTest[testUrl=%@] fail, currentResult is null.", currentUrl);
        return;
    }

    // 计算下载的大小
    totalBytes = [[SVNetworkTrafficMonitor getDataCounters] doubleValue] - currentBytes;

    // 计算总时间
    totalTime = ([[NSDate date] timeIntervalSince1970] * 1000 - startTime) / 1000;

    // 计算平均下载速度
    double avgSpeed = (totalBytes * 8 / 1024) / totalTime;

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
- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
        withError:(NSError *)error
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

    // 计算下载的大小
    double downloadSize = [[SVNetworkTrafficMonitor getDataCounters] doubleValue] - currentBytes;

    // 加载时间
    double costTime = ([[NSDate date] timeIntervalSince1970] * 1000 - startTime) / 1000;

    // 计算平均下载速度
    double avgSpeed = 0.0;
    if (currentResult.responseTime > 0)
    {
        avgSpeed = (downloadSize * 8 / 1024) / costTime;
    }

    [currentResult setTotalTime:costTime];
    [currentResult setDownloadSpeed:avgSpeed];

    SVInfo (@"%@%@;%@%f;%@%f", @"Test Url:", currentUrl, @"Current Cost Time:", costTime,
            @"Current Dowanload Speed:", avgSpeed);

    // 向页面推送数据
    [_testDelegate updateTestResultDelegate:self.webTestContext testResult:currentResult];

    // 如果超过10S，则任务测试结束
    if (costTime >= 10)
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
- (void)closeTimer
{
    // 关闭定时器
    if (caclSeedTimer)
    {
        [caclSeedTimer invalidate];
        caclSeedTimer = nil;
    }
}

/**
 *  持久化结果明细
 */
- (void)persistSVDetailResultModel
{
    SVDBManager *db = [SVDBManager sharedInstance];

    // 如果表不存在，则创建表
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS SVDetailResultModel(ID integer PRIMARY KEY "
                      @"AUTOINCREMENT, testId integer, testType integer, testResult text, "
                      @"testContext text, probeInfo text);"];

    NSString *insertSVDetailResultModelSQL =
    [NSString stringWithFormat:@"INSERT INTO "
                               @"SVDetailResultModel (testId,testType,testResult, testContext, "
                               @"probeInfo) VALUES(%ld, %d, "
                               @"'%@', '%@', '%@');",
                               _testId, WEB, [self testResultToJsonString],
                               [self testContextToJsonString], [self testProbeInfo]];

    // 插入结果明细
    [db executeUpdate:insertSVDetailResultModelSQL];
}

// probeInfo转换成json字符串
- (NSString *)testProbeInfo
{
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    //    SVInfo (@"SVProbeInfo ip:%@   isp:%@", probeInfo.ip, probeInfo.isp);
    [dictionary setObject:!probeInfo.ip ? @"" : probeInfo.ip forKey:@"ip"];
    //    [dictionary setObject:!probeInfo.isp ? @"" : probeInfo.isp forKey:@"isp"];
    [dictionary setObject:!probeInfo.networkType ? @"" : probeInfo.networkType
                   forKey:@"netWorkType"];
    [dictionary setObject:![probeInfo getBandwidth] ? @"" : [probeInfo getBandwidth]
                   forKey:@"signedBandwidth"];

    return [self dictionaryToJsonString:dictionary];
}

// 测试结果转换成json字符串
- (NSString *)testResultToJsonString
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (NSString *testUrl in [self.webTestResultDic allKeys])
    {
        SVWebTestResult *result = [self.webTestResultDic objectForKey:testUrl];
        NSMutableDictionary *currenDic = [[NSMutableDictionary alloc] init];
        [currenDic setObject:[[NSNumber alloc] initWithLong:result.testTime] forKey:@"testTime"];
        [currenDic setObject:result.testUrl forKey:@"testUrl"];
        [currenDic setObject:[[NSNumber alloc] initWithDouble:result.responseTime]
                      forKey:@"responseTime"];
        [currenDic setObject:[[NSNumber alloc] initWithDouble:result.totalTime]
                      forKey:@"totalTime"];
        [currenDic setObject:[[NSNumber alloc] initWithDouble:result.downloadSpeed]
                      forKey:@"downloadSpeed"];
        NSString *resultStr = [self dictionaryToJsonString:currenDic];

        [dictionary setObject:resultStr forKey:testUrl];
    }

    return [self dictionaryToJsonString:dictionary];
}


// 将testContext转换为json字符串
- (NSString *)testContextToJsonString
{
    NSArray *_urlArray = [self.webTestContext urlArray];
    if (_urlArray)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:[self.webTestContext urlArray] forKey:@"urlArray"];

        return [self dictionaryToJsonString:dictionary];
    }
    return @"";
}

// 将字典转换成json字符串
- (NSString *)dictionaryToJsonString:(NSMutableDictionary *)dictionary
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error)
    {
        SVError (@"%@", error);
        return @"";
    }
    else
    {
        NSString *resultJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return resultJson;
    }
}

@end
