//
//  TSVideoURLAnalyseFactory.h
//  TaskService
//
//  Created by Rain on 1/29/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVVideoAnalyser.h"
#import <Foundation/Foundation.h>

/**
 *  视频分片分析器工厂类
 */
@interface SVVideoAnalyserFactory : NSObject

/**
 *  根据视频URL所属网站，返回该网站对应的视频分片信息分析器
 *
 *  @param videoURL 视频URL
 *
 *  @return 视频分片信息分析器
 */
+ (SVVideoAnalyser *)createAnalyser:(NSString *)videoURL;

@end
