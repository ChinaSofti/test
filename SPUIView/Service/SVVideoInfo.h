//
//  TSVideoInfo.h
//  TaskService
//
//  Created by Rain on 1/30/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVVideoSegement.h"
#import <Foundation/Foundation.h>

/**
 *  视频信息
 */
@interface SVVideoInfo : NSObject
{
    @private
    // 视频分片信息
    NSMutableArray *_segements;
}


// 视频URL
@property NSString *videoURL;

// vid
@property NSString *vid;

// 视频title
@property NSString *title;

// 视频服务器返回的视频Json对象
@property NSData *videoDataJson;

/**
 *  使用视频URL进行初始化
 *
 *  @param videoURL 视频URL
 *
 *  @return 视频信息对象
 */
- (id)initWithURL:(NSString *)videoURL;

/**
 *  添加视频分片
 *
 *  @param segement 分片
 */
- (void)addSegement:(SVVideoSegement *)segement;

/**
 *  获取所有分片
 *
 *  @return 分片
 */
- (NSArray *)getAllSegement;

@end
