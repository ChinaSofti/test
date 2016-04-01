//
//  TSVideoInfo.m
//  TaskService
//
//  Created by Rain on 1/30/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVVideoInfo.h"

@implementation SVVideoInfo

@synthesize vid, videoURL, videoDataJson, title;

/**
 *  使用视频URL进行初始化
 *
 *  @param videoURL 视频URL
 *
 *  @return 视频信息对象
 */
- (id)initWithURL:(NSString *)_videoURL
{
    self.videoURL = _videoURL;
    return self;
}

/**
 *  添加视频分片
 *
 *  @param segement 分片
 */
- (void)addSegement:(SVVideoSegement *)segement
{
    if (!_segements)
    {
        _segements = [[NSMutableArray alloc] init];
    }

    [_segements addObject:segement];
}

/**
 *  获取所有分片
 *
 *  @return 分片
 */
- (NSArray *)getAllSegement
{
    return _segements;
}

@end
