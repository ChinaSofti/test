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
@property int networkType;
@property NSString *singnal;
@property BOOL isTesting;
@property NSString *wifiName;
@property NSString *isp;
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

/**
 *  设置清晰度
 *
 *  @param clarity 清晰度
 */
- (void)setVideoClarity:(NSString *)clarity;

/**
 *  获取清晰度
 *
 *  @return 清晰度
 */
- (NSString *)getVideoClarity;

/**
 *  设置当前位置信息
 *
 *  @param locationInfo 当前位置信息
 */
- (void)setLocationInfo:(NSMutableDictionary *)locationInfo;

/**
 *  获取当前位置信息
 *
 *  @return 当前位置信息
 */
- (NSMutableDictionary *)getLocationInfo;

/**
 *  设置是否上传结果
 *
 *  @param isUploadResult 是否上传结果
 */
- (void)setUploadResult:(BOOL)isUploadResult;

/**
 *  获取是否上传结果
 *
 *  @return 是否上传结果
 */
- (BOOL)isUploadResult;

/**
 *  获取UUID
 *
 *  @return UUID
 */
- (NSString *)getUUID;

/**
 *  设置本机使用过的wifi信息，只记录五条
 *  @param wifiInfos 本机使用过的wifi信息
 */
- (void)setWifiInfo:(NSMutableArray *)wifiInfo;

/**
 *  获取本机使用过的wifi信息
 *
 *  @return 本机使用过的wifi信息
 */
- (NSMutableArray *)getWifiInfo;

/**
 *  设置服务器信息(服务器用来获取配置和上传结果)
 *  @param serverInfo 服务器信息
 */
- (void)setServerInfo:(NSDictionary *)serverInfo;

/**
 *  获取服务器信息(服务器用来获取配置和上传结果)
 *
 *  @return 服务器信息
 */
- (NSDictionary *)getServerInfo;

@end
