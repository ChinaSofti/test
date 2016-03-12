//
//  SVSpeedTestContext.m
//  SpeedPro
//
//  Created by 李灏 on 16/3/11.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SPService/SVSpeedTestServers.h"
#import "SVSpeedTestContext.h"

@implementation SVSpeedTestContext

@synthesize downloadUrl, uploadUrl, delayUrl;

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    return self;
}

@end
