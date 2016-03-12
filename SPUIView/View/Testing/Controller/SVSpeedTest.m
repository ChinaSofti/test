//
//  SVSpeedTest2.m
//  SpeedPro
//
//  Created by 李灏 on 16/3/11.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVSpeedTest.h"
#import "SVSpeedTestInfo.h"
#import <SPCommon/SVLog.h>
#import <SPService/SVIPAndISPGetter.h>

#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <pthread.h>
#import <sys/socket.h>

const int RECONNECT_WAIT_TIME = 250 * 1000;
const int STEP = 10;
const int DELAY_TEST_COUTN = 5;
const int DELAY_BUFFER_SIZE = 1024;
const int DOWNLOAD_BUFFER_SIZE = 512 * 1024;
const int UPLOAD_BUFFER_SIZE = 16 * 1024;
const int THREAD_NUM = 2;
const int SAMPLE_INTERVAL = 100 * 1000;
const int SAMPLE_COUNT = 100;
const NSString *BUNDORY = @"---------------------------7db1c523809b2";

@implementation SVSpeedTest

long _testId;

id<SVSpeedTestDelegate> _testDelegate;

// 测试状态
TestStatus _testStatus;

SVSpeedTestInfo *_speedTestInfo;

long _downloadSize = 0;

long _uploadSize = 0;

double _speedsAll[100];

SVSpeedTestResult *_testResult;

SVSpeedTestResult *_curTestResult;

SVSpeedTestContext *_testContext;

struct sockaddr_in addr;

double _beginTime;

/**
 *  初始化网页测试对象，初始化必须放在UI主线程中进行
 *
 *  @param testId        测试ID
 *  @param showVideoView UIView 用于显示网页
 *
 *  @return 视频测试对象
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

    _testContext = [[SVSpeedTestContext alloc] init];
    _testResult = [[SVSpeedTestResult alloc] init];
    _speedTestInfo = [[SVSpeedTestInfo alloc] init];

    return TRUE;
}

// 开始测试
- (BOOL)startTest
{
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
    _testStatus = TEST_TESTING;
    [self startDownloadTest];

    // 推送最终结果
    [_testDelegate updateTestResultDelegate:_testContext testResult:_testResult];

    // 启动上传测试
    _testStatus = TEST_TESTING;
    [self startUploadTest];

    // TODO yzy 结果入库

    // 推送最终结果
    [_testDelegate updateTestResultDelegate:_testContext testResult:_testResult];

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
            SVInfo (@"thread create error, tid = %lld", tids[i]);
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
            SVInfo (@"thread create error, tid = %lld", tids[i]);
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
        SVInfo (@"delay test thread create error, tid = %lld", tid);
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
    SVInfo (@"request %@", request);

    _beginTime = [[NSDate date] timeIntervalSince1970];

    while (_testStatus == TEST_TESTING)
    {
        int fd = socket (AF_INET, SOCK_STREAM, 0);
        int ret = connect (fd, (struct sockaddr *)&addr, sizeof (struct sockaddr));
        if (-1 == ret)
        {
            SVInfo (@"connect error, ret = %d", ret);
            usleep (RECONNECT_WAIT_TIME);
            continue;
        }

        long len = write (fd, [request UTF8String], [request length] + 1);
        SVInfo (@"download write len = %ld", len);

        char *buff = (char *)malloc (DOWNLOAD_BUFFER_SIZE * sizeof (char));
        memset (buff, '\0', DOWNLOAD_BUFFER_SIZE);

        len = 0;
        while (_testStatus == TEST_TESTING && (len = read (fd, buff, DOWNLOAD_BUFFER_SIZE)) > 0)
        {
            _downloadSize += len;
        }
    }
}

void upload (int i)
{

    SVInfo (@"Upload-Thread-%d start\n", i);

    int fd = socket (AF_INET, SOCK_STREAM, 0);

    int ret = connect (fd, (struct sockaddr *)&addr, sizeof (struct sockaddr));
    if (-1 == ret)
    {
        SVInfo (@"connect error, ret = %d", ret);
        return;
    }

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

    SVInfo (@"request %@, fileReqesult %@", request, fileRequest);

    char *buff = (char *)malloc (UPLOAD_BUFFER_SIZE * sizeof (char));
    memset (buff, '\0', UPLOAD_BUFFER_SIZE);

    long len = write (fd, [request UTF8String], [request length] + 1);
    len = write (fd, [fileRequest UTF8String], [fileRequest length] + 1);

    int count = 0;
    _beginTime = [[NSDate date] timeIntervalSince1970];
    while (_testStatus == TEST_TESTING && (len = send (fd, buff, UPLOAD_BUFFER_SIZE, 0)) > 0)
    {
        _uploadSize += len;
        if (count % 1000 == 0)
        {
            SVInfo (@"Thread-%d, uploadSize = %ld", i, _uploadSize);
        }
        count++;
    }


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

    SVInfo (@"request %@", request);

    char *buff = (char *)malloc (DELAY_BUFFER_SIZE * sizeof (char));
    memset (buff, '\0', DELAY_BUFFER_SIZE);

    double minDelay = DBL_MAX;
    for (int i = 0; i < DELAY_TEST_COUTN; i++)
    {
        int fd = socket (AF_INET, SOCK_STREAM, 0);

        int ret = connect (fd, (struct sockaddr *)&addr, sizeof (struct sockaddr));
        if (-1 == ret)
        {
            SVInfo (@"delayTest connect error, ret = %d", ret);
            usleep (RECONNECT_WAIT_TIME);
            return;
        }

        long len = write (fd, [request UTF8String], [request length] + 1);
        SVInfo (@"delay test write len = %ld", len);
        double startTime = [[NSDate date] timeIntervalSince1970] * 1000;
        len = read (fd, buff, DELAY_BUFFER_SIZE);
        double delay = [[NSDate date] timeIntervalSince1970] * 1000 - startTime;

        if (delay < minDelay)
        {
            minDelay = delay;
        }

        close (fd);

        SVInfo (@"delay test read len = %ld, delay = %f", len, delay);
    }

    _testResult.delay = minDelay;

    SVInfo (@"minDelay = %fms", minDelay);
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


    while (count++ <= SAMPLE_COUNT)
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

        // 计算秒极结果，用于绘制线图
        if (count != 0 && count % STEP == 0)
        {
            speed = speedSum / STEP;
            speedSum = 0.0;
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

    _testStatus = TEST_FINISHED;

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

    SVInfo (@"totalSize = %ld, costTime = %f", *size, (currentTime - _beginTime));

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
        SVInfo (@"avg = %f, speedAvg = %f", avg, speedAvg);
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

    SVInfo (@"avg speed = %f, len = %ld", speedAvg, len);
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
    SVInfo (@"host:%@, ip: %@", info.host, ip);

    return info;
}

- (NSString *)getIPWithHostName:(const NSString *)hostName
{
    const char *hostN = [hostName UTF8String];
    struct hostent *phot;

    @try
    {
        phot = gethostbyname (hostN);
    }
    @catch (NSException *exception)
    {
        return nil;
    }

    struct in_addr ip_addr;

    memcpy (&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = { 0 };
    inet_ntop (AF_INET, &ip_addr, ip, sizeof (ip));

    NSString *strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}

@end
