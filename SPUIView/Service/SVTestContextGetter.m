//
//  TSContextGetter.m
//  TaskService
//
//  Created by Rain on 1/28/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVHttpsTools.h"
#import "SVLog.h"
#import "SVProbeInfo.h"
#import "SVProbeInfo.h"
#import "SVSpeedTestServers.h"
#import "SVTestContextGetter.h"
#import "SVVideoAnalyser.h"
#import "SVVideoAnalyserFactory.h"

/**
 *  从指定服务器获取测试相关的配置信息。
 *  默认服务器地址为 https://58.60.106.188:12210/speedpro/configapi
 */

@implementation SVTestContextGetter
{
    SVVideoTestContext *videoContext;

    NSString *videoURLS;

    SVWebTestContext *webContext;

    NSString *webURLs;

    SVSpeedTestContext *bandwidthContext;

    NSString *_serverURL;

    // 是否初始化完成
    BOOL isInitSuccess;
}

static NSString *inChinaURL = @"https://tools-speedpro.huawei.com/proconfig/distribute?lang=CN";

static NSString *overseaURL = @"https://tools-speedpro.huawei.com/proconfig/distribute?lang=EN";

static SVTestContextGetter *contextGetter = nil;

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    @synchronized (self)
    {

        if (contextGetter == nil)
        {
            contextGetter = [[super allocWithZone:NULL] init];
        }
    }

    return contextGetter;
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
    return [SVTestContextGetter sharedInstance];
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
    return [SVTestContextGetter sharedInstance];
}

/**
 *  根据IP运营商信息进行初始化对象
 */
- (void)initIPAndISP
{
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    NSString *localIP = servers.clientIP;
    SVIPAndISP *ipAndISP = [SVIPAndISPGetter queryIPDetail:localIP];
    if (ipAndISP)
    {
        SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
        [probeInfo setIp:ipAndISP.query];
        NSString *countryCode = ipAndISP.countryCode;
        if (countryCode && [countryCode isEqualToString:@"CN"])
        {
            // 修改URL参数
            _serverURL = inChinaURL;
        }
        else
        {
            _serverURL = overseaURL;
        }
    }
}

/**
 *  从缺省的指定服务器请求数据
 */
- (void)requestContextDataFromServer
{
    @try
    {
        SVHttpsTools *getter = [[SVHttpsTools alloc] initWithURLNSString:_serverURL];
        self.data = [getter getResponseData];
        SVInfo (@"%@", [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]);
    }
    @catch (NSException *exception)
    {
        SVError (@"request test context information fail. exception:%@", exception);
    }
}

/**
 *  解析从服务器获取的数据，并将数据解析为对应测试的Context对象
 */
- (void)parseContextData
{
    if (!self.data)
    {
        SVError (@"request data is null");
        return;
    }

    NSError *error = nil;
    NSDictionary *dictionay =
    [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
    if (error)
    {
        SVError (@"convert NSData to json fail. Error:%@", error);
        return;
    }

    if (dictionay)
    {
        videoURLS = [dictionay valueForKey:@"ottUrls"];
        webURLs = [dictionay valueForKey:@"webUrls"];
        //        NSString *versionCode = [dictionay valueForKey:@"versionCode"];
        //        NSString *downloadUrl = [dictionay valueForKey:@"downloadUrl"];
    }

    isInitSuccess = TRUE;
}

- (BOOL)isInitSuccess
{
    return isInitSuccess;
}

/**
 *  获取视频Context对象
 *
 *  @return 视频Context对象
 */
- (SVVideoTestContext *)getVideoContext
{
    // 初始化VideoTestContext
    videoContext = [[SVVideoTestContext alloc] initWithData:self.data];
    [videoContext setVideoURLsString:videoURLS];
    if (!videoContext.videoURLString)
    {
        SVWarn (@"video url request fail from our server. use default video url.");
        return nil;
    }

    SVVideoAnalyser *analyser = [SVVideoAnalyserFactory createAnalyser:videoContext.videoURLString];
    SVVideoInfo *videoInfo = [analyser analyse];
    if (!videoInfo)
    {
        SVError (@"analyse video fail. ");
        return nil;
    }

    // 获取所有分片信息，如果为空则直接返回
    NSMutableArray *allSegement = [[NSMutableArray alloc] initWithArray:[videoInfo getAllSegement]];
    if (!allSegement || allSegement.count == 0)
    {
        SVError (@"video segement info is empty. ");
        return nil;
    }

    //    // 生成随机数
    //    int randomIndex = arc4random () % [allSegement count];

    // 解析出视频ip，归属地等信息
    //    SVVideoSegement *segement = allSegement[randomIndex];
    SVVideoSegement *segement = allSegement[0];
    NSURL *url = [NSURL URLWithString:segement.videoSegementURLStr];
    [segement setVideoSegementURL:url];
    @try
    {
        SVIPAndISP *ipAndISP = [SVIPAndISPGetter queryIPDetail:url.host];
        if (ipAndISP)
        {
            [segement setVideoIP:url.host];
            [segement setVideoLocation:ipAndISP.city];
            [segement setVideoISP:ipAndISP.isp];
        }
    }
    @catch (NSException *exception)
    {
        SVError (@"query ip[%@] location fail %@", url.host, exception);
    }

    // 初始化需要播放的分片信息
    NSMutableArray *videoSegmentInfo = [[NSMutableArray alloc] init];
    [videoSegmentInfo addObject:segement];

    //    [videoContext setVideoSegementURLString:segement.videoSegementURL];
    //    [videoContext setVideoSegementURL:url];
    //    [videoContext setVideoSegementSize:segement.size];
    //    [videoContext setVideoSegementDuration:segement.duration];
    //    [videoContext setVideoSegementBitrate:segement.bitrate];
    //    [videoContext setVideoSegementIP:url.host];
    //    [videoContext setVideoQuality:segement.videoQuality];
    //    [videoContext setVideoResolution:segement.videoResolution];
    //    [videoContext setFrameRate:segement.frameRate];

    [videoContext setVideoSegementInfo:videoSegmentInfo];
    [videoContext setVid:videoInfo.vid];


    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    int videoPlayDuration = [probeInfo getVideoPlayTime];
    [videoContext setVideoPlayDuration:videoPlayDuration];
    NSString *videoClarity = [probeInfo getVideoClarity];
    [videoContext setVideoClarity:videoClarity];
    return videoContext;
}

/**
 *  获取网页Context对象
 *
 *  @return 网页Context对象
 */
- (SVWebTestContext *)getWebContext
{
    webContext = [[SVWebTestContext alloc] initWithData:self.data];

    [webContext setUrlArray:[webURLs componentsSeparatedByString:@"\r\n"]];

    return webContext;
}

/**
 *  获取带宽Context对象
 *
 *  @return 带宽Context对象
 */
- (SVSpeedTestContext *)getBandwidthContext
{
    bandwidthContext = [[SVSpeedTestContext alloc] initWithData:self.data];
    return bandwidthContext;
}


/**
 *  视频是否是YouTube
 *
 *  @return TRUE 视频是YouTube视频
 */
- (BOOL)isYoutube
{
    if (videoURLS && [videoURLS containsString:@"youtube"])
    {
        return true;
    }

    return false;
}

@end
