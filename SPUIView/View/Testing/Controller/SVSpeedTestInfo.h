//
//  SVSpeedTestInfo.h
//  SpeedPro
//
//  Created by 李灏 on 16/3/10.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVSpeedTestInfo : NSObject
@property NSString *host;
@property NSString *ip;
@property NSNumber *port;

@property NSURL *downloadUrl;
@property NSString *downloadPath;
@property NSURL *uploadUrl;
@property NSString *uploadPath;
@property NSURL *delayUrl;
@property NSString *delayPath;

@end
