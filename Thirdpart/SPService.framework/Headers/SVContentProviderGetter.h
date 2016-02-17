//
//  SVContentProviderGetter.h
//  SPUIView
//
//  Created by Rain on 2/6/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "UvMOS_Outer_Api.h"
#import <Foundation/Foundation.h>
/**
 *  获取视频提供商
 */
@interface SVContentProviderGetter : NSObject


/**
 *  获取视频提供商
 *
 *  @param videoURLHost 域名
 *
 *  @return 视频提供商
 */
+ (UvMOSContentProvider)getContentProvider:(NSString *)videoURL;

@end
