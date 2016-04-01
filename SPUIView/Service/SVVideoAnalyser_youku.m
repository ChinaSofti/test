//
//  TSVideoAnalyser_YouKu.m
//  TaskService
//
//  Created by Rain on 1/29/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVHttpGetter.h"
#import "SVLog.h"
#import "SVTimeUtil.h"
#import "SVVideoAnalyser_youku.h"
#import "SVWebBrowser.h"
#import "SVYouKu__ysuid.h"
#import "SVYoukuSIDAndTokenAndEqGetter.h"

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
    // 请求视频播放页面，获取服务器返回Cookie中ykss的值
    SVWebBrowser *browser = [[SVWebBrowser alloc] init];
    [browser addHeader:@"Referer" value:@"http://www.youku.com"];
    [browser browser:_videoURL requestType:GET];
    NSString *ykss = [browser getReturnCookie:@"ykss"];
    if (!_ykss)
    {
        if (!ykss)
        {
            return nil;
        }
        _ykss = ykss;
    }
    SVInfo (@"ykss = %@", _ykss);

    // 请求/play/get.json?vid={vid}&ct=12 并在请求头中添加Referer, ykss, __ysuid。
    // Referer 头即为视频播放页面访问的URL
    // ykss 亦访问视频播放页面服务器返回的Cookie
    // __ysuid 需要根据算法进行计算获取
    NSString *vid = [self getParamsByReg];
    NSString *videoSourceCodeURL = [NSString stringWithFormat:_toGetSourceCode, vid];
    SVWebBrowser *browser2 = [[SVWebBrowser alloc] init];
    [browser2 addHeader:@"Referer" value:_videoURL];
    [browser2 addCookies:@"ykss" value:_ykss];
    [browser2 addCookies:@"__ysuid" value:[SVYouKu__ysuid getYsuid:1]];
    [browser2 browser:videoSourceCodeURL requestType:GET];
    NSData *jsonData = [browser2 getResponseData];
    NSError *error;
    id videoSourceCodeJson =
    [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error)
    {
        SVError (@"%@", error);
        return _videoInfo;
    }

    NSDictionary *dataOfVideoSourceCodeJson = [videoSourceCodeJson valueForKey:@"data"];

    // 检测服务器返回的JSON信息是否存在error节点，如果存在，说明服务器存在异常。当前无法查询该视频信息
    NSArray *errorInfo = [dataOfVideoSourceCodeJson valueForKey:@"error"];
    if (errorInfo)
    {
        // 视频服务器存在异常。当前无法查询该视频信息。
        SVError (@"video website return error. return json:%@", dataOfVideoSourceCodeJson);
        return _videoInfo;
    }

    NSString *oip = [[dataOfVideoSourceCodeJson valueForKey:@"security"] valueForKey:@"ip"];
    NSString *encryptString =
    [[dataOfVideoSourceCodeJson valueForKey:@"security"] valueForKey:@"encrypt_string"];


    NSString *segUrl = nil;
    NSArray *streamArray = [dataOfVideoSourceCodeJson valueForKey:@"stream"];
    for (NSDictionary *streamObj in streamArray)
    {
        //
        NSString *streamType = [streamObj valueForKey:@"stream_type"];
        // 4K 目前手机APP只测试hd3的视频源
        if ([streamType isEqualToString:@"mp4hd3"])
        {
            NSString *streamFileid = [streamObj valueForKey:@"stream_fileid"];


            SVYoukuSIDAndTokenAndEqGetter *sidAndTokenAndEqGetter =
            [[SVYoukuSIDAndTokenAndEqGetter alloc] initWithEncrpytString:encryptString
                                                            streamFileid:streamFileid];
            NSString *sid = [sidAndTokenAndEqGetter getSID];
            NSString *token = [sidAndTokenAndEqGetter getToken];
            NSString *ep = [sidAndTokenAndEqGetter getEq];

            NSArray *segsArray = [streamObj valueForKey:@"segs"];
            // 刘程雨 2016/02/18 目前只查询一个分片的视频地址
            // for (int i = 0; i < [segsArray count]; i++)
            for (int i = 0; i < 1; i++)
            {
                NSDictionary *segementJson = segsArray[0];
                NSString *segsKey = [segementJson valueForKey:@"key"];
                int millisecondVideo = [[segementJson valueForKey:@"total_milliseconds_video"] intValue];
                segUrl = [NSString stringWithFormat:_getVideoFragmentInfoURL, sid, streamFileid,
                                                    segsKey, (millisecondVideo / 1000), oip, token, ep];

                int size = [[segsArray[0] valueForKey:@"size"] intValue];


                if (!segUrl)
                {
                    return nil;
                }

                //                NSLog (@"segURL %@", segUrl);
                SVWebBrowser *browser3 = [[SVWebBrowser alloc] init];
                [browser3 addHeader:@"Referer" value:_videoURL];
                [browser3 browser:segUrl requestType:GET];
                NSData *jsonData3 = [browser3 getResponseData];
                SVDebug (@"data : %@",
                         [[NSString alloc] initWithData:jsonData3 encoding:NSUTF8StringEncoding]);

                NSError *error3;
                id videoRealURLJson =
                [NSJSONSerialization JSONObjectWithData:jsonData3 options:0 error:&error3];
                if (error)
                {
                    SVError (@"%@", error);
                    return _videoInfo;
                }

                NSString *videoRealURL = [videoRealURLJson[0] valueForKey:@"server"];

                SVVideoSegement *segement = [[SVVideoSegement alloc] init];
                [segement setSegementID:i];
                // 视频大小 单位为byte
                [segement setSize:size];
                [segement setDuration:(millisecondVideo / 1000)];
                [segement setVideoSegementURL:videoRealURL];
                [segement setBitrate:((size * 8 / 1024) / (millisecondVideo / 1000))];
                [_videoInfo addSegement:segement];
            }
        }
    }

    NSString *videoTitle = [[dataOfVideoSourceCodeJson valueForKey:@"video"] valueForKey:@"title"];
    [_videoInfo setVid:vid];
    [_videoInfo setTitle:videoTitle];
    [_videoInfo setVideoDataJson:jsonData];
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
