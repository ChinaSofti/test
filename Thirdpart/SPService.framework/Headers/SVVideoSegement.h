//
//  TSVideoFragment.h
//  TaskService
//
//  Created by Rain on 1/29/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVVideoSegement : NSObject

// 分片序号ID
@property int segementID;

// 真实视频地址（URL）
@property NSString *videoSegementURL;

// 视频大小（单位字节 byte）
@property int size;

// 视频时长 (单位秒)
@property int duration;

// 视频码率 (单位：Kbps)
@property float bitrate;

// 视频帧率 (单位：Fps)
@property float frameRate;

// 视频分辨率 1920 * 1080 即：videoWidth * videoHeight
@property NSString *videoResolution;


@end
