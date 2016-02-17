//
//  SVUvMOSVideoResolutionGetter.h
//  SPUIView
//
//  Created by Rain on 2/6/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "UvMOS_Outer_Api.h"
#import <Foundation/Foundation.h>

/**
 *  根据视频宽度和高度获取对应的视频分辨率
 */
@interface SVUvMOSVideoResolutionGetter : NSObject

/**
 *  根据视频宽度和高度获取对应的视频分辨率
 *
 *  @param height 视频高度
 *  @param width  视频宽带
 *
 *  @return 视频分辨率
 */
+ (UvMOSVideoResolution)getUvMOSVideoResolution:(int)width height:(int)height;

@end
