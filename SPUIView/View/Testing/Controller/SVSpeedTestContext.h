//
//  SVSpeedTestContext.h
//  SpeedPro
//
//  Created by 李灏 on 16/3/11.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPService/SVTestContext.h>

@interface SVSpeedTestContext : SVTestContext

@property NSURL *downloadUrl;
@property NSURL *uploadUrl;
@property NSURL *delayUrl;

- (id)init;

@end
