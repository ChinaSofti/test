//
//  TSVideoContext.h
//  TaskService
//
//  Created by Rain on 1/28/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVTestContext.h"

/**
 * 视频Context
 *
 - returns: 视频Context
 */
@interface SVVideoTestContext : SVTestContext

@property NSArray *urlArray;

@property NSString *videoURLString;

// 视频分片URL字符串
@property NSString *videoSegementURLString;
// 视频分片URL
@property NSURL *videoSegementURL;
// 视频分片大小
@property int videoSegementSize;
// 视频分片时长
@property int videoSegementDuration;
// 视频分片码率 (单位：Kbps)
@property float videoSegementBitrate;
// 视频分片IP
@property NSString *videoSegementIP;
// 视频分片位置
@property NSString *videoSegemnetLocation;
// 视频分片所属运营商
@property NSString *videoSegemnetISP;

// 视频播放时长
@property int videoPlayDuration;


/**
 *  设置URLs字符串
 *
 *  @param videoURLsString URLs字符串
 */
- (void)setVideoURLsString:(NSString *)videoURLsString;

@end
