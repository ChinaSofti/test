//
//  SVWifiInfo.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/5/11.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVWifiInfo.h"

@implementation SVWifiInfo

@synthesize wifiName, bandWidth;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.wifiName forKey:@"wifiName"];
    [aCoder encodeObject:self.bandWidth forKey:@"bandWidth"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.wifiName = [aDecoder decodeObjectForKey:@"wifiName"];
        self.bandWidth = [aDecoder decodeObjectForKey:@"bandWidth"];
    }
    return self;
}

@end
