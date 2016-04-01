//
//  SVVideoTest.m
//  SPUIView
//
//  Created by Rain on 2/6/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//
#import "SVDBManager.h"
#import "SVIPAndISPGetter.h"
#import "SVLog.h"
#import "SVProbeInfo.h"
#import "SVTestContextGetter.h"
#import "SVTimeUtil.h"
#import "SVVideoPlayer.h"
#import "SVVideoTest.h"

@implementation SVVideoTest
{
    @private

    // 测试ID
    long long _testId;

    //播放视频的 UIView 组建
    UIView *_showVideoView;

    // 视频地址
    NSString *_videoPath;

    // 视频播放器
    SVVideoPlayer *_videoPlayer;

    // 测试状态
    TestStatus testStatus;
}

@synthesize testResult, testContext;

/**
 *  初始化视频测试对象，初始化必须放在UI主线程中进行
 *
 *  @param testId        测试ID
 *  @param showVideoView UIView 用于显示播放视频
 *
 *  @return 视频测试对象
 */
- (id)initWithView:(long long)testId
     showVideoView:(UIView *)showVideoView
      testDelegate:(id<SVVideoTestDelegate>)testDelegate
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    _testId = testId;
    _showVideoView = showVideoView;
    testStatus = TEST_TESTING;

    if (!_videoPlayer)
    {
        //初始化播放器
        _videoPlayer =
        [[SVVideoPlayer alloc] initWithView:_showVideoView testDelegate:testDelegate];
    }
    SVInfo (@"SVVideoTest testID:%lld  showVideoView:%@", testId, showVideoView);
    return self;
}

/**
 *  初始化TestContext
 */
- (BOOL)initTestContext
{
    @try
    {
        // 初始化TestContext
        SVTestContextGetter *contextGetter = [SVTestContextGetter sharedInstance];
        testContext = [contextGetter getVideoContext];
        if (!testContext)
        {
            SVError (@"test[testId=%lld] fail. there is no test context", _testId);
            return false;
        }
        return true;
    }
    @catch (NSException *exception)
    {
        SVError (@"init test context fail:%@", exception);
        testStatus = TEST_ERROR;
        return false;
    }
}

/**
 *  开始测试
 */
- (BOOL)startTest
{
    @try
    {
        @synchronized (_showVideoView)
        {
            if (testStatus == TEST_TESTING)
            {
                // 初始化TestResult
                if (!testResult)
                {
                    testResult = [[SVVideoTestResult alloc] init];
                    [testResult setTestId:_testId];
                    [testResult setTestTime:_testId];
                }


                // 开始播放视频
                [_videoPlayer setTestContext:testContext];
                [_videoPlayer setTestResult:testResult];
                [_videoPlayer play];
            }
        }

        while (!_videoPlayer.isFinished)
        {
            [NSThread sleepForTimeInterval:1];
        }

        SVInfo (@"test[%lld] finished", _testId);
    }
    @catch (NSException *exception)
    {
        SVError (@"start test video fail:%@", exception);
        testStatus = TEST_ERROR;
        return false;
    }

    // 持久化结果明细
    [self persistSVDetailResultModel];
    SVInfo (@"persist test[testId=%lld] result success", _testId);
    return true;
}

/**
 *   停止测试
 */
- (BOOL)stopTest
{
    @synchronized (_showVideoView)
    {
        if (testStatus == TEST_TESTING)
        {
            testStatus = TEST_FINISHED;
        }

        if (_videoPlayer)
        {
            @try
            {
                //初始化播放器
                [_videoPlayer stop];
                SVInfo (@"stop test [testId=%lld]", _testId);
            }
            @catch (NSException *exception)
            {
                SVError (@"stop play video fail. %@", exception);
                return false;
            }
        }
    }

    return true;
}


/**
 *  持久化结果明细
 */
- (void)persistSVDetailResultModel
{
    SVDBManager *db = [SVDBManager sharedInstance];
    NSString *insertSVDetailResultModelSQL;
    @try
    {
        // 如果表不存在，则创建表
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS SVDetailResultModel(ID integer PRIMARY KEY "
                          @"AUTOINCREMENT, testId integer, testType integer, testResult text, "
                          @"testContext text, probeInfo text);"];

        insertSVDetailResultModelSQL =
        [NSString stringWithFormat:@"INSERT INTO "
                                   @"SVDetailResultModel (testId,testType,testResult, testContext, "
                                   @"probeInfo) VALUES(%lld, %d, "
                                   @"'%@', '%@', '%@');",
                                   _testId, VIDEO, [self testResultToJsonString],
                                   [self testContextToJsonString], [self testProbeInfo]];
        // 插入结果明细
        [db executeUpdate:insertSVDetailResultModelSQL];
    }
    @catch (NSException *exception)
    {
        SVError (@"execute insert SVDetailResultModel SQL[%@] fail. Exception:  %@",
                 insertSVDetailResultModelSQL, exception);
    }
}

- (NSString *)testProbeInfo
{
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    SVIPAndISP *ipAndISP = [SVIPAndISPGetter getIPAndISP];
    if (!ipAndISP)
    {
        return @"";
    }

    [dictionary setObject:!ipAndISP.isp ? @"" : ipAndISP.isp forKey:@"isp"];
    [dictionary setObject:!probeInfo.ip ? @"" : probeInfo.ip forKey:@"ip"];
    [dictionary setObject:!probeInfo.networkType ? @"" : probeInfo.networkType
                   forKey:@"networkType"];
    NSString *bandwidth = [probeInfo getBandwidth];
    [dictionary setObject:!bandwidth ? @"" : bandwidth forKey:@"signedBandwidth"];

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

- (NSString *)testResultToJsonString
{

    float sQualitySession = !testResult.sQualitySession ? 0 : testResult.sQualitySession;
    float sInteractionSession = !testResult.sInteractionSession ? 0 : testResult.sInteractionSession;
    float sViewSession = !testResult.sViewSession ? 0 : testResult.sViewSession;
    float UvMOSSession = !testResult.UvMOSSession ? 0 : testResult.UvMOSSession;
    float firstBufferTime = !testResult.firstBufferTime ? 0 : testResult.firstBufferTime;
    int videoCuttonTimes = !testResult.videoCuttonTimes ? 0 : testResult.videoCuttonTimes;
    int videoCuttonTotalTime = !testResult.videoCuttonTotalTime ? 0 : testResult.videoCuttonTotalTime;
    float downloadSpeed = !testResult.downloadSpeed ? 0 : testResult.downloadSpeed;
    int videoWidth = !testResult.videoWidth ? 0 : testResult.videoWidth;
    int videoHeight = !testResult.videoHeight ? 0 : testResult.videoHeight;
    float frameRate = !testResult.frameRate ? 0 : testResult.frameRate;
    float bitrate = !testResult.bitrate ? 0 : testResult.bitrate;
    float screenSize = !testResult.screenSize ? 0 : testResult.screenSize;
    NSString *videoResolution = !testResult.videoResolution ? @"" : testResult.videoResolution;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[[NSNumber alloc] initWithLongLong:testResult.testTime]
                   forKey:@"testTime"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:sQualitySession]
                   forKey:@"sQualitySession"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:sInteractionSession]
                   forKey:@"sInteractionSession"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:sViewSession] forKey:@"sViewSession"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:UvMOSSession] forKey:@"UvMOSSession"];
    [dictionary setObject:[[NSNumber alloc] initWithLong:firstBufferTime]
                   forKey:@"firstBufferTime"];
    [dictionary setObject:[[NSNumber alloc] initWithInt:videoCuttonTimes]
                   forKey:@"videoCuttonTimes"];
    [dictionary setObject:[[NSNumber alloc] initWithInt:videoCuttonTotalTime]
                   forKey:@"videoCuttonTotalTime"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:downloadSpeed] forKey:@"downloadSpeed"];
    [dictionary setObject:[[NSNumber alloc] initWithInt:videoWidth] forKey:@"videoWidth"];
    [dictionary setObject:[[NSNumber alloc] initWithInt:videoHeight] forKey:@"videoHeight"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:frameRate] forKey:@"frameRate"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:bitrate] forKey:@"bitrate"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:screenSize] forKey:@"screenSize"];
    [dictionary setObject:videoResolution forKey:@"videoResolution"];

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

- (NSString *)testContextToJsonString
{
    //    NSString *videoSegementURLString = !testContext.videoSegementURLString ? @"" :
    //    testContext.videoSegementURLString;
    NSString *videoURLString = !testContext.videoURLString ? @"" : testContext.videoURLString;
    int videoSegementURL = !testContext.videoSegementSize ? 0 : testContext.videoSegementSize;
    int videoSegementDuration = !testContext.videoSegementDuration ? 0 : testContext.videoSegementDuration;
    float videoSegementBitrate = !testContext.videoSegementBitrate ? 0 : testContext.videoSegementBitrate;
    NSString *videoSegementIP = !testContext.videoSegementIP ? @"" : testContext.videoSegementIP;
    NSString *videoSegemnetLocation = !testContext.videoSegemnetLocation ? @"" : testContext.videoSegemnetLocation;
    NSString *videoSegemnetISP = !testContext.videoSegemnetISP ? @"" : testContext.videoSegemnetISP;
    int videoPlayDuration = !testContext.videoPlayDuration ? 60 : testContext.videoPlayDuration;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    [dictionary setObject:[NSNumber numberWithInt:videoPlayDuration] forKey:@"videoPlayDuration"];
    [dictionary setObject:videoURLString forKey:@"videoURL"];
    [dictionary setObject:[[NSNumber alloc] initWithInt:videoSegementURL]
                   forKey:@"videoSegementSize"];
    [dictionary setObject:[[NSNumber alloc] initWithLong:videoSegementDuration]
                   forKey:@"videoSegementDuration"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:videoSegementBitrate]
                   forKey:@"videoSegementBitrate"];
    [dictionary setObject:videoSegementIP forKey:@"videoSegementIP"];
    [dictionary setObject:videoSegemnetLocation forKey:@"videoSegemnetLocation"];
    [dictionary setObject:videoSegemnetISP forKey:@"videoSegemnetISP"];

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
