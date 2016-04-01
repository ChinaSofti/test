//
//  TSVideoURLAnalyseFactory.m
//  TaskService
//
//  Created by Rain on 1/29/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVLog.h"
#import "SVVideoAnalyserFactory.h"

/**
 *  视频分片分析器工厂类
 */
@implementation SVVideoAnalyserFactory


/**
 *  根据视频URL所属网站，返回该网站对应的视频分片信息分析器
 *
 *  @param videoURL 视频URL
 *
 *  @return 视频分片信息分析器
 */
+ (SVVideoAnalyser *)createAnalyser:(NSString *)videoURL
{
    SVVideoAnalyser *analyser = nil;
    NSString *website = [self getWebsiteFromVideoURL:videoURL];
    if (!website)
    {
        return nil;
    }

    Class class = NSClassFromString ([@"SVVideoAnalyser_" stringByAppendingString:website]);
    analyser = [(SVVideoAnalyser *)[class alloc] initWithURL:videoURL];
    return analyser;
}

/**
 *  对视频URL进行解析，获取该URL对应的网址。
 *
 *  @param videoURL 视频URL
 *
 *  @return 网址
 */
+ (NSString *)getWebsiteFromVideoURL:(NSString *)videoURL
{
    NSURL *url = [NSURL URLWithString:videoURL];
    // http://v.youku.com/v_show/id_XODMxMzYyMjgw.html 的host是 v.youku.com
    NSString *host = [url host];
    NSArray *array = [host componentsSeparatedByString:@"."];

    // website 默认取 host通过“.”拆分数组后，倒数第二个值
    if (array.count >= 2)
    {
        NSString *website = [array objectAtIndex:(array.count - 2)];
        SVInfo (@"URL:%@  website:%@", videoURL, website);
        return website;
    }
    else
    {
        SVError (@"URL:%@  get website fail.", videoURL);
    }

    return nil;
}

@end
