//
//  SVYoutubeVideoPlayer.m
//  SpeedPro
//
//  Created by Rain on 3/29/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVProbeInfo.h"
#import "SVTimeUtil.h"
#import "SVVideoSegement.h"
#import "SVYoutubeVideoPlayer2.h"

@implementation SVYoutubeVideoPlayer2
{
    // 视频是否准备好，可以进行播放
    BOOL _didPrepared;

    YTPlayerView *_videoPlayer;

    // 首次缓冲开始毫秒时间戳
    int _firstBufferTime;

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

    // 上一次状态
    YTPlayerState lastState;

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
        [self addLoadingUIView:showOnView];
        _testDelegate = testDelegate;
        SVInfo (@"init player view:%@", _showOnView);

        CGSize size = _showOnView.frame.size;
        _videoPlayer = [[YTPlayerView alloc] initWithFrame:CGRectMake (0, 0, size.width, size.height)];
        _videoPlayer.bounds = CGRectMake (0, 0, size.width, size.height);
        [_videoPlayer setDelegate:self];
        [_showOnView addSubview:_videoPlayer];
    }
    return self;
}

/**
 *  添加视频缓冲加载圆圈图标
 *
 *  @param view 父UIView
 */
- (void)addLoadingUIView:(UIView *)view
{
    // 视频播放缓冲进度
    UIView *activityCarrier = [[UIView alloc]
    initWithFrame:CGRectMake ((showOnView.frame.size.width - 40) / 2,
                              (showOnView.frame.size.height - 40) / 2, FITWIDTH (40), FITWIDTH (40))];
    activityView = [[UIActivityIndicatorView alloc]
    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityCarrier addSubview:activityView];
    [showOnView addSubview:activityCarrier];
    [activityView startAnimating];
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

    [testContext setTestStatus:TEST_TESTING];

    SVInfo (@"video play time is:%d", testContext.videoPlayDuration);
    execute_total_times = testContext.videoPlayDuration * 5;

    // 初始化UvMOS组件
    [self initUvMOSCompent];

    // 获取要测试的分片信息
    segement = testContext.videoSegementInfo[0];

    if (segement.videoSegementURL)
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

            playerHtmlPath =
            [NSString stringWithFormat:@"file://%@?vid=%@&quality=%@&width=%d&height=%d",
                                       playerHtmlPath, vid, quality, 480, 320];

            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:@"default" forKey:@"vq"];
            dispatch_async (dispatch_get_main_queue (), ^{
              [_videoPlayer loadWithVideoId:@"6v2L2UGZJAM" playerVars:dic];
            });

            SVInfo (@"load player.html from resource directory. URL:%@", playerHtmlPath);
        }
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
        [UIApplication sharedApplication].idleTimerDisabled = NO;
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

- (void)mediaPlayer_bufferingStart
{
    SVInfo (@"NAL 2HBT &&&&&&&&&&&&&&&&.......&&&&&&&&&&&&&&&&& bufferingStart");
    _bufferStartTime = [SVTimeUtil currentMilliSecondStamp];
    // 显示加载图标
    if (![activityView isAnimating])
    {
        [activityView startAnimating];
    }

    if (_firstBufferTime)
    {
        // 卡顿开始
        int interval = (int)([SVTimeUtil currentMilliSecondStamp] - [testResult videoStartPlayTime]);
        [uvMOSCalculator update:STATUS_IMPAIR_START time:interval];
    }
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
    if (_firstBufferTime)
    {
        // 卡顿次数加一
        videoCuttonTimes += 1;
        videoCuttonTotalTime += bufferedTime;
        [testResult setVideoCuttonTimes:(testResult.videoCuttonTimes + 1)];
        [testResult setVideoCuttonTotalTime:(testResult.videoCuttonTotalTime + bufferedTime)];

        // 卡顿结束
        int interval = (int)([SVTimeUtil currentMilliSecondStamp] - [testResult videoStartPlayTime]);
        [uvMOSCalculator update:STATUS_IMPAIR_END time:interval];
    }

    SVInfo (@"NAL 3HBT &&&&&&&&&&&&&&&&.......&&&&&&&&&&&&&&&&&  bufferingEnd");
    [self startCalculateUvMOS_bufferedTime:bufferedTime];
}

- (void)startCalculateUvMOS_bufferedTime:(int)bufferedTime
{
    // 注意：
    // 首次缓冲时长不计入卡顿时长，且第一次缓冲不算卡顿。首次缓冲时长只是首次缓冲时长
    if (!_firstBufferTime)
    {
        NSLog (@"first calculate uvmos, registe and calcuate U-vMOS");
        //        _firstBufferTime = bufferedTime;

        long long endPlayTime = [SVTimeUtil currentMilliSecondStamp];
        _firstBufferTime = (int)(endPlayTime - startPlayTime);
        [testResult setFirstBufferTime:_firstBufferTime];

        NSString *r = segement.videoResolution;
        NSArray *array = [r componentsSeparatedByString:@"x"];
        // 视频宽度
        NSString *videoWidth = array[0];
        // 视频高度
        NSString *videoHeight = array[1];

        [testResult setVideoWidth:[videoWidth intValue]];
        [testResult setVideoHeight:[videoHeight intValue]];
        if (videoHeight && videoWidth)
        {
            [testResult setVideoResolution:[NSString stringWithFormat:@"%@", r]];
        }

        [testResult setBitrate:(segement.bitrate)];
        [testResult setFrameRate:segement.frameRate];

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


#pragma mark - YTPlayerViewDelegate protocol
/**
 * Invoked when the player view is ready to receive API calls.
 * mediaPlayer_didPrepared
 *
 * @param playerView The YTPlayerView instance that has become ready.
 */
- (void)playerViewDidBecomeReady:(nonnull YTPlayerView *)playerView
{
    SVInfo (@"playerViewDidBecomeReady");
    // 隐藏加载图标
    if ([activityView isAnimating])
    {
        [activityView stopAnimating];
    }

    startPlayTime = [SVTimeUtil currentMilliSecondStamp];
    [testResult setVideoStartPlayTime:startPlayTime];

    int firstBufferedTime = (int)([SVTimeUtil currentMilliSecondStamp] - startPlayTime);
    [testResult setFirstBufferTime:firstBufferedTime];

    SVInfo (@"------------------------------didPrepared------------------------------");
    _didPrepared = YES;
}

/**
 * Callback invoked when player state has changed, e.g. stopped or started playback.
 *
 * @param playerView The YTPlayerView instance where playback state has changed.
 * @param state YTPlayerState designating the new playback state.
 */
- (void)playerView:(nonnull YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    SVInfo (@"didChangeToState %zd", state);
    //        -1 – 未开始
    //        0 – 已结束
    //        1 – 正在播放
    //        2 – 已暂停
    //        3 – 正在缓冲
    //        5 – 已插入视频
    switch (state)
    {
    case kYTPlayerStateUnstarted:
        //
        break;
    case kYTPlayerStateEnded:
        [self mediaPlayer_playbackComplete];
        break;
    case kYTPlayerStatePlaying:
        if (!_firstBufferTime)
        {
            [self startCalculateUvMOS_bufferedTime:_firstBufferTime];
            break;
        }

        if (_bufferStartTime && _bufferStartTime != 0)
        {
            [self mediaPlayer_bufferingEnd];
        }
        break;
    case kYTPlayerStatePaused:
        //
        break;
    case kYTPlayerStateBuffering:
        // 开始缓冲
        [self mediaPlayer_bufferingStart];
        break;
    case kYTPlayerStateQueued:
        //
        break;
    case kYTPlayerStateUnknown:
        //
        break;
    default:
        break;
    }

    lastState = state;
}

/**
 * Callback invoked when playback quality has changed.
 *
 * @param playerView The YTPlayerView instance where playback quality has changed.
 * @param quality YTPlaybackQuality designating the new playback quality.
 */
- (void)playerView:(nonnull YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality
{
    SVInfo (@"didChangeToState %zd", quality);
    //        suggestedQuality 参数的值可以为small、medium、large、hd720、hd1080、highres 或
    //        default。我们建议您将参数值设置为 default，这会指示 YouTube
    //        选择最适合的播放质量，具体质量会因不同用户、视频、系统和其他播放条件而异。
    // 1080p
}

/**
 * Callback invoked when an error has occured.
 *
 * @param playerView The YTPlayerView instance where the error has occurred.
 * @param error YTPlayerError containing the error state.
 */
- (void)playerView:(nonnull YTPlayerView *)playerView receivedError:(YTPlayerError)error
{
    SVInfo (@"receivedError %zd", error);
}

/**
 * Callback invoked frequently when playBack is plaing.
 *
 * @param playerView The YTPlayerView instance where the error has occurred.
 * @param playTime float containing curretn playback time.
 */
- (void)playerView:(nonnull YTPlayerView *)playerView didPlayTime:(float)playTime
{
    SVInfo (@"didPlayTime, %.2f", playTime);
}


@end
