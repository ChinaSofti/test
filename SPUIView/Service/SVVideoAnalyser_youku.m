//
//  TSVideoAnalyser_YouKu.m
//  TaskService
//
//  Created by Rain on 1/29/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "DLVideoParser.h"
#import "SVHttpGetter.h"
#import "SVLog.h"
#import "SVProbeInfo.h"
#import "SVTimeUtil.h"
#import "SVVideoAnalyser_youku.h"
#import "SVWebBrowser.h"

// 获取密文 ip等信息
#define ToGetSourceCodeURL "http://play.youku.com/play/get.json?vid=%@&ct=12"
// 获取视频分片信息
#define GetVideoFragmentInfoURL                                                                  \
    "http://k.youku.com/player/getFlvPath/sid/%@_00/st/flv/fileid/"                              \
    "%@?K=%@&ctype=12&ev=1&ts=%d&oip=%@&token=%@&ep=%@&yxon=1&special=true&hd=0&myp=0&ymovie=1&" \
    "ypp=2"

@implementation SVVideoAnalyser_youku
{
    // 获取密文 ip等信息
    NSString *_toGetSourceCode;
    // 获取视频分片信息
    NSString *_getVideoFragmentInfoURL;
}

// 正则用于提取vid
static NSString *_VID_REG = @"^http://v.youku.com/v_show/id_([0-9a-zA-Z=]+)([_a-z0-9]+)?\\.html";

static NSString *_ykss;

/**
 *  根据视频URL初始化视频信息分析器
 *
 *  @param videoURL 视频URL
 *
 *  @return 视频分片分析器
 */
- (id)initWithURL:(NSString *)videoURL
{
    self = [super initWithURL:videoURL];
    if (self)
    {
        _toGetSourceCode = @ToGetSourceCodeURL;
        _getVideoFragmentInfoURL = @GetVideoFragmentInfoURL;
    }

    return self;
}


/**
 *  根据视频URL查询和分析视频信息
 *  视频URL（_videoURL）的格式例如：http://v.youku.com/v_show/id_XODMxMzYyMjgw.html
 */
- (SVVideoInfo *)analyse
{
    // 输入合法的正版序列号（每个客户有一个对应的序列号，否则会只能使用几天测试）
    VideoResult *vResult = NULL;
    int initRet = DLVideoParser_Init ("6sLU05E2pfCaeSpfZmLW0B4l", "eDFN6IJjvehXURanpniOeZZR");
    if (initRet != 0)
    {
        // please input corrent keyValue
        SVError (@"Invalid key!");
        return _videoInfo;
    }

    // 进行真正的解析
    //    _videoURL = @"http://v.youku.com/v_show/id_XMjcwNjYwNTIw.html";
    const char *videoUrlChar = [_videoURL UTF8String];
    long ret = DLVideo_Parse (videoUrlChar, &vResult, NULL, NULL);
    if (ret != 0 || vResult == NULL)
    {
        SVError (@"Vieo result is null!");
        return _videoInfo;
    }
    if (vResult->vName != NULL)
    {
        [_videoInfo setTitle:[NSString stringWithUTF8String:vResult->vName]];
    }

    // 视频清晰度的字典
    NSDictionary *videoTypeDic =
    @{ @"480P": @"MP4-HD",
       @"720P": @"FLV-SuperHD",
       @"1080P": @"FLV-1080P" };

    // 根据用户选择的清晰度选择分片
    NSString *videoType = @"FLV-1080P";
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSString *videoClarity = probeInfo.getVideoClarity;
    if ([videoClarity isEqualToString:@"Auto"])
    {
        // 生成随机数
        int randomIndex = arc4random () % [videoTypeDic count];

        // 获取随机的清晰度
        videoType = videoTypeDic.allValues[randomIndex];
    }
    else
    {
        videoType = [videoTypeDic valueForKey:videoClarity];
    }

    //    videoType = @"3GP-HD";
    for (int i = 0; vResult->streams != NULL && i < (int)vResult->streamCount; i++)
    {
        // 如果视频类型和用户选择的不一致则继续
        if (![videoType isEqualToString:[NSString stringWithUTF8String:vResult->streams[i].strType]])
        {
            continue;
        }

        // 解析分片
        for (int j = 0; vResult->streams[i].segs != NULL && j < (int)vResult->streams[i].segCount; j++)
        {
            int fileSize = [[NSNumber alloc] initWithLong:vResult->streams[i].segs[j].fileSize].intValue;
            int duration = vResult->streams[i].segs[j].seconds;
            NSString *segUrl = (vResult->streams[i].segs[j].url != NULL ?
                                [NSString stringWithUTF8String:vResult->streams[i].segs[j].url] :
                                @"");

            SVVideoSegement *segement = [[SVVideoSegement alloc] init];
            [segement setSegementID:i];

            // 视频大小 单位为byte
            [segement setSize:fileSize];
            [segement setDuration:duration];
            [segement setVideoSegementURLStr:segUrl];
            [segement setBitrate:((fileSize * 8 / 1024) / duration)];
            [_videoInfo addSegement:segement];
        }
    }

    //    // 视频清晰度的字典
    //    NSDictionary *videoTypeDic = @{ @"480P": @"mp4hd", @"720P": @"mp4hd2", @"1080P": @"mp4hd3"
    //    };
    //
    //    // 请求视频播放页面，获取服务器返回Cookie中ykss的值
    //    SVWebBrowser *browser = [[SVWebBrowser alloc] init];
    //    [browser addHeader:@"Referer" value:@"http://www.youku.com"];
    //    [browser browser:_videoURL requestType:GET];
    //    NSString *ykss = [browser getReturnCookie:@"ykss"];
    //    if (!_ykss)
    //    {
    //        if (!ykss)
    //        {
    //            return nil;
    //        }
    //        _ykss = ykss;
    //    }
    //    SVInfo (@"ykss = %@", _ykss);
    //
    //    // 请求/play/get.json?vid={vid}&ct=12 并在请求头中添加Referer, ykss, __ysuid。
    //    // Referer 头即为视频播放页面访问的URL
    //    // ykss 亦访问视频播放页面服务器返回的Cookie
    //    // __ysuid 需要根据算法进行计算获取
    //    NSString *vid = [self getParamsByReg];
    //    NSString *videoSourceCodeURL = [NSString stringWithFormat:_toGetSourceCode, vid];
    //    SVWebBrowser *browser2 = [[SVWebBrowser alloc] init];
    //    [browser2 addHeader:@"Referer" value:_videoURL];
    //    [browser2 addCookies:@"ykss" value:_ykss];
    //    [browser2 addCookies:@"__ysuid" value:[SVYouKu__ysuid getYsuid:1]];
    //    [browser2 browser:videoSourceCodeURL requestType:GET];
    //    NSData *jsonData = [browser2 getResponseData];
    //    NSError *error;
    //    id videoSourceCodeJson =
    //    [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    //    if (error)
    //    {
    //        SVError (@"%@", error);
    //        return _videoInfo;
    //    }
    //
    //    NSDictionary *dataOfVideoSourceCodeJson = [videoSourceCodeJson valueForKey:@"data"];
    //
    //    //检测服务器返回的JSON信息是否存在error节点，如果存在，说明服务器存在异常。当前无法查询该视频信息
    //    NSArray *errorInfo = [dataOfVideoSourceCodeJson valueForKey:@"error"];
    //    if (errorInfo)
    //    {
    //        // 视频服务器存在异常。当前无法查询该视频信息。
    //        SVError (@"video website return error. return json:%@", dataOfVideoSourceCodeJson);
    //        return _videoInfo;
    //    }
    //
    //    NSString *oip = [[dataOfVideoSourceCodeJson valueForKey:@"security"] valueForKey:@"ip"];
    //    NSString *encryptString =
    //    [[dataOfVideoSourceCodeJson valueForKey:@"security"] valueForKey:@"encrypt_string"];
    //
    //    // 根据用户选择的清晰度选择分片
    //    NSString *videoType = @"mp4hd3";
    //    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    //    NSString *videoClarity = probeInfo.getVideoClarity;
    //    if ([videoClarity isEqualToString:@"Auto"])
    //    {
    //        // 生成随机数
    //        int randomIndex = arc4random () % [videoTypeDic count];
    //
    //        // 获取随机的清晰度
    //        videoType = videoTypeDic.allValues[randomIndex];
    //    }
    //    else
    //    {
    //        videoType = [videoTypeDic valueForKey:videoClarity];
    //    }
    //
    //    NSString *segUrl = nil;
    //    NSArray *streamArray = [dataOfVideoSourceCodeJson valueForKey:@"stream"];
    //    for (NSDictionary *streamObj in streamArray)
    //    {
    //        NSString *streamType = [streamObj valueForKey:@"stream_type"];
    //
    //        // 4K 目前手机APP只测试hd3的视频源
    //        if ([streamType isEqualToString:videoType])
    //        {
    //            NSString *streamFileid = [streamObj valueForKey:@"stream_fileid"];
    //
    //
    //            SVYoukuSIDAndTokenAndEqGetter *sidAndTokenAndEqGetter =
    //            [[SVYoukuSIDAndTokenAndEqGetter alloc] initWithEncrpytString:encryptString
    //                                                            streamFileid:streamFileid];
    //            NSString *sid = [sidAndTokenAndEqGetter getSID];
    //            NSString *token = [sidAndTokenAndEqGetter getToken];
    //            NSString *ep = [sidAndTokenAndEqGetter getEq];
    //
    //            NSArray *segsArray = [streamObj valueForKey:@"segs"];
    //            // 刘程雨 2016/02/18 目前只查询一个分片的视频地址
    //            // for (int i = 0; i < [segsArray count]; i++)
    //            for (int i = 0; i < 1; i++)
    //            {
    //                NSDictionary *segementJson = segsArray[0];
    //                NSString *segsKey = [segementJson valueForKey:@"key"];
    //                int millisecondVideo = [[segementJson valueForKey:@"total_milliseconds_video"]
    //                intValue];
    //                segUrl = [NSString stringWithFormat:_getVideoFragmentInfoURL, sid,
    //                streamFileid,
    //                                                    segsKey, (millisecondVideo / 1000), oip,
    //                                                    token, ep];
    //
    //                int size = [[segsArray[0] valueForKey:@"size"] intValue];
    //
    //
    //                if (!segUrl)
    //                {
    //                    return nil;
    //                }
    //
    //                //                NSLog (@"segURL %@", segUrl);
    //                SVWebBrowser *browser3 = [[SVWebBrowser alloc] init];
    //                [browser3 addHeader:@"Referer" value:_videoURL];
    //                [browser3 browser:segUrl requestType:GET];
    //                NSData *jsonData3 = [browser3 getResponseData];
    //                SVDebug (@"data : %@",
    //                         [[NSString alloc] initWithData:jsonData3
    //                         encoding:NSUTF8StringEncoding]);
    //
    //                NSError *error3;
    //                id videoRealURLJson =
    //                [NSJSONSerialization JSONObjectWithData:jsonData3 options:0 error:&error3];
    //                if (error)
    //                {
    //                    SVError (@"%@", error);
    //                    return _videoInfo;
    //                }
    //
    //                NSString *videoRealURL = [videoRealURLJson[0] valueForKey:@"server"];
    //
    //                SVVideoSegement *segement = [[SVVideoSegement alloc] init];
    //                [segement setSegementID:i];
    //                // 视频大小 单位为byte
    //                [segement setSize:size];
    //                [segement setDuration:(millisecondVideo / 1000)];
    //                [segement setVideoSegementURLStr:videoRealURL];
    //                [segement setBitrate:((size * 8 / 1024) / (millisecondVideo / 1000))];
    //                [_videoInfo addSegement:segement];
    //            }
    //        }
    //    }
    //
    //    NSString *videoTitle = [[dataOfVideoSourceCodeJson valueForKey:@"video"]
    //    valueForKey:@"title"];
    //    [_videoInfo setVid:vid];
    //    [_videoInfo setTitle:videoTitle];
    //    [_videoInfo setVideoDataJson:jsonData];
    return _videoInfo;
}


/**
 *  解析视频URL，获取其中“id_”和“.html”之间的值
 *
 *  @return 视频ID
 */
- (NSString *)getParamsByReg
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_VID_REG
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:_videoURL
                                      options:NSMatchingReportCompletion
                                        range:NSMakeRange (0, [_videoURL length])];
    if (matches && matches.count > 0)
    {
        NSTextCheckingResult *checkingResult = [matches objectAtIndex:0];
        NSRange halfRange = [checkingResult rangeAtIndex:1];
        return [_videoURL substringWithRange:halfRange];
    }

    return nil;
}

@end
