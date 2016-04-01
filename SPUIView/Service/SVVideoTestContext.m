//
//  TSVideoContext.m
//  TaskService
//
//  Created by Rain on 1/28/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVVideoTestContext.h"

/**
 * 视频Context
 *
 - returns: 视频Context
 */

@implementation SVVideoTestContext

@synthesize urlArray, videoURLString, videoSegementURLString, videoSegementDuration,
videoSegementSize, videoSegementIP, videoSegemnetLocation, videoSegementBitrate, videoSegementURL,
videoSegemnetISP, videoPlayDuration;

/**
 *  初始化后做一下操作。用于子类进行重写
 */
- (void)handleAfterInit
{
    // do nothing
}

/**
 *  设置URLs字符串
 *
 *  @param videoURLsString URLs字符串
 */
- (void)setVideoURLsString:(NSString *)videoURLsString
{
    urlArray = [videoURLsString componentsSeparatedByString:@"\r\n"];
    if (urlArray)
    {
        int index = arc4random () % urlArray.count;
        videoURLString = [urlArray objectAtIndex:index];
    }
}

@end
