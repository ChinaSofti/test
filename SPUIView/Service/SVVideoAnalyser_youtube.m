//
//  TSVideoAnalyser_Youtube.m
//  TaskService
//
//  Created by Rain on 1/29/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVHttpsGetter.h"
#import "SVLog.h"
#import "SVProbeInfo.h"
#import "SVVideoAnalyser_youtube.h"

// quality_label=2160p
// quality_label=1440p
// quality_label=1080p
// quality_label=720p
// quality_label=480p
// quality_label=360p
// quality_label=240p
// quality_label=144p
#define QUALITY_LABEL @"quality_label=360p"

@implementation SVVideoAnalyser_youtube


// 正则用于提取vid  https://www.youtube.com/watch?v=6v2L2UGZJAM
static NSString *_VID_REG = @"^https://www.youtube.com/watch?v=([0-9a-zA-Z_]+)$";

static NSString *_GET_VIDEO_INFO_URL = @"https://www.youtube.com/"
                                       @"get_video_info?html5=1&video_id=%@&eurl&el="
                                       @"embedded&autoplay=1&iframe=1&c=WEB&cplayer=UNIPLAYER&cbr="
                                       @"Chrome&cos=Windows&cosver=6.1";

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
    return self;
}

/**
 *  对视频URL进行分析
 */
- (SVVideoInfo *)analyse
{
    NSString *vid = [self getVid];
    if (!vid)
    {
        SVError (@"get vid fail. url:%@", _videoInfo.videoURL);
        return _videoInfo;
    }

    [_videoInfo setVid:vid];
    NSString *getVideoInfoURL = [NSString stringWithFormat:_GET_VIDEO_INFO_URL, vid];
    SVHttpsGetter *getter = [[SVHttpsGetter alloc] initWithURLNSString:getVideoInfoURL];
    NSString *content = [getter getResponseDataString];
    if (!content)
    {
        SVError (@"request youtube get_video_info fail. url:%@", getVideoInfoURL);
        return _videoInfo;
    }

    NSString *adaptive_fmts;
    NSArray *arrays = [content componentsSeparatedByString:@"&"];
    for (NSString *str in arrays)
    {
        //        NSLog (@"%@", str);
        if ([str containsString:@"adaptive_fmts"])
        {
            NSArray *adaptive_fmts_arrays = [str componentsSeparatedByString:@"="];
            if (adaptive_fmts_arrays.count > 1)
            {
                adaptive_fmts = adaptive_fmts_arrays[1];
                break;
            }
        }
    }

    if (!adaptive_fmts)
    {
        SVError (@"get_video_info doesn't contain adaptive_fmts. please check whether the url of "
                 @"get_video_info is available.  url:%@",
                 getVideoInfoURL);
        return _videoInfo;
    }

    NSString *decode_adaptive_fmts = [self decodeFromPercentEscapeString:adaptive_fmts];
    NSArray *videoSegementString = [decode_adaptive_fmts componentsSeparatedByString:@","];
    SVInfo (@"videoUrlList size = %zd", videoSegementString.count);
    if (videoSegementString.count < 1)
    {
        SVError (@"illeagle videoUrlList info content");
        return _videoInfo;
    }

    // 视频清晰度的字典
    NSArray *videoTypeArray = @[@"480P", @"720P", @"1080P"];

    // 根据用户选择的清晰度选择分片
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSString *videoClarity = probeInfo.getVideoClarity;
    NSString *videoType = @"quality_label=1080P";

    if ([videoClarity isEqualToString:@"Auto"])
    {
        // 生成随机数
        int randomIndex = arc4random () % [videoTypeArray count];

        // 获取随机的清晰度
        videoType = videoTypeArray[randomIndex];
    }
    else
    {
        videoType = [NSString stringWithFormat:@"quality_label=%@", videoClarity];
    }

    NSMutableArray *videoParamStringArrays = [[NSMutableArray alloc] init];
    for (int i = 0; i < videoSegementString.count; i++)
    {
        if ([videoSegementString[i] containsString:videoType] &&
            [videoSegementString[i] containsString:@"type=video%2Fmp4"])
        {
            [videoParamStringArrays addObject:videoSegementString[i]];
        }
    }

    NSMutableString *videoParamString;
    long count = videoParamStringArrays.count;
    if (count > 0)
    {
        int i = arc4random () % count;
        videoParamString = videoParamStringArrays[i];
    }

    if (!videoParamString)
    {
        SVError (@"get video info fail");
        return _videoInfo;
    }

    SVInfo (@"%@", videoParamString);
    NSString *videoURLString;
    NSArray *videoInfoArray = [videoParamString componentsSeparatedByString:@"&"];
    SVVideoSegement *segement = [[SVVideoSegement alloc] init];
    for (NSString *item in videoInfoArray)
    {
        SVInfo (@"%@", item);
        NSArray *arrays5 = [item componentsSeparatedByString:@"="];
        NSString *key = arrays5[0];
        NSString *value = arrays5[1];
        //        NSString *value = [self decodeFromPercentEscapeString:arrays5[1]];
        //        if (!key)
        //        {
        //            continue;
        //        }

        if ([key isEqualToString:@"url"])
        {
            videoURLString = value;
            continue;
        }


        if ([key isEqualToString:@"size"])
        {
            // 视频分辨率
            [segement setVideoResolution:value];
            continue;
        }

        if ([key isEqualToString:@"bitrate"])
        {
            // 视频码率
            [segement setBitrate:([value floatValue] / 1024)];
            continue;
        }

        if ([key isEqualToString:@"fps"])
        {
            // 视频帧率
            [segement setFrameRate:[value floatValue]];
            continue;
        }

        // clen=751660159
        if ([key isEqualToString:@"clen"])
        {
            // 视频大小
            [segement setSize:[value intValue]];
            continue;
        }

        // quality_label=720p
        if ([key isEqualToString:@"quality_label"])
        {
            // 视频大小
            [segement setVideoQuality:value];
            continue;
        }
    }

    [segement setVideoSegementURLStr:videoURLString];
    [_videoInfo addSegement:segement];
    return _videoInfo;
}

/**
 *  修改signature
 *
 *  @param signature 原始signature
 *
 *  @return 新的signature
 */
- (NSString *)modifySignarture:(NSString *)signature
{
    int array[] = { 1, 1, 2, 43, 0, 65, 1, 3, 2, 1 };
    int len = (sizeof (array) / sizeof (array[0]));
    NSMutableString *str = [[NSMutableString alloc] initWithString:signature];
    for (int i = 0; i < len; i += 2)
    {
        int k = array[i];
        int m = array[i + 1];
        switch (k)
        {
        case 0:
            // swap char
            [self swapchar:str index:m];
            break;
        case 1:
            // delete char
            [str deleteCharactersInRange:NSMakeRange (m, 1)];
            break;
        case 2:
            str = [self reverse:str];
            // reverse
            break;
        default:
            break;
        }
    }

    return str;
}

- (void)swapchar:(NSMutableString *)str index:(int)index
{
    long len = str.length;
    char c1 = [str characterAtIndex:0];
    char c2 = [str characterAtIndex:(index % len)];
    [str deleteCharactersInRange:NSMakeRange (0, 1)];
    [str insertString:[[NSString alloc] initWithFormat:@"%c", c2] atIndex:0];
    if (index < len)
    {
        [str deleteCharactersInRange:NSMakeRange (index, 1)];
        [str insertString:[[NSString alloc] initWithFormat:@"%c", c1] atIndex:index];
    }
}

- (NSMutableString *)reverse:(NSString *)str
{
    NSMutableString *reverseString = [[NSMutableString alloc] init];
    for (int i = 0; i < str.length; i++)
    {
        //倒序读取字符并且存到可变数组数组中
        unichar c = [str characterAtIndex:str.length - i - 1];
        [reverseString appendFormat:@"%c", c];
    }

    return reverseString;
}

/**
 *  从视频URL中提取signature的value
 *
 *  @param videoURLString 视频URL
 *
 *  @return signature的value
 */
- (NSString *)extractSignature:(NSString *)videoURLString
{
    NSString *_SIGNATURE_REG = @".*signature=([0-9a-zA-Z.]+)&.*";
    //    videoURLString
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_SIGNATURE_REG
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:videoURLString
                                      options:NSMatchingReportCompletion
                                        range:NSMakeRange (0, [videoURLString length])];
    if (matches && matches.count > 0)
    {
        NSTextCheckingResult *checkingResult = [matches objectAtIndex:0];
        NSRange halfRange = [checkingResult rangeAtIndex:1];
        NSString *signature = [videoURLString substringWithRange:halfRange];
        return signature;
    }
    return nil;
}


/**
 *  URL解码
 *
 *  @param input URL
 *
 *  @return 解码后的URL
 */
- (NSString *)decodeFromPercentEscapeString:(NSString *)input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"

                               withString:@""

                                  options:NSLiteralSearch

                                    range:NSMakeRange (0, [outputStr length])];
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


/**
 *  解析视频URL，获取其中“id_”和“.html”之间的值
 *
 *  @return 视频ID
 */
- (NSString *)getVid
{
    //    NSError *error = nil;
    //    NSRegularExpression *regex = [NSRegularExpression
    //    regularExpressionWithPattern:_VID_REG
    //                         options:NSRegularExpressionCaseInsensitive |
    //                         NSRegularExpressionDotMatchesLineSeparators
    //                           error:&error];
    //    NSArray *matches = [regex matchesInString:_videoURL
    //                                      options:NSMatchingWithTransparentBounds
    //                                        range:NSMakeRange (0, [_videoURL length])];
    //    if (matches && matches.count > 0)
    //    {
    //        NSTextCheckingResult *checkingResult = [matches objectAtIndex:0];
    //        NSRange halfRange = [checkingResult rangeAtIndex:1];
    //        return [_videoURL substringWithRange:halfRange];
    //    }

    NSArray *array = [_videoURL componentsSeparatedByString:@"?v="];
    if (array.count <= 1)
    {
        return nil;
    }

    return array[1];
}


@end
