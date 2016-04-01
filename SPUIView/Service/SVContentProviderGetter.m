//
//  SVContentProviderGetter.m
//  SPUIView
//
//  Created by Rain on 2/6/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVContentProviderGetter.h"

/**
 *  获取视频提供商
 */
@implementation SVContentProviderGetter

/**
 *  获取视频提供商
 *
 *  @param videoURLHost 域名
 *
 *  @return 视频提供商
 */
+ (UvMOSContentProvider)getContentProvider:(NSString *)videoURLHost
{
    if (!videoURLHost)
    {
        return CONTENT_PROVIDER_OTHER;
    }

    if ([videoURLHost containsString:@"youku"])
    {
        // 视频内容来自优酷
        return CONTENT_PROVIDER_YOUKU;
    }
    else if ([videoURLHost containsString:@"youtube"])
    {
        // 视频内容来自YOUTUBE
        return CONTENT_PROVIDER_YOUTUBE;
    }
    else if ([videoURLHost containsString:@"qq"])
    {
        // 视频内容来自腾讯
        return CONTENT_PROVIDER_TENCENT;
    }
    else if ([videoURLHost containsString:@"sohu"])
    {
        // 视频内容来自搜狐
        return CONTENT_PROVIDER_SOHU;
    }
    else if ([videoURLHost containsString:@"iqiy"])
    {
        // 视频内容来自爱奇艺
        return CONTENT_PROVIDER_IQIY;
    }
    else if ([videoURLHost containsString:@"youpeng"])
    {
        // 视频内容来自优朋
        return CONTENT_PROVIDER_YOUPENG;
    }
    else
    {
        // 视频内容来自其他内容提供商
        return CONTENT_PROVIDER_OTHER;
    }
}


@end
