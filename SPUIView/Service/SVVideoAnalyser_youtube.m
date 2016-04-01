//
//  TSVideoAnalyser_Youtube.m
//  TaskService
//
//  Created by Rain on 1/29/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVHttpsGetter.h"
#import "SVLog.h"
#import "SVVideoAnalyser_youtube.h"

#define VIDEO_4K @"quality_label=2160p"
//#define VIDEO_4K @"quality_label=144p"
#define VIDEO_1K @"quality_label=1080p"

@implementation SVVideoAnalyser_youtube

/**
 *  对视频URL进行分析
 */
- (SVVideoInfo *)analyse
{
    SVHttpsGetter *getter = [[SVHttpsGetter alloc] initWithURLNSString:_videoURL];

    NSString *content =
    [[NSString alloc] initWithData:[getter getResponseData] encoding:NSUTF8StringEncoding];
    NSArray *arrays = [content componentsSeparatedByString:@"adaptive_fmts"];
    if (arrays.count < 2)
    {
        SVError (@"not obtain html content of this url  %c",
                 [content containsString:@"adaptive_fmts"]);
        return _videoInfo;
    }

    NSString *paramString = arrays[1];
    NSArray *arrays2 = [paramString componentsSeparatedByString:@"\""];
    if (arrays2.count < 3)
    {
        SVError (@"illeagle url info content");
        return _videoInfo;
    }

    //    SVInfo (@"videoUrlSource = %@", arrays2[2]);
    NSArray *arrays3 = [arrays2[2] componentsSeparatedByString:@","];
    SVInfo (@"videoUrlList size = %zd", arrays3.count);
    if (arrays3.count < 1)
    {
        SVError (@"illeagle videoUrlList info content");
        return _videoInfo;
    }

    NSMutableArray *videoParamStringArrays = [[NSMutableArray alloc] init];

    for (int i = 0; i < arrays3.count; i++)
    {
        if ([arrays3[i] containsString:VIDEO_4K] || [arrays3[i] containsString:VIDEO_1K])
        {
            //            videoParamString = arrays3[i];
            [videoParamStringArrays addObject:arrays3[i]];
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

    //    SVInfo (@"%@", videoParamString);
    SVInfo (@"item:----------start--------------");
    NSArray *arrays4 = [videoParamString componentsSeparatedByString:@"\\u0026"];

    NSString *videoURLString;
    SVVideoSegement *segement = [[SVVideoSegement alloc] init];
    for (NSString *item in arrays4)
    {
        SVInfo (@"%@", item);
        NSArray *arrays5 = [item componentsSeparatedByString:@"="];
        NSString *key = arrays5[0];
        NSString *value = [self decodeFromPercentEscapeString:arrays5[1]];
        if (!key)
        {
            continue;
        }

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
    }
    SVInfo (@"item:----------end----------------%@", videoURLString);

    if (![videoURLString containsString:@"signature"])
    {
        //
        //        NSString *signature = [self extractSignature:videoURLString];
        //        if (!signature)
        //        {
        //            SVError (@"extract signature fail.");
        //            return _videoInfo;
        //        }
        //
        //        SVInfo (@"modify before signature:%@", signature);
        //        NSString *newSignature = [self modifySignarture:signature];
        //        SVInfo (@"modify after signature:%@", newSignature);
        //
        //        NSArray *arrays6 = [videoURLString componentsSeparatedByString:signature];
        //        NSString *videoURL =
        //        [[NSString alloc] initWithFormat:@"%@%@%@%@", arrays6[0], newSignature,
        //        arrays6[1],
        //                                         @"&alr=yes&ratebypass=yes&c=WEB&cver=html5"];
    }


    SVInfo (@"final url:%@", videoURLString);
    [segement setVideoSegementURL:videoURLString];
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


@end
