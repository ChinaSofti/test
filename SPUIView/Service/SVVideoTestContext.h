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

@property (nonatomic, retain) NSArray *urlArray;

@property (nonatomic, retain) NSString *videoURLString;

//// 视频分片URL字符串
//@property (nonatomic, retain) NSString *videoSegementURLString;
//// 视频分片URL
//@property (nonatomic, retain) NSURL *videoSegementURL;
//// 视频分片大小
//@property int videoSegementSize;
//// 视频分片时长
//@property int videoSegementDuration;
//// 视频分片码率 (单位：Kbps)
//@property float videoSegementBitrate;
//// 视频分片IP
//@property (nonatomic, retain) NSString *videoSegementIP;
//// 视频分片位置
//@property (nonatomic, retain) NSString *videoSegemnetLocation;
//// 视频分片所属运营商
//@property (nonatomic, retain) NSString *videoSegemnetISP;

// 所有视频分片信息
@property (nonatomic, retain) NSMutableArray *videoSegementInfo;

// 视频播放时长
@property int videoPlayDuration;

// 视频清晰度
@property int videoClarity;

// 视频vid
@property (nonatomic, retain) NSString *vid;

//// 视频清晰度
//@property (nonatomic, retain) NSString *videoQuality;
//
//// 视频分辨率 1920 * 1080 即：videoWidth * videoHeight
//@property (nonatomic, retain) NSString *videoResolution;
//
//// 视频帧率 (单位：Fps)
//@property float frameRate;


/**
 *  设置URLs字符串
 *
 *  @param videoURLsString URLs字符串
 */
- (void)setVideoURLsString:(NSString *)videoURLsString;

@end
