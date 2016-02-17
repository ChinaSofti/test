//
//  SVVideoTestResult.h
//  SPUIView
//
//  Created by Rain on 2/6/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVTestResult.h"
#import "SVVideoTestSample.h"

/**
 *  视频测试结果
 */
@interface SVVideoTestResult : SVTestResult

// 测试时间
@property long testTime;

// sQuality会话得分：截止到当前的会话期间，视频质量得分，包含之前的所有采样周期
@property float sQualitySession;
// sInteraction会话得分：截止到当前的会话期间，交互体验得分，包含之前的所有采样周期
@property float sInteractionSession;
// sView会话得分：截止到当前的会话期间，观看体验得分，包含之前的所有采样周期
@property float sViewSession;
// U-vMOS会话得分：截止到当前的会话期间，U-vMOS综合得分，包含之前的所有采样周期
@property float UvMOSSession;


// 首次缓冲时间
@property int firstBufferTime;

// 开始视频播放
@property long videoStartPlayTime;
// 结束视频播放
@property long videoEndPlayTime;
// 视频卡顿次数
@property int videoCuttonTimes;
// 视频卡顿总时长
@property int videoCuttonTotalTime;

// 下载速率
@property float downloadSpeed;

// 下载大小
@property int downloadSize;

// 视频宽度
@property int videoWidth;

// 视频高度
@property int videoHeight;

// 视频帧率
@property float frameRate;

// 视频码率
@property float bitrate;

// 屏幕尺寸
@property float screenSize;

// 视频分辨率 1920 * 1080 即：videoWidth * videoHeight
@property NSString *videoResolution;

// 测试样本结果信息
@property NSMutableArray *videoTestSamples;


@end
