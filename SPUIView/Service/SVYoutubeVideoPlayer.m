//
//  SVYoutubeVideoPlayer.m
//  SpeedPro
//
//  Created by Rain on 3/29/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVLog.h"
#import "SVProbeInfo.h"
#import "SVTimeUtil.h"
#import "SVVideoSegement.h"
#import "SVYoutubeVideoPlayer.h"

NSString static *const kYTPlaybackQualitySmallQuality = @"small";
NSString static *const kYTPlaybackQualityMediumQuality = @"medium";
NSString static *const kYTPlaybackQualityLargeQuality = @"large";
NSString static *const kYTPlaybackQualityHD720Quality = @"hd720";
NSString static *const kYTPlaybackQualityHD1080Quality = @"hd1080";
NSString static *const kYTPlaybackQualityHighResQuality = @"highres";
NSString static *const kYTPlaybackQualityAutoQuality = @"auto";
NSString static *const kYTPlaybackQualityDefaultQuality = @"default";
NSString static *const kYTPlaybackQualityUnknownQuality = @"unknown";

static NSString *useragent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_1 like Mac OS X) "
                             @"AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Mobile/9B206 "
                             @"Safari/601.3.9";

@implementation SVYoutubeVideoPlayer
{
    // 视频是否准备好，可以进行播放
    BOOL _didPrepared;

    WKWebView *_webView;

    // 开始缓冲时间
    long long _bufferStartTime;

    // 总下载大小
    int _downloadSize;
    // 总下载时长
    int _downloadTime;

    // 每5秒周期卡顿次数
    int videoCuttonTimes;

    // 每5秒周期卡顿总时长
    int videoCuttonTotalTime;

    // 缓冲时间集合
    NSMutableArray *bufferedTimeArray;

    // 加载图标
    UIActivityIndicatorView *activityView;

    // 每隔5秒推送一次结果
    id<SVVideoTestDelegate> _testDelegate;

    // 定时器
    NSTimer *timer;

    // 计算UvMOS次数
    int execute_times;

    BOOL isFinished;

    long long startPlayTime;

    BOOL _isSetup;

    int _videoPlayTime;

    // 正在测试的分片信息
    SVVideoSegement *segement;
}

@synthesize showOnView, testResult, testContext, uvMOSCalculator;

// 计算UvMOS总次数
static int execute_total_times = 4;

/**
 *  初始化视频播放器对象
 *
 *  @param showOnView 视频在指定的UIView上进行展示并进行播放
 *
 *  @return 视频播放器对象
 */
- (id)initWithView:(UIView *)_showOnView testDelegate:(id<SVVideoTestDelegate>)testDelegate;
{
    self = [super init];
    if (self)
    {
        showOnView = _showOnView;
        _testDelegate = testDelegate;
        SVInfo (@"init player view:%@", _showOnView);

        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [config setRequiresUserActionForMediaPlayback:NO];
        [config setAllowsInlineMediaPlayback:YES];
        [config setAllowsPictureInPictureMediaPlayback:NO];
        [config.userContentController addScriptMessageHandler:self name:@"YoutubeVideoPlayer_OC"];

        CGSize size = _showOnView.frame.size;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake (0, 0, size.width, size.height)
                                      configuration:config];
        [_webView setCustomUserAgent:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) "
                                     @"AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 "
                                     @"Safari/537.36"];
        [_webView setContentMode:UIViewContentModeScaleToFill];
        [_showOnView addSubview:_webView];
    }
    return self;
}

/**
 *  播放视频
 */
- (void)play
{

    if (!testContext || !testResult)
    {
        SVError (@"test context or test result is null. so refuse play video.");
        return;
    }

    startPlayTime = [SVTimeUtil currentMilliSecondStamp];
    [testResult setVideoStartPlayTime:startPlayTime];
    [testContext setTestStatus:TEST_TESTING];

    SVInfo (@"video play time is:%d", testContext.videoPlayDuration);
    execute_total_times = testContext.videoPlayDuration * 5;

    // 初始化UvMOS组件
    [self initUvMOSCompent];

    // 获取要测试的分片信息
    segement = testContext.videoSegementInfo[0];

    if (segement.videoSegementURLStr)
    {
        NSString *playerHtmlPath = [self getPlayerHtmlPath];
        //调用逻辑
        if (playerHtmlPath)
        {
            NSString *vid = testContext.vid;
            //            NSString *quality = [self getQuality];
            NSString *quality = @"small";
            if (!vid)
            {
                vid = @"6v2L2UGZJAM";
            }

            // 自适应高宽
            float width = 768;
            float height = 486;
            if (kScale == 3)
            {
                width = _webView.frame.size.width * kScale * 1.35;
                height = _webView.frame.size.height * kScale * 1.35;
            }
            else
            {
                width = _webView.frame.size.width * kScale * 2;
                height = _webView.frame.size.height * kScale * 2;
            }

            playerHtmlPath =
            [NSString stringWithFormat:@"file://%@?vid=%@&quality=%@&width=%f&height=%f",
                                       playerHtmlPath, vid, quality, width, height];

            if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
            {
                // iOS9. One year later things are OK.
                SVInfo (@"load player.html from resource directory. URL:%@", playerHtmlPath);
                NSURL *fileURL = [NSURL URLWithString:playerHtmlPath];
                [_webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
            }
            else
            {
                // iOS8. Things can be workaround-ed
                SVInfo (@"load player.html from tmp directory. URL:%@", playerHtmlPath);
                NSURL *fileURL = [self fileURLForBuggyWKWebView8:[NSURL fileURLWithPath:playerHtmlPath]];
                NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
                [_webView loadRequest:request];
            }
        }
    }
}

- (NSString *)getQuality
{
    NSString *quality = segement.videoQuality;
    if (!quality)
    {
        return kYTPlaybackQualityDefaultQuality;
    }
    else if ([quality containsString:@"240p"] || [quality containsString:@"144p"])
    {
        return kYTPlaybackQualitySmallQuality;
    }
    else if ([quality containsString:@"360p"])
    {
        return kYTPlaybackQualityMediumQuality;
    }
    else if ([quality containsString:@"480p"])
    {
        return kYTPlaybackQualityLargeQuality;
    }
    else if ([quality containsString:@"720p"])
    {
        return kYTPlaybackQualityHD720Quality;
    }
    else if ([quality containsString:@"1080p"])
    {
        return kYTPlaybackQualityHD1080Quality;
    }
    else if ([quality containsString:@"2160p"] || [quality containsString:@"1440p"])
    {
        return kYTPlaybackQualityHighResQuality;
    }
    else
    {
        return kYTPlaybackQualityDefaultQuality;
    }
}


- (NSString *)getPlayerHtmlPath
{
    // 资源目录
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirArray = [fileManager subpathsAtPath:resourcePath];
    NSString *playerHtmlPath;
    for (NSString *path in dirArray)
    {
        if ([path containsString:@"player.html"])
        {
            playerHtmlPath = [resourcePath stringByAppendingPathComponent:path];
            break;
        }
    }

    if (!playerHtmlPath)
    {
        SVError (@"player.html path get fail. checking the file is exist or not.");
        return playerHtmlPath;
    }

    SVInfo (@"player.html path:%@", playerHtmlPath);
    return playerHtmlPath;
}


- (NSURL *)fileURLForBuggyWKWebView8:(NSURL *)fileURL
{
    NSError *error = nil;
    if (!fileURL.fileURL || ![fileURL checkResourceIsReachableAndReturnError:&error])
    {
        return nil;
    }
    // Create "/temp/www" directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory ()] URLByAppendingPathComponent:@"www"];
    [fileManager createDirectoryAtURL:temDirURL
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];

    NSURL *dstURL = [temDirURL URLByAppendingPathComponent:fileURL.lastPathComponent];
    // Now copy given file to the temp directory
    [fileManager removeItemAtURL:dstURL error:&error];
    [fileManager copyItemAtURL:fileURL toURL:dstURL error:&error];
    // Files in "/temp/www" load flawlesly :)
    return dstURL;
}


/**
 *  初始化UvMOS组件
 */
- (void)initUvMOSCompent
{
    uvMOSCalculator =
    [[SVUvMOSCalculator alloc] initWithTestContextAndResult:testContext testResult:testResult];

    //    // 注册UvMOS计算服务
    //    [uvMOSCalculator registeService];
}

/**
 *  停止视频播放
 */
- (void)stop
{
    @synchronized (testContext)
    {
        if (isFinished)
        {
            return;
        }

        @try
        {
            // 隐藏加载图标
            [activityView stopAnimating];
            //取消定时器
            [timer invalidate];
            timer = nil;
            //            // 视频正在播放，则停止视频
            //            if (_VMpalyer)
            //            {
            //                BOOL isPlaying = [_VMpalyer isPlaying];
            //                if (isPlaying)
            //                {
            //                    SVInfo (@"vmplayer pause");
            //                    [_VMpalyer pause];
            //                }
            //
            //                [_VMpalyer reset];
            //                SVInfo (@"vmplayer reset");
            //                [_VMpalyer unSetupPlayer];
            //            }
        }
        @catch (NSException *exception)
        {
            SVError (@"stop video fail. exception:%@", exception);
        }

        [testResult setDownloadSize:_downloadSize];
        if (_downloadTime > 0)
        {
            [testResult setDownloadSpeed:(_downloadSize * 8 / _downloadTime)];
        }
        [testResult setVideoEndPlayTime:[SVTimeUtil currentMilliSecondStamp]];

        // 取消 UvMOS 注册服务
        [uvMOSCalculator unRegisteService];
        if (testContext.testStatus == TEST_TESTING)
        {
            testContext.testStatus = TEST_FINISHED;
        }

        isFinished = TRUE;
        //        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

/**
 *  是否完成播放
 *
 *  @return TRUE 完成
 */
- (BOOL)isFinished
{
    return isFinished;
}


- (void)prepareVideo
{
    if (segement.videoSegementURL)
    {
        SVInfo (@"prepareVideo");
        //播放时不要锁屏
        //        [UIApplication sharedApplication].idleTimerDisabled = YES;
        // 设置缓冲大小为2倍码率
        //        [_VMpalyer setBufferSize:testContext.videoSegementBitrate * 2 * 1024];
        //        [_VMpalyer setDataSource:testContext.videoSegementURL];
        //        [_VMpalyer prepareAsync];
    }
}

/**
 * Called when the player prepared.
 * 当'播放器准备完成'时, 该协议方法被调用, 我们可以在此调用 [player start]来开始音视频的播放.
 *
 * @param player The shared media player instance.
 * @param arg Not use.
 */
- (void)mediaPlayer_didPrepared
{
    // 隐藏加载图标
    if ([activityView isAnimating])
    {
        [activityView stopAnimating];
    }

    int firstBufferedTime = (int)([SVTimeUtil currentMilliSecondStamp] - startPlayTime);
    [testResult setFirstBufferTime:firstBufferedTime];

    SVInfo (@"------------------------------didPrepared------------------------------");
    _didPrepared = YES;

    SVVideoTestSample *sample = [[SVVideoTestSample alloc] init];
    [sample setPeriodLength:0];
    [sample setInitBufferLatency:testResult.firstBufferTime];
    [sample setAvgVideoBitrate:testResult.bitrate];
    [sample setAvgKeyFrameSize:testResult.frameRate];
    [sample setStallingFrequency:20];
    [sample setStallingDuration:0];
    [sample setVideoStartPlayTime:[testResult videoStartPlayTime]];
    [sample setVideoTotalCuttonTime:0];

    long long endTime = [SVTimeUtil currentMilliSecondStamp];
    int interval = (int)(endTime - [testResult videoStartPlayTime]);
    [uvMOSCalculator calculateUvMOS:sample time:interval];

    if (!testResult.videoTestSamples)
    {
        testResult.videoTestSamples = [[NSMutableArray alloc] init];
    }
    [testResult.videoTestSamples addObject:sample];
    [_testDelegate updateTestResultDelegate:testContext testResult:testResult];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                             target:self
                                           selector:@selector (pushTestSample)
                                           userInfo:nil
                                            repeats:YES];
}

/**
 * Called when the player playback completed.
 * 当'该音视频播放完毕'时, 该协议方法被调用, 我们可以在此作一些播放器善后操作, 如: 重置播放器,
 * 准备播放下一个音视频等
 *
 * @param player The shared media player instance.
 * @param arg Not use.
 */
- (void)mediaPlayer_playbackComplete
{
    _didPrepared = NO;
    execute_times = execute_total_times;
    [self pushTestSample];
    SVInfo (@"------------------------------playbackComplete------------------------------");
}

/**
 * Called when the player have error occur.
 * 如果播放由于某某原因发生了错误, 导致无法正常播放, 该协议方法被调用, 参数 arg 包含了错误原因.

 * @param player The shared media player instance.
 * @param arg Contain the detail error information.
 */
- (void)mediaPlayer_error
{
    SVInfo (@"------------------------------VMediaPlayer Error------------------------------");
    [activityView stopAnimating];
    testContext.testStatus = TEST_ERROR;
}


/**
 * Called when the download rate change.
 *
 * This method is only useful for online media stream.
 *
 * @param player The shared media player instance.
 * @param arg *NSNumber* type, *int* value. The rate in KBytes/s.
 */
- (void)mediaPlayer_downloadRate
{
    //    SVInfo (@"------------------------------downloadRate: %d", [arg intValue]);
    //    _downloadSize += [arg intValue];
    //    _downloadTime += 1;
    //    if ((int)arg >= testContext.videoSegementBitrate)
    //    {
    //        int bufferedTime = (int)([SVTimeUtil currentMilliSecondStamp] - startPlayTime);
    //        [self startCalculateUvMOS_bufferedTime:bufferedTime];
    //    }
}

- (void)mediaPlayer_bufferingStart
{
    SVInfo (@"NAL 2HBT &&&&&&&&&&&&&&&&.......&&&&&&&&&&&&&&&&& bufferingStart");
    _bufferStartTime = [SVTimeUtil currentMilliSecondStamp];
    // 显示加载图标
    if (![activityView isAnimating])
    {
        [activityView startAnimating];
    }

    // 卡顿开始
    int interval = (int)([SVTimeUtil currentMilliSecondStamp] - [testResult videoStartPlayTime]);
    [uvMOSCalculator update:STATUS_IMPAIR_START time:interval];
}

/**
 *  缓冲结束开始播放视频
 *
 *  @param player 播放器
 *  @param arg    arg
 */
- (void)mediaPlayer_bufferingEnd
{
    // 隐藏加载图标
    if ([activityView isAnimating])
    {
        [activityView stopAnimating];
    }

    int bufferedTime = (int)([SVTimeUtil currentMilliSecondStamp] - _bufferStartTime);

    // 注意：
    // 首次缓冲时长不计入卡顿时长，且第一次缓冲不算卡顿。首次缓冲时长只是首次缓冲时长

    // 卡顿次数加一
    videoCuttonTimes += 1;
    videoCuttonTotalTime += bufferedTime;
    [testResult setVideoCuttonTimes:(testResult.videoCuttonTimes + 1)];
    [testResult setVideoCuttonTotalTime:(testResult.videoCuttonTotalTime + bufferedTime)];

    // 卡顿结束
    int interval = (int)([SVTimeUtil currentMilliSecondStamp] - [testResult videoStartPlayTime]);
    [uvMOSCalculator update:STATUS_IMPAIR_END time:interval];

    SVInfo (@"NAL 3HBT &&&&&&&&&&&&&&&&.......&&&&&&&&&&&&&&&&&  bufferingEnd");
}

- (void)pushTestSample
{
    @try
    {
        SVVideoTestSample *sample = [[SVVideoTestSample alloc] init];
        [sample setPeriodLength:5];
        [sample setInitBufferLatency:0];
        [sample setAvgVideoBitrate:testResult.bitrate];
        [sample setAvgKeyFrameSize:testResult.frameRate];
        [sample setVideoStartPlayTime:[testResult videoStartPlayTime]];
        [sample setVideoTotalCuttonTime:testResult.videoCuttonTotalTime];
        if (videoCuttonTimes <= 0)
        {
            [sample setStallingFrequency:0];
            [sample setStallingDuration:0];
        }
        else
        {
            [sample setStallingFrequency:videoCuttonTimes];
            [sample setStallingDuration:(videoCuttonTotalTime / videoCuttonTimes)];
        }

        int interval = (int)([SVTimeUtil currentMilliSecondStamp] - [testResult videoStartPlayTime]);
        [uvMOSCalculator calculateUvMOS:sample time:interval];

        [testResult.videoTestSamples addObject:sample];
        videoCuttonTimes = 0;
        videoCuttonTotalTime = 0;

        execute_times += 1;
        if (execute_times >= execute_total_times)
        {
            [testResult setSViewSession:sample.sViewSession];
            [testResult setSInteractionSession:sample.sInteractionSession];
            [testResult setSQualitySession:sample.sQualitySession];
            [testResult setUvMOSSession:sample.UvMOSSession];
            [self stop];
        }

        [_testDelegate updateTestResultDelegate:testContext testResult:testResult];
    }
    @catch (NSException *exception)
    {
        SVError (@"%@", exception);
    }
}


#pragma mark - WKScriptMessageHandler protocol

/*! @abstract Invoked when a script message is received from a webpage.
 @param userContentController The user content controller invoking the
 delegate method.
 @param message The script message received.
 */
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog (@"----------------------------Message: %@", message.body);
    NSLog (@"%@", [message.body class]);
    NSDictionary *dic = message.body;
    NSString *type = [dic valueForKey:@"type"];
    if ([type containsString:@"onPlayerReady"])
    {
        [self mediaPlayer_didPrepared];
    }
    else if ([type containsString:@"onPlayerStateChange"])
    {
        //        -1 – 未开始
        //        0 – 已结束
        //        1 – 正在播放
        //        2 – 已暂停
        //        3 – 正在缓冲
        //        5 – 已插入视频
    }

    else if ([type containsString:@"onPlaybackQualityChange"])
    {
        //        suggestedQuality 参数的值可以为small、medium、large、hd720、hd1080、highres 或
        //        default。我们建议您将参数值设置为 default，这会指示 YouTube
        //        选择最适合的播放质量，具体质量会因不同用户、视频、系统和其他播放条件而异。
        // 1080p
    }
    else
    {
        // if ([type containsString:@"onPlayerError"])
        [self mediaPlayer_error];
    }
}


#pragma mark - WKNavigationDelegate protocol

- (void)webView:(WKWebView *)webView
didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog (@"didStartProvisionalNavigation");
    NSLog (@"webView URL:%@", webView.URL);
    NSLog (@"navigation:%@", navigation);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog (@"didFinishNavigation");
    NSLog (@"webView URL:%@", webView.URL);
    NSLog (@"navigation:%@", navigation);
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
                   withError:(NSError *)error
{
    NSLog (@"didFinishNavigation");
    NSLog (@"webView URL:%@", webView.URL);
    NSLog (@"error:%@", error);
}


@end
