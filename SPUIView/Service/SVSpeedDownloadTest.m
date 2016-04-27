//
//  SVSpeedDownloadTest.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/4/27.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVSpeedDownloadTest.h"
#import "SVSpeedTest.h"
#import "SVSpeedTestResult.h"

const int CACL_COUNT = 50;

@implementation SVSpeedDownloadTest
{
    // 下载地址
    NSURL *downloadUrl;

    // 协议类
    id<SVSpeedTestDelegate> delegate;

    // 开始时间
    double beginTime;

    // 上次计算速度的时间
    double preTime;

    // 整体测试状态(整个下载测试的状态)
    TestStatus _testStatus;

    // 下载状态(整个下载测试会多次下载文件，此状态是每次下载的状态)
    TestStatus _internalTestStatus;

    // 下载大小
    long long downloadSize;

    // 上次获取的下载大小
    long long preDownloadSize;

    // 计算下载速度的定时器
    NSTimer *caclSeedTimer;

    // 当前结果
    SVSpeedTestResult *_curTestResult;

    // 总结果
    SVSpeedTestResult *_testResult;

    // 测试上下文
    SVSpeedTestContext *_testContext;

    // 实时下载速度
    double speed;

    // 总下载速度
    double speedSum;

    // 平均下载速度
    double speedAvg;

    // 计算次数，最多计算50次
    int count;

    // 单次下载是否结束
    BOOL isFinished;

    // 记录每次计算的速度
    NSMutableArray *speedAll;
}

- (id)initWithUrl:(NSURL *)url
     WithDelegate:(id<SVSpeedTestDelegate>)currDelegate
       WithTestId:(long long)testId
   WithTestResult:(SVSpeedTestResult *)testResult
   WithTestContet:(SVSpeedTestContext *)testContext
   WithTestStatus:(TestStatus)status
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    // 初始化参数
    downloadUrl = url;
    delegate = currDelegate;
    _testResult = testResult;
    _testContext = testContext;
    _testStatus = status;
    _internalTestStatus = TEST_TESTING;

    _curTestResult = [[SVSpeedTestResult alloc] init];
    _curTestResult.testId = testId;
    _curTestResult.isUpload = NO;
    _curTestResult.isSummeryResult = NO;

    speed = 0.0;
    speedSum = 0.0;
    speedAvg = 0.0;
    count = 0;
    preDownloadSize = 0;

    speedAll = [[NSMutableArray alloc] init];
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

        // 定时器只需要初始化一次
        if (!caclSeedTimer)
        {
            beginTime = [[NSDate date] timeIntervalSince1970];
            preTime = beginTime;

            // 启动计算下载速度的定时器，当前时间200ms后，每隔200ms执行一次
            caclSeedTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.2]
                                                     interval:0.2
                                                       target:self
                                                     selector:@selector (caclSpeed)
                                                     userInfo:@"Calculate Speed"
                                                      repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:caclSeedTimer forMode:NSDefaultRunLoopMode];
        }

        while (_testStatus == TEST_TESTING && _internalTestStatus == TEST_TESTING && !isFinished)
        {
            // 每次等待100毫秒，直到下载结束
            NSDate *interval = [NSDate dateWithTimeIntervalSinceNow:0.1];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:interval];
        }

        // 关闭连接
        [conn cancel];
        SVInfo (@"download close connection!");
    }

    // 计算结果
    double currentTime = [[NSDate date] timeIntervalSince1970];
    speedAvg = downloadSize * 8.0 / (currentTime - beginTime) / 1000000;

    SVInfo (@"download totalSize = %lld, costTime = %f", downloadSize, (currentTime - beginTime));

    // 所有50个采样点，排序，去除最小30%和最大10%的采样点，再取平均值
    long len = [speedAll count];
    [speedAll sortUsingComparator:^NSComparisonResult (__strong id obj1, __strong id obj2) {
      return [obj1 intValue] > [obj2 intValue];
    }];

    int startIndex = len * 0.3 + 1;
    int endIndex = len * 0.9;

    speedSum = 0.0;
    if (endIndex > startIndex)
    {
        for (int i = startIndex; i < endIndex; i++)
        {
            speedSum += [speedAll[i] doubleValue];
        }

        double avg = speedSum / (endIndex - startIndex);
        if (avg > speedAvg)
        {
            speedAvg = avg;
        }
    }

    [_testResult setIsUpload:NO];
    _testResult.downloadSpeed = speedAvg;
    _testResult.isSummeryResult = YES;

    SVInfo (@"download over, downloadSize = %lld, avg speed = %f", downloadSize, speedAvg);
}

- (void)caclSpeed
{
    if (count > CACL_COUNT)
    {
        _internalTestStatus = TEST_FINISHED;
        return;
    }

    double currentTime = [[NSDate date] timeIntervalSince1970];
    if (currentTime <= preTime)
    {
        speed = 0.0;
    }
    else
    {
        speed = (downloadSize - preDownloadSize) * 8.0 / (currentTime - preTime) / 1000000;
    }
    preTime = currentTime;
    preDownloadSize = downloadSize;

    speedSum += speed;
    [speedAll addObject:[[NSNumber alloc] initWithDouble:speed]];

    // 组装100ms结果并推送给前台,此结果用来刷新表盘，不入库
    _curTestResult.testTime = currentTime;
    _curTestResult.isSecResult = NO;

    // 计算秒极结果，用于绘制线图
    if (count != 0 && count % 5 == 0)
    {
        speed = speedSum / 5;
        speedSum = 0.0;
        _curTestResult.isSecResult = YES;
        SVInfo (@"Second speed = %f", speed);
    }

    _curTestResult.downloadSpeed = speed;
    _curTestResult.isp = _testResult.isp;
    _curTestResult.delay = _testResult.delay;

    count++;

    // 推送
    [delegate updateTestResultDelegate:_testContext testResult:_curTestResult];
}

// 更新测试状态
- (void)updateStatus:(TestStatus)status
{
    _testStatus = status;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error)
    {
        SVError (@"download connect error, error:%@", error);
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

@end
