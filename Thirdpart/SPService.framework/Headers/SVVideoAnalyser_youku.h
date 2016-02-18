//
//  TSVideoAnalyser_YouKu.h
//  TaskService
//
//  Created by Rain on 1/29/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVVideoAnalyser.h"

@interface SVVideoAnalyser_youku : SVVideoAnalyser

/**
 *  根据视频URL初始化视频信息分析器
 *
 *  @param videoURL 视频URL
 *
 *  @return 视频分片分析器
 */
- (id)initWithURL:(NSString *)videoURL;

/**
 *  根据视频URL查询和分析视频信息
 */
- (SVVideoInfo *)analyse;

@end
