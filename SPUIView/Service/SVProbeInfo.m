//
//  SVProbeInfo.m
//  SPUIView
//
//  Created by Rain on 2/11/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVCurrentDevice.h"
#import "SVLog.h"
#import "SVProbeInfo.h"
#import "SVWifiInfo.h"

#define default_screenSize 42;
#define VIDEO_PLAY_TIME_KEY @"videoPlayTime"
#define LANGUAGE_INDEX_KEY @"languageIndex"


@implementation SVProbeInfo

@synthesize singnal, ip, networkType, location, wifiName;

// 屏幕尺寸
static NSString *_screenSize;


/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    static SVProbeInfo *probeInfo;
    @synchronized (self)
    {
        if (probeInfo == nil)
        {
            probeInfo = [[super allocWithZone:NULL] init];

            // 初始化基本信息
            probeInfo.networkType = 1;
            probeInfo.location = @"";
            probeInfo.ip = @"";

            // 初始化屏幕大小
            if (![probeInfo getScreenSize])
            {
                [probeInfo setScreenSize:42.00];
            }

            // 初始化带宽类型
            if (![probeInfo getBandwidthType])
            {
                [probeInfo setBandwidthType:@"0"];
            }

            // 初始化视频清晰度
            if (![probeInfo getVideoClarity])
            {
                [probeInfo setVideoClarity:@"1080P"];
            }

            // 初始化wifi数组，用于记录使用过的wifi信息
            if (![probeInfo getWifiInfo])
            {
                NSMutableArray *wifiInfo = [[NSMutableArray alloc] init];
                [probeInfo setWifiInfo:wifiInfo];
            }

            // 初始化带宽
            if (![probeInfo getBandwidth])
            {
                [probeInfo setBandwidth:@""];
            }

            // 初始化UUID
            if (![probeInfo getUUID])
            {
                NSString *uuid = [probeInfo gen_uuid];
                [probeInfo setUUID:uuid];
            }
        }
    }

    return probeInfo;
}

/**
 *  覆写allocWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [SVProbeInfo sharedInstance];
}

/**
 *  覆写copyWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [SVProbeInfo sharedInstance];
}

/**
 *  设置是否是第一次启动
 *
 *  @param firstStart 是否是第一次启动
 */
- (void)setFirstStart:(BOOL)firstStart
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:firstStart forKey:@"isFirstStart"];
    [defaults synchronize];
}

/**
 *  是否是第一次启动
 *
 *  @return 是否是第一次启动
 */
- (BOOL)isFirstStart
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"isFirstStart"];
}


/**
 *  设置屏幕尺寸
 *
 *  @param screenSize 屏幕尺寸
 */
- (void)setScreenSize:(float)screenSize
{
    SVInfo (@"Advanced Setting[screenSize=%.1f]", screenSize);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _screenSize = [NSString stringWithFormat:@"%.1f", screenSize];
    [defaults setObject:_screenSize forKey:@"screenSize"];
    [defaults synchronize];
}

/**
 *  查询屏幕尺寸
 *
 *  @return 屏幕尺寸
 */
- (NSString *)getScreenSize
{
    return _screenSize;
}

/**
 *  带宽类型
 *
 *  @param type 带宽类型
 */
- (void)setBandwidthType:(NSString *)type
{
    SVInfo (@"Advanced Setting[bandwidth type=%@]", type);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:type forKey:@"bandwidthType"];
    [defaults synchronize];
}

/**
 *  获取带宽类型
 *
 *  @return 带宽类型
 */
- (NSString *)getBandwidthType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:@"bandwidthType"];
}

/**
 *  设置带宽
 *
 *  @param bandwidth 带宽
 */
- (void)setBandwidth:(NSString *)bandwidth
{
    SVInfo (@"Advanced Setting[bandwidth=%@]", bandwidth);

    // 如果带宽是0，则当没有设置处理
    if (!bandwidth || [bandwidth isEqualToString:@"0"])
    {
        bandwidth = @"";
    }

    // 更新wifi信息
    NSMutableArray *wifiInfoArray = [self getWifiInfo];

    // 获取当前wifi的名称
    NSString *currWifiName = [SVCurrentDevice getWifiName];

    // 修改对应wifi的带宽
    for (SVWifiInfo *wifiInfo in wifiInfoArray)
    {
        // 如果名称已经记录过，且带宽也设置过，则不是新的wifi
        if ([wifiInfo.wifiName isEqualToString:currWifiName])
        {
            wifiInfo.bandWidth = bandwidth;
        }
    }
    [self setWifiInfo:wifiInfoArray];
}

/**
 *  获取带宽
 *
 *  @return 带宽
 */
- (NSString *)getBandwidth
{
    // 更新wifi信息
    NSMutableArray *wifiInfoArray = [self getWifiInfo];

    // 获取当前wifi的名称
    NSString *currWifiName = [SVCurrentDevice getWifiName];

    // 修改对应wifi的带宽
    for (SVWifiInfo *wifiInfo in wifiInfoArray)
    {
        // 如果名称已经记录过，且带宽也设置过，则不是新的wifi
        if ([wifiInfo.wifiName isEqualToString:currWifiName])
        {
            return wifiInfo.bandWidth;
        }
    }

    return nil;
}


/**
 *  语言设置的索引
 *
 *  @param languageIndex 语言设置的索引
 */
- (void)setLanguageIndex:(int)languageIndex
{
    SVInfo (@"Advanced Setting[languageIndex=%d]", languageIndex);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d", languageIndex] forKey:LANGUAGE_INDEX_KEY];
    [defaults synchronize];
}

/**
 *  获取语言设置的索引
 *
 *  @return 语言设置的索引
 */
- (int)getLanguageIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *languageIndex = [defaults valueForKey:LANGUAGE_INDEX_KEY];
    if (languageIndex)
    {
        return [languageIndex intValue];
    }
    else
    {
        return 0;
    }
}

/**
 *  设置视频播放时长, 时间单位全部转换为秒
 *  包含：20s,3min,5min,10min,30min
 *
 *  @param languageIndex 视频播放时长
 */
- (void)setVideoPlayTime:(int)videoPlayTime
{
    SVInfo (@"Advanced Setting[videoPlayTime=%d]", videoPlayTime);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d", videoPlayTime]
                 forKey:VIDEO_PLAY_TIME_KEY];
    [defaults synchronize];
}

/**
 *  获取视频播放时长, 时间单位全部转换为秒
 *
 *  @return 视频播放时长
 */
- (int)getVideoPlayTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *videoPlayTime = [defaults valueForKey:VIDEO_PLAY_TIME_KEY];

    // 如果缓存中没有，则初始化
    if (!videoPlayTime)
    {
        [self setVideoPlayTime:60];
        return 60;
    }
    return [videoPlayTime intValue];
}

/**
 *  设置清晰度
 *
 *  @param clarity 清晰度
 */
- (void)setVideoClarity:(NSString *)clarity
{
    SVInfo (@"Advanced Setting[clarity=%@]", clarity);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:clarity forKey:@"videoClarity"];
    [defaults synchronize];
}

/**
 *  获取清晰度
 *
 *  @return 清晰度
 */
- (NSString *)getVideoClarity
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *videoClarity = [defaults valueForKey:@"videoClarity"];
    return videoClarity;
}

/**
 *  设置是否上传结果
 *
 *  @param isUploadResult 是否上传结果
 */
- (void)setUploadResult:(BOOL)isUploadResult
{
    SVInfo (@"Advanced Setting[isUploadResult=%d]", isUploadResult);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d", isUploadResult] forKey:@"isUploadResult"];
    [defaults synchronize];
}

/**
 *  获取是否上传结果
 *
 *  @return 是否上传结果
 */
- (BOOL)isUploadResult
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *isUploadResult = [defaults valueForKey:@"isUploadResult"];

    // 如果没有缓存则初始化
    if (!isUploadResult)
    {
        [self setUploadResult:YES];
        return YES;
    }
    return [isUploadResult boolValue];
}

/**
 *  设置UUID
 *  @param uuid 唯一标示
 */
- (void)setUUID:(NSString *)uuid
{
    SVInfo (@"Advanced Setting[UUID=%@]", uuid);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:uuid forKey:@"speedProUUID"];
    [defaults synchronize];
}

/**
 *  获取UUID
 *
 *  @return UUID
 */
- (NSString *)getUUID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [defaults valueForKey:@"speedProUUID"];
    return uuid;
}

/**
 *  设置当前位置信息
 *
 *  @param locationInfo 当前位置信息
 */
- (void)setLocationInfo:(NSMutableDictionary *)locationInfo
{
    SVInfo (@"Current location info = %@", locationInfo);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:locationInfo forKey:@"CurrentLocationInfo"];
    [defaults synchronize];
}

/**
 *  获取当前位置信息
 *
 *  @return 当前位置信息
 */
- (NSMutableDictionary *)getLocationInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *locationInfo = [defaults valueForKey:@"CurrentLocationInfo"];
    return locationInfo;
}

/**
 *  设置本机使用过的wifi信息，只记录五条
 *  @param wifiInfos 本机使用过的wifi信息
 */
- (void)setWifiInfo:(NSMutableArray *)wifiInfo
{
    SVInfo (@"Current wifiInfo = %@]", wifiInfo);

    // 判断数组长度，如果大于五则将第一个数据移除掉
    if ([wifiInfo count] > 5)
    {
        [wifiInfo removeObjectAtIndex:0];
    }

    // 序列化数组
    NSData *wifiData = [NSKeyedArchiver archivedDataWithRootObject:wifiInfo];

    // 放到UserDefaults中
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:wifiData forKey:@"SVWifiInfo"];
    [defaults synchronize];
}

/**
 *  获取本机使用过的wifi信息
 *
 *  @return 本机使用过的wifi信息
 */
- (NSMutableArray *)getWifiInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *wifiData = [defaults objectForKey:@"SVWifiInfo"];
    if (!wifiData)
    {
        return nil;
    }

    // 反序列化数组
    return [[NSKeyedUnarchiver unarchiveObjectWithData:wifiData] mutableCopy];
}

/**
 *  设置服务器信息(服务器用来获取配置和上传结果)
 *  @param serverInfo 服务器信息
 */
- (void)setServerInfo:(NSDictionary *)serverInfo
{
    SVInfo (@"Current ServerInfo = %@]", serverInfo);

    // 放到UserDefaults中
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serverInfo forKey:@"SVServerInfo"];
    [defaults synchronize];
}

/**
 *  获取服务器信息(服务器用来获取配置和上传结果)
 *
 *  @return 服务器信息
 */
- (NSDictionary *)getServerInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *serverInfo = [defaults dictionaryForKey:@"SVServerInfo"];
    if (!serverInfo)
    {
        return nil;
    }

    return serverInfo;
}

// 生成UUID
- (NSString *)gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate (NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString (NULL, uuid_ref);
    CFRelease (uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease (uuid_string_ref);
    return uuid;
}


@end
