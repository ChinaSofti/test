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
 *  根据视频URL查询和分析视频信息
 */
- (SVVideoInfo *)analyse;

@end
