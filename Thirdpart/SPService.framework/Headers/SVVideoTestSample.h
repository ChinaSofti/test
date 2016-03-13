//
//  SVVideoTestSample.h
//  SPUIView
//
//  Created by Rain on 2/6/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVVideoTestSample : NSObject

// sQuality会话得分：截止到当前的会话期间，视频质量得分，包含之前的所有采样周期
@property float sQualitySession;
// sInteraction会话得分：截止到当前的会话期间，交互体验得分，包含之前的所有采样周期
@property float sInteractionSession;
// sView会话得分：截止到当前的会话期间，观看体验得分，包含之前的所有采样周期
@property float sViewSession;
// U-vMOS会话得分：截止到当前的会话期间，U-vMOS综合得分，包含之前的所有采样周期
@property float UvMOSSession;

// 采样周期时长，单位秒(s)，建议按照观看时间反馈，近似可以按照内容的实际时间反馈
@property int periodLength;
// 初始缓冲时长，单位毫秒(ms)，采样周期内没有初始缓冲事件时，输入0
@property int initBufferLatency;
// 支持VBR特性时，采样周期内视频文件平均码率，单位kbps，无法获得时输入0
@property int avgVideoBitrate;
// 支持VBR特性时，采样周期内I帧平均大小，单位字节，无法获得时输入0
@property int avgKeyFrameSize;
// 采样周期内，卡顿次数
@property int stallingFrequency;
// 采样周期内，平均卡顿时长，单位毫秒(ms)
@property int stallingDuration;
// 采样周期内，卡顿总时长
@property int stallingTotalTime;

// 开始缓冲时间
@property long videoStartPlayTime;

@end
