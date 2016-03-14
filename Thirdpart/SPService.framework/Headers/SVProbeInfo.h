//
//  SVProbeInfo.h
//  SPUIView
//
//  Created by Rain on 2/11/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVProbeInfo : NSObject

@property NSString *ip;
@property NSString *location;
@property NSString *networkType;
@property NSString *singnal;


/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance;


/**
 *  设置屏幕尺寸
 *
 *  @param screenSize 屏幕尺寸
 */
- (void)setScreenSize:(float)screenSize;

/**
 *  查询屏幕尺寸
 *
 *  @return 屏幕尺寸
 */
- (NSString *)getScreenSize;

/**
 *  带宽类型
 *
 *  @param type 带宽类型
 */
- (void)setBandwidthType:(NSString *)type;

/**
 *  获取带宽类型
 *
 *  @return 带宽类型
 */
- (NSString *)getBandwidthType;

/**
 *  设置带宽
 *
 *  @param bandwidth 带宽
 */
- (void)setBandwidth:(NSString *)bandwidth;

/**
 *  获取带宽
 *
 *  @return 带宽
 */
- (NSString *)getBandwidth;

/**
 *  语言设置的索引
 *
 *  @param languageIndex 语言设置的索引
 */
- (void)setLanguageIndex:(int)languageIndex;

/**
 *  获取语言设置的索引
 *
 *  @return 语言设置的索引
 */
- (int)getLanguageIndex;


/**
 *  设置视频播放时长, 时间单位全部转换为秒
 *  包含：20s,3min,5min,10min,30min
 *
 *  @param languageIndex 视频播放时长
 */
- (void)setVideoPlayTime:(int)videoPlayTime;

/**
 *  获取视频播放时长, 时间单位全部转换为秒
 *
 *  @return 视频播放时长
 */
- (int)getVideoPlayTime;


@end
