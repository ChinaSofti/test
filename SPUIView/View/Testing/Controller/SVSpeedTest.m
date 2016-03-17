//
//  SVSpeedTest2.m
//  SpeedPro
//
//  Created by 李灏 on 16/3/11.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVResultPush.h"
#import "SVSpeedServerDelay.h"
#import "SVSpeedTest.h"
#import "SVSpeedTestInfo.h"
#import <SPCommon/SVDBManager.h>
#import <SPCommon/SVLog.h>
#import <SPService/SVIPAndISPGetter.h>
#import <SPService/SVSpeedTestServers.h>

#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <pthread.h>
#import <sys/socket.h>

const int RECONNECT_WAIT_TIME = 500 * 1000;
const int STEP = 5;
const int DELAY_TEST_COUTN = 5;
const int DELAY_BUFFER_SIZE = 1024;
const int DOWNLOAD_BUFFER_SIZE = 512 * 1024;
const int UPLOAD_BUFFER_SIZE = 16 * 1024;
const int THREAD_NUM = 2;
const int SAMPLE_INTERVAL = 200 * 1000;
const int SAMPLE_COUNT = 50;
const NSString *BUNDORY = @"---------------------------7db1c523809b2";

@implementation SVSpeedTest

long _testId;

id<SVSpeedTestDelegate> _testDelegate;

// 测试状态
TestStatus _testStatus;

TestStatus _internalTestStatus;

SVSpeedTestInfo *_speedTestInfo;

long _downloadSize = 0;

long _uploadSize = 0;

double _speedsAll[SAMPLE_COUNT];

SVSpeedTestResult *_testResult;

SVSpeedTestResult *_curTestResult;

SVSpeedTestContext *_testContext;

struct sockaddr_in addr;

double _beginTime;

/**
 *  初始化带宽测试对象，初始化必须放在UI主线程中进行
 *
 *  @param testId        测试ID
 *  @param showVideoView UIView 用于显示网页
 *
 *  @return 带宽测试对象
 */
- (id)initWithView:(long)testId
     showSpeedView:(UIView *)showSpeedView
      testDelegate:(id<SVSpeedTestDelegate>)testDelegate
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    _testId = testId;
    _testDelegate = testDelegate;

    return self;
}

// 初始化测试数据
- (BOOL)initTestContext
{
    _testStatus = TEST_TESTING;
    _internalTestStatus = TEST_TESTING;

    _testContext = [[SVSpeedTestContext alloc] init];
    _testResult = [[SVSpeedTestResult alloc] init];
    _speedTestInfo = [[SVSpeedTestInfo alloc] init];

    _downloadSize = 0;
    _uploadSize = 0;

    double starttime = [[NSDate date] timeIntervalSince1970] * 1000;
    // 获取带宽测试地址
    [self getSpeedTestUrl];
    NSLog (@"################%.2f############", [[NSDate date] timeIntervalSince1970] * 1000 - starttime);

    return TRUE;
}

// 获取带宽测试的测试地址
- (void)getSpeedTestUrl
{
    // 获取所有的带宽测试服务器
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    NSArray *serverArray = [servers getAllServer];

    // 遍历前五个服务器，得到时延最小的一个
    NSMutableArray *serverUrlArray = [[NSMutableArray alloc] init];
    long size = [serverArray count] < 5 ? [serverArray count] : 5;
    for (int i = 0; i < size; i++)
    {
        SVSpeedTestServer *server = serverArray[i];
        NSURL *url = [NSURL URLWithString:server.serverURL];

        // 在线程中计算时延
        dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          SVSpeedServerDelay *serverDelay = [[SVSpeedServerDelay alloc] init];
          [serverDelay getserverDelay:url];

          // 等待时延测试结束
          while (!serverDelay.finished)
          {
              NSDate *interval = [NSDate dateWithTimeIntervalSinceNow:0.005];
              [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:interval];
          }
          [serverUrlArray addObject:url];
        });
    }

    // 需要等待五个服务器的时延都计算出来
    while ([serverUrlArray count] == 0)
    {
        NSDate *interval = [NSDate dateWithTimeIntervalSinceNow:0.005];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:interval];
    }

    // 初始化默认服务器地址
    NSURL *url = serverUrlArray[0];

    // 获取测试地址
    NSString *host = [url host];
    NSNumber *port = [url port];

    _testContext.downloadUrl =
    [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", host, port,
                                                    @"/speedtest/random4000x4000.jpg"]];

    _testContext.uploadUrl =
    [NSURL URLWithString:[NSString
                         stringWithFormat:@"http://%@:%@%@", host, port, @"/speedtest/upload.php"]];

    _testContext.delayUrl =
    [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", host, port,
                                                    @"/speedtest/latency.txt"]];
}

// 开始测试
- (BOOL)startTest
{
    // 设置屏幕不会休眠
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    _testResult.testId = _testId;
    _testResult.testTime = [[NSDate date] timeIntervalSince1970] * 1000;

    // 解析域名
    _speedTestInfo = [self analyse];
    _testResult.ipAddress = _speedTestInfo.ip;
    memset (&addr, 0, sizeof (addr));
    addr.sin_len = sizeof (addr);
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons ([_speedTestInfo.port intValue]);
    addr.sin_addr.s_addr = inet_addr ([_speedTestInfo.ip UTF8String]);

    // 启动时延测试
    [self startDelayTest];

    // 查询服务器归属地
    _testResult.isp = [SVIPAndISPGetter queryIPDetail:_speedTestInfo.ip];

    // 启动下载测试
    _internalTestStatus = TEST_TESTING;
    if (_testStatus == TEST_TESTING)
    {
        [self startDownloadTest];
    }

    // 推送最终结果
    [_testDelegate updateTestResultDelegate:_testContext testResult:_testResult];

    // 启动上传测试
    _internalTestStatus = TEST_TESTING;
    if (_testStatus == TEST_TESTING)
    {
        [self startUploadTest];
    }

    if (_testStatus == TEST_TESTING)
    {
        // 推送最终结果
        [_testDelegate updateTestResultDelegate:_testContext testResult:_testResult];

        // 结果入库
        [self persistSVDetailResultModel];

        sleep (2);
        _testContext.testStatus = TEST_FINISHED;
        _internalTestStatus = TEST_FINISHED;

        [_testDelegate updateTestResultDelegate:_testContext testResult:_testResult];
    }

    // 取消屏幕不会休眠的设置
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    return TRUE;
}

- (BOOL)startDownloadTest
{
    pthread_t tids[THREAD_NUM];
    for (int i = 0; i < THREAD_NUM; i++)
    {
        int ret = pthread_create (&tids[i], NULL, (void *)download, i);
        if (ret != 0)
        {
            SVInfo (@"startDownloadTest thread create error, tid = %lld", tids[i]);
        }
    }

    pthread_t spTid;
    pthread_create (&spTid, NULL, (void *)sample, false);

    for (int i = 0; i < THREAD_NUM; i++)
    {
        pthread_join (tids[i], NULL);
    }
    pthread_join (spTid, NULL);

    return YES;
}

- (BOOL)startUploadTest
{
    pthread_t tids[THREAD_NUM];
    for (int i = 0; i < THREAD_NUM; i++)
    {
        int ret = pthread_create (&tids[i], NULL, (void *)upload, i);
        if (ret != 0)
        {
            SVInfo (@"startUploadTest thread create error, tid = %lld", tids[i]);
        }
    }

    pthread_t spTid;
    pthread_create (&spTid, NULL, (void *)sample, true);

    for (int i = 0; i < THREAD_NUM; i++)
    {
        pthread_join (tids[i], NULL);
    }
    pthread_join (spTid, NULL);

    return YES;
}

- (BOOL)startDelayTest
{
    pthread_t tid;
    int ret = pthread_create (&tid, NULL, (void *)delayTest, 0);
    if (ret != 0)
    {
        SVInfo (@"startDelayTest thread create error, tid = %lld", tid);
    }

    return YES;
}

void download (int i)
{
    SVInfo (@"Download-Thread-%d start\n", i);

    NSString *request = [NSString
    stringWithFormat:@"%@ %@ HTTP/1.1\r\nAccept: %@\r\nHost: %@\r\nConnection: "
                     @"%@\r\nAccept-Encoding:gzip, deflate, sdch "
                     @"\r\nAccept-Language:zh-CN,zh;q=0.8\r\nUser-Agent:Mozilla/5.0 (iPhone "
                     @"Simulator; U; CPU iPhone OS 6 like Mac OS X; en-us) AppleWebKit/532.9 "
                     @"(KHTML, like Gecko) Mobile/8B117\r\n\r\n",
                     @"GET", _speedTestInfo.downloadPath, @"*/*", _speedTestInfo.host, @"Close"];
    SVInfo (@"download request %@", request);

    char *buff = (char *)malloc (DOWNLOAD_BUFFER_SIZE * sizeof (char));
    memset (buff, '\0', DOWNLOAD_BUFFER_SIZE);

    _beginTime = [[NSDate date] timeIntervalSince1970];

    while (_testStatus == TEST_TESTING && _internalTestStatus == TEST_TESTING)
    {
        int fd = socket (AF_INET, SOCK_STREAM, 0);
        int ret = connect (fd, (struct sockaddr *)&addr, sizeof (struct sockaddr));
        if (-1 == ret)
        {
            SVInfo (@"download connect error, fd = ret = %d", fd, ret);
            usleep (RECONNECT_WAIT_TIME);
            continue;
        }

        long len = write (fd, [request UTF8String], [request length] + 1);
        SVInfo (@"download write len = %ld", len);

        len = 0;
        while (_testStatus == TEST_TESTING && _internalTestStatus == TEST_TESTING &&
               (len = read (fd, buff, DOWNLOAD_BUFFER_SIZE)) > 0)
        {
            _downloadSize += len;
        }

        ret = close (fd);
        SVInfo (@"download close socket, fd = %d, ret = %d", fd, ret);
    }

    free (buff);
    buff = NULL;

    SVInfo (@"download over, downloadSize = %ld", _downloadSize);
}

void upload (int i)
{

    SVInfo (@"Upload-Thread-%d start\n", i);

    NSString *request = [NSString
    stringWithFormat:@"%@ %@ HTTP/1.1\r\nAccept: %@\r\nHost: %@\r\nConnection: "
                     @"%@\r\nAccept-Charset: utf-8\r\nAccept-Encoding:gzip, deflate, sdch "
                     @"\r\nAccept-Language:zh-CN,zh;q=0.8\r\nContent-Type: multipart/form-data; "
                     @"boundary=%@\r\nContent-Length:0\r\nUser-Agent:Mozilla/5.0 (iPhone "
                     @"Simulator; U; CPU iPhone OS 6 like Mac OS X; en-us) AppleWebKit/532.9 "
                     @"(KHTML, like Gecko) Mobile/8B117\r\n\r\n",
                     @"POST", _speedTestInfo.uploadUrl, @"*/*", _speedTestInfo.host, @"keep-alive", BUNDORY];

    NSString *fileRequest =
    [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"file.jpg\"\r\n", BUNDORY];

    SVInfo (@"upload request %@, fileReqesult %@", request, fileRequest);

    char *buff = (char *)malloc (UPLOAD_BUFFER_SIZE * sizeof (char));
    memset (buff, '\0', UPLOAD_BUFFER_SIZE);

    _beginTime = [[NSDate date] timeIntervalSince1970];
    while (_testStatus == TEST_TESTING && _internalTestStatus == TEST_TESTING)
    {
        int fd = socket (AF_INET, SOCK_STREAM, 0);

        int ret = connect (fd, (struct sockaddr *)&addr, sizeof (struct sockaddr));
        if (-1 == ret)
        {
            SVInfo (@"upload connect error, fd = %d, ret = %d", fd, ret);
            usleep (RECONNECT_WAIT_TIME);
            continue;
        }

        long len = write (fd, [request UTF8String], [request length] + 1);
        len = write (fd, [fileRequest UTF8String], [fileRequest length] + 1);

        while (_testStatus == TEST_TESTING && _internalTestStatus == TEST_TESTING &&
               (len = send (fd, buff, UPLOAD_BUFFER_SIZE, 0)) > 0)
        {
            _uploadSize += len;
        }

        ret = close (fd);
        SVInfo (@"upload close socket, fd = %d, ret = %d", fd, ret);
    }

    free (buff);
    buff = NULL;

    SVInfo (@"upload over, uploadSize = %ld", _uploadSize);
}


void delayTest (int i)
{
    SVInfo (@"DelayTest-Thread-%d start\n", i);

    NSString *request = [NSString
    stringWithFormat:@"%@ %@ HTTP/1.1\r\nAccept: %@\r\nHost: %@\r\nConnection: "
                     @"%@\r\nAccept-Encoding:gzip, deflate, sdch "
                     @"\r\nAccept-Language:zh-CN,zh;q=0.8\r\nUser-Agent:Mozilla/5.0 (iPhone "
                     @"Simulator; U; CPU iPhone OS 6 like Mac OS X; en-us) AppleWebKit/532.9 "
                     @"(KHTML, like Gecko) Mobile/8B117\r\n\r\n",
                     @"GET", _speedTestInfo.delayPath, @"*/*", _speedTestInfo.host, @"Close"];

    SVInfo (@"delayTest request %@", request);

    char *buff = (char *)malloc (DELAY_BUFFER_SIZE * sizeof (char));
    memset (buff, '\0', DELAY_BUFFER_SIZE);

    double minDelay = DBL_MAX;
    for (int i = 0; _testStatus == TEST_TESTING && i < DELAY_TEST_COUTN; i++)
    {
        int fd = socket (AF_INET, SOCK_STREAM, 0);

        int ret = connect (fd, (struct sockaddr *)&addr, sizeof (struct sockaddr));
        if (-1 == ret)
        {
            SVInfo (@"delayTest connect error, fd = %d, ret = %d", fd, ret);
            usleep (RECONNECT_WAIT_TIME);
            continue;
        }

        long len = write (fd, [request UTF8String], [request length] + 1);
        SVInfo (@"delayTest write len = %ld", len);
        double startTime = [[NSDate date] timeIntervalSince1970] * 1000;
        len = read (fd, buff, DELAY_BUFFER_SIZE);
        double delay = [[NSDate date] timeIntervalSince1970] * 1000 - startTime;

        if (delay < minDelay)
        {
            minDelay = delay;
        }

        ret = close (fd);

        SVInfo (@"delayTest close socket, fd = %d, ret = %d", fd, ret);
    }

    _testResult.delay = minDelay == DBL_MAX ? 0.0 : minDelay;

    free (buff);
    buff = NULL;

    SVInfo (@"delayTest over, delay = %fms", _testResult.delay);
}

void sample (BOOL isUpload)
{
    _curTestResult = [[SVSpeedTestResult alloc] init];
    _curTestResult.testId = _testId;
    _curTestResult.isUpload = isUpload;
    _curTestResult.isSummeryResult = NO;

    memset (_speedsAll, 0, sizeof (_speedsAll));
    long *size = isUpload ? &_uploadSize : &_downloadSize;
    long preSize = *size;
    double time = [[NSDate date] timeIntervalSince1970];
    double preTime = time;
    double speed = 0.0;
    double speedSum = 0.0;
    double speedAvg = 0.0;

    int count = 0;

    while (count++ <= SAMPLE_COUNT && _testStatus == TEST_TESTING)
    {
        usleep (SAMPLE_INTERVAL);

        time = [[NSDate date] timeIntervalSince1970];
        if (time <= preTime)
        {
            speed = 0.0;
        }
        else
        {
            speed = (*size - preSize) * 8.0 / (time - preTime) / 1000000;
        }
        preTime = time;
        preSize = *size;

        speedSum += speed;
        _speedsAll[count] = speed;

        // 组装100ms结果并推送给前台,此结果用来刷新表盘，不入库
        _curTestResult.testTime = time;
        _curTestResult.isSecResult = NO;

        // 计算秒极结果，用于绘制线图
        if (count != 0 && count % STEP == 0)
        {
            speed = speedSum / STEP;
            speedSum = 0.0;
            _curTestResult.isSecResult = YES;
            SVInfo (@"sample speed = %f", speed);
        }

        if (isUpload)
        {
            _curTestResult.uploadSpeed = speed;
            _curTestResult.downloadSpeed = _testResult.downloadSpeed;
        }
        else
        {
            _curTestResult.downloadSpeed = speed;
        }

        _curTestResult.isp = _testResult.isp;
        _curTestResult.delay = _testResult.delay;

        // 推送
        [_testDelegate updateTestResultDelegate:_testContext testResult:_curTestResult];
    }

    _internalTestStatus = TEST_FINISHED;

    // 采样结束，计算平均速度
    // speedSum = 0.0;
    //    long len = sizeof (_speeds) / sizeof (_speeds[0]);
    //    BOOL flag = false;
    //    int validSpeedCount = 0;
    //    for (int i = 0; i < len; i++)
    //    {
    //        if (_speeds[i] > 0.001)
    //        {
    //            // 从第一个速度大于0.001的采样点开始
    //            flag = true;
    //        }
    //
    //        if (flag)
    //        {
    //            speedSum += _speeds[i];
    //            validSpeedCount++;
    //        }
    //    }
    //
    //    if (validSpeedCount < 1)
    //    {
    //        speedAvg = 0;
    //    }
    //    else
    //    {
    //        speedAvg = speedSum / validSpeedCount;
    //    }

    double currentTime = [[NSDate date] timeIntervalSince1970];
    speedAvg = *size * 8.0 / (currentTime - _beginTime) / 1000000;

    SVInfo (@"sample, totalSize = %ld, costTime = %f", *size, (currentTime - _beginTime));

    // 所有50个采样点，排序，去除最小30%和最大10%的采样点，再取平均值
    long len = sizeof (_speedsAll) / sizeof (_speedsAll[0]);
    sort (&_speedsAll, len);

    int startIndex = len * 0.3 + 1;
    int endIndex = len * 0.9;

    speedSum = 0.0;
    if (endIndex > startIndex)
    {
        for (int i = startIndex; i < endIndex; i++)
        {
            speedSum += _speedsAll[i];
        }

        double avg = speedSum / (endIndex - startIndex);
        SVInfo (@"sample, avg = %f, speedAvg = %f", avg, speedAvg);
        if (avg > speedAvg)
        {
            speedAvg = avg;
        }
    }

    if (isUpload)
    {
        _testResult.uploadSpeed = speedAvg;
    }
    else
    {
        _testResult.downloadSpeed = speedAvg;
    }

    _testResult.isSummeryResult = YES;

    SVInfo (@"sample over, isUpload = %d, avg speed = %f, len = %ld", isUpload, speedAvg, len);
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
                               _testId, BANDWIDTH, [self testResultToJsonString],
                               [self testContextToJsonString], [self testProbeInfo]];

    // 插入结果明细
    [db executeUpdate:insertSVDetailResultModelSQL];
}


// 测试结果转换成json字符串
- (NSString *)testResultToJsonString
{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];

    [dic setObject:[[NSNumber alloc] initWithLong:_testResult.testTime] forKey:@"testTime"];
    [dic setObject:[[NSNumber alloc] initWithDouble:_testResult.delay] forKey:@"delay"];
    [dic setObject:[[NSNumber alloc] initWithDouble:_testResult.downloadSpeed]
            forKey:@"downloadSpeed"];
    [dic setObject:[[NSNumber alloc] initWithDouble:_testResult.uploadSpeed] forKey:@"uploadSpeed"];
    [dic setObject:_testResult.ipAddress forKey:@"ipAddress"];

    if (_testResult.isp)
    {
        if (_testResult.isp.city)
        {
            [dic setObject:_testResult.isp.city forKey:@"location"];
        }
        if (_testResult.isp.isp)
        {
            [dic setObject:_testResult.isp.isp forKey:@"isp"];
        }
    }

    NSString *json = [self dictionaryToJsonString:dic];

    SVInfo (@"testResultToJsonString:  %@", json);

    return json;
}

// probeInfo转换成json字符串
- (NSString *)testProbeInfo
{
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    SVIPAndISP *ipAndISP = [SVIPAndISPGetter getIPAndISP];
    //    SVInfo (@"SVProbeInfo ip:%@   isp:%@", probeInfo.ip, probeInfo.isp);
    [dictionary setObject:!probeInfo.ip ? @"" : probeInfo.ip forKey:@"ip"];
    [dictionary setObject:!ipAndISP.isp ? @"" : ipAndISP.isp forKey:@"isp"];
    [dictionary setObject:!probeInfo.networkType ? @"" : probeInfo.networkType
                   forKey:@"netWorkType"];
    [dictionary setObject:![probeInfo getBandwidth] ? @"" : [probeInfo getBandwidth]
                   forKey:@"signedBandwidth"];

    NSString *json = [self dictionaryToJsonString:dictionary];

    SVInfo (@"testProbeInfo:  %@", json);

    return json;
}

// 将testContext转换为json字符串
- (NSString *)testContextToJsonString
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];


    [dic setObject:[_testContext.delayUrl absoluteString] forKey:@"delayUrl"];
    [dic setObject:[_testContext.downloadUrl absoluteString] forKey:@"downloadUrl"];
    [dic setObject:[_testContext.uploadUrl absoluteString] forKey:@"uploadUrl"];

    NSString *json = [self dictionaryToJsonString:dic];

    SVInfo (@"testContextToJsonString:  %@", json);

    return json;
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

void sort (double *a, int n)
{
    int i, j;
    double temp;
    for (i = 0; i < n - 1; i++)
    {
        for (j = i + 1; j < n; j++)
        {
            if (a[i] > a[j])
            {
                temp = a[i];
                a[i] = a[j];
                a[j] = temp;
            }
        }
    }
}
// 停止测试
- (BOOL)stopTest
{
    _testStatus = TEST_FINISHED;
    _internalTestStatus = TEST_FINISHED;

    // 取消屏幕不会休眠的设置
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    SVInfo (@"stop speed test!!!!");

    return TRUE;
}

/**
 * 解析域名，封装socket参数
 */
- (SVSpeedTestInfo *)analyse
{
    SVSpeedTestInfo *info = [[SVSpeedTestInfo alloc] init];
    info.downloadUrl = _testContext.downloadUrl;
    info.downloadPath = [_testContext.downloadUrl path];
    info.uploadUrl = _testContext.uploadUrl;
    info.uploadPath = [_testContext.uploadUrl path];
    info.delayUrl = _testContext.delayUrl;
    info.delayPath = [_testContext.delayUrl path];

    info.host = [_testContext.downloadUrl host];
    info.port = [_testContext.downloadUrl port];
    NSString *ip = [self getIPWithHostName:info.host];
    info.ip = ip;

    SVInfo (@"analyse, host:%@, ip: %@", info.host, ip);

    return info;
}

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
