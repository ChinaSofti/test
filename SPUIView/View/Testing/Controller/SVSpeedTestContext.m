//
//  SVSpeedTestContext.m
//  SpeedPro
//
//  Created by 李灏 on 16/3/11.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

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

    self.downloadUrl =
    [NSURL URLWithString:@"http://bj3.unicomtest.com:80/speedtest/random4000x4000.jpg"];
    self.uploadUrl = [NSURL URLWithString:@"http://bj3.unicomtest.com:80/speedtest/upload.php"];
    self.delayUrl = [NSURL URLWithString:@"http://bj3.unicomtest.com:80/speedtest/latency.txt"];
    return self;
}

@end
