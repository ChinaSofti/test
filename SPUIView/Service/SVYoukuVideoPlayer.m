//
//  SVYoukuVideoPlayer.m
//  SpeedPro
//
//  Created by Rain on 3/29/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVLog.h"
#import "SVProbeInfo.h"
#import "SVRealReachability.h"
#import "SVTimeUtil.h"
#import "SVVideoSegement.h"
#import "SVVideoUtil.h"
#import "SVYoukuVideoPlayer.h"

@implementation SVYoukuVideoPlayer
{
    // 视频是否准备好，可以进行播放
    BOOL _didPrepared;

    // 第三方视频播放对象
    VMediaPlayer *_VMpalyer;

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

    int maxDownloadSize;
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
    showOnView = _showOnView;
    [self addLoadingUIView:showOnView];
    _testDelegate = testDelegate;
    SVInfo (@"init player view:%@", _showOnView);
    if (!_VMpalyer)
    {
        _VMpalyer = [VMediaPlayer sharedInstance];
        //        [_VMpalyer setVideoFillMode:VMVideoFillModeFit];
        _isSetup = [_VMpalyer setupPlayerWithCarrierView:showOnView withDelegate:self];
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
    initWithFrame:CGRectMake ((showOnView.bounds.size.width - 40) / 2,
                              (showOnView.bounds.size.height - 40) / 2, FITWIDTH (40), FITWIDTH (40))];
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

    startPlayTime = [SVTimeUtil currentMilliSecondStamp];
    [testResult setVideoStartPlayTime:startPlayTime];
    [testContext setTestStatus:TEST_TESTING];

    SVInfo (@"video play time is:%d", testContext.videoPlayDuration);
    execute_total_times = testContext.videoPlayDuration * 5;

    // 初始化UvMOS组件
    [self initUvMOSCompent];

    // 获取要测试的分片信息
    segement = testContext.videoSegementInfo[0];

    if (segement.videoSegementURL)
    {
        BOOL isPlaying = [_VMpalyer isPlaying];
        if (isPlaying)
        {
            // 如果视频正在播放，不做任何处理
            SVInfo (@"have been playing");
            return;
        }
        else
        {
            if (_didPrepared)
            {
                // 开始播放视频
                SVInfo (@"start play");
                [_VMpalyer start];
            }
            else
            {
                SVInfo (@"paly prepareVideo");
                [self prepareVideo];
            }
        }
    }
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
            // 视频正在播放，则停止视频
            if (_VMpalyer)
            {
                BOOL isPlaying = [_VMpalyer isPlaying];
                if (isPlaying)
                {
                    SVInfo (@"vmplayer pause");
                    [_VMpalyer pause];
                }

                [_VMpalyer reset];
                SVInfo (@"vmplayer reset");
                [_VMpalyer unSetupPlayer];
            }
        }
        @catch (NSException *exception)
        {
            SVError (@"stop video fail. exception:%@", exception);
        }

        // 取消 UvMOS 注册服务
        [uvMOSCalculator unRegisteService];
        if (testContext.testStatus == TEST_TESTING)
        {
            testContext.testStatus = TEST_FINISHED;
        }

        isFinished = TRUE;
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
        [_VMpalyer setBufferSize:segement.bitrate * 2 * 1024];
        [_VMpalyer setDataSource:segement.videoSegementURL];
        [_VMpalyer prepareAsync];
    }
}

/**
 * Called when the player prepared.
 * 当'播放器准备完成'时, 该协议方法被调用, 我们可以在此调用 [player start]来开始音视频的播放.
 *
 * @param player The shared media player instance.
 * @param arg Not use.
 */
- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    // 隐藏加载图标
    if ([activityView isAnimating])
    {
        [activityView stopAnimating];
    }

    int firstBufferedTime = (int)([SVTimeUtil currentMilliSecondStamp] - startPlayTime);
    [testResult setFirstBufferTime:firstBufferedTime];

    // 初始化卡顿状态，默认为不卡顿
    testResult.isCutton = NO;

    SVInfo (@"------------------------------didPrepared------------------------------");
    _didPrepared = YES;
    [player setVideoFillMode:VMVideoFillModeFit];
    [player start];

    // 视频宽度
    int videoWidth = [player getVideoWidth];
    // 视频高度
    int videoHeight = [player getVideoHeight];
    // 视频帧率
    NSDictionary *metaData = [player getMetadata];
    float frame_rate = [[metaData valueForKey:@"video_frame_rate"] floatValue];

    [testResult setVideoWidth:videoWidth];
    [testResult setVideoHeight:videoHeight];
    if (videoHeight && videoWidth)
    {
        [testResult setVideoResolution:[NSString stringWithFormat:@"%d*%d", videoWidth, videoHeight]];
    }

    [testResult setBitrate:(segement.bitrate)];
    [testResult setFrameRate:frame_rate];

    SVVideoTestSample *sample = [[SVVideoTestSample alloc] init];
    [sample setPeriodLength:0];
    [sample setInitBufferLatency:testResult.firstBufferTime];
    [sample setAvgVideoBitrate:testResult.bitrate];
    [sample setAvgKeyFrameSize:testResult.frameRate];
    [sample setStallingFrequency:20];
    [sample setStallingDuration:0];
    [sample setVideoStartPlayTime:[testResult videoStartPlayTime]];
    [sample setVideoTotalCuttonTime:0];
    [uvMOSCalculator calculateUvMOS:sample time:testResult.firstBufferTime];
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
- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
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
- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
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
- (void)mediaPlayer:(VMediaPlayer *)player downloadRate:(id)arg
{
    SVInfo (@"------------------------------downloadRate: %d", [arg intValue]);
    _downloadSize += [arg intValue];
    _downloadTime += 1;

    if (!maxDownloadSize)
    {
        maxDownloadSize = [arg intValue];
    }

    if ([arg intValue] >= maxDownloadSize)
    {
        [testResult setDownloadSpeed:(maxDownloadSize * 8)];
        maxDownloadSize = [arg intValue];
    }
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg
{
    SVInfo (@"NAL 2HBT &&&&&&&&&&&&&&&&.......&&&&&&&&&&&&&&&&& bufferingStart");
    _bufferStartTime = [SVTimeUtil currentMilliSecondStamp];
    [player pause];
    // 显示加载图标
    if (![activityView isAnimating])
    {
        [activityView startAnimating];
    }

    // 卡顿开始
    int interval = (int)([SVTimeUtil currentMilliSecondStamp] - [testResult videoStartPlayTime]);
    [uvMOSCalculator update:STATUS_IMPAIR_START time:interval];

    // 开始缓存时，重置状态
    testResult.isCutton = YES;
}

/**
 *  缓冲结束开始播放视频
 *
 *  @param player 播放器
 *  @param arg    arg
 */
- (void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg
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
    [player start];

    // 卡顿结束，重置状态
    testResult.isCutton = NO;
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
            [testResult setDownloadSize:_downloadSize];
            [testResult setVideoEndPlayTime:[SVTimeUtil currentMilliSecondStamp]];

            // 计算视频实际播放时长
            long long videoStartPlayTime = !testResult.videoStartPlayTime ? 0 : testResult.videoStartPlayTime;
            long long videoEndPlayTime = !testResult.videoEndPlayTime ? 0 : testResult.videoEndPlayTime;
            int firstBufferTime = testResult.firstBufferTime;
            int cuttonTotalTime = testResult.videoCuttonTotalTime;
            int videoPlayTime =
            ((int)(videoEndPlayTime - videoStartPlayTime) - firstBufferTime - cuttonTotalTime) / 1000;
            [testResult setVideoPlayTime:videoPlayTime];

            SVVideoTestSample *sample = [uvMOSCalculator calculateUvMOSNetworkPlan];
            [testResult setSViewSession:sample.sViewSession];
            [testResult setSInteractionSession:sample.sInteractionSession];
            [testResult setSQualitySession:sample.sQualitySession];
            [testResult setUvMOSSession:sample.UvMOSSession];
            [testResult setSQualityInstant:sample.sQualityInstant];
            [testResult setSInteractionInstant:sample.sInteractionInstant];
            [testResult setSViewInstant:sample.sViewInstant];
            [testResult setUvmosInstant:sample.uvmosInstant];
            [self stop];
        }

        [_testDelegate updateTestResultDelegate:testContext testResult:testResult];
    }
    @catch (NSException *exception)
    {
        SVError (@"%@", exception);
    }
}


@end
