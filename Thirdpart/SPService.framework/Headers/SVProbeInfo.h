//
//  SVProbeInfo.h
//  SPUIView
//
//  Created by Rain on 2/11/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 测试执行状态
 */
typedef enum _NetworkType {
    // wife
    WIFE = 0,
    // 移动
    MOBILE = 1,
} NetworkType;

@interface SVProbeInfo : NSObject

@property NSString *ip;
@property NSString *isp;
@property NSString *location;
@property NSString *signedBandwidth;
@property NSString *networkType;
@property NSString *singnal;


/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance;


@end
