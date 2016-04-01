//
//  SVCurrentDevice.m
//  SpeedPro
//
//  Created by Rain on 3/26/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVCurrentDevice.h"
#import "sys/utsname.h"

@implementation SVCurrentDevice


/**
 *  获取当前手机型号
 *
 *  @return 手机型号。 i386 和 x86_64 对应的是模拟器
 */
+ (NSString *)deviceType
{
    struct utsname systemInfo;
    uname (&systemInfo);
    NSString *deviceString =
    [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];


    NSArray *modelArray = @[

        // iPhone Simulator
        @"i386",
        @"x86_64",

        // iPhone
        @"iPhone1,1",
        @"iPhone1,2",
        @"iPhone2,1",
        @"iPhone3,1",
        @"iPhone3,2",
        @"iPhone3,3",
        @"iPhone4,1",
        @"iPhone5,1",
        @"iPhone5,2",
        @"iPhone5,3",
        @"iPhone5,4",
        @"iPhone6,1",
        @"iPhone6,2",
        @"iPhone7,1",
        @"iPhone7,2",
        @"iPhone8,1",
        @"iPhone8,2",

        // iPod Touch
        @"iPod1,1",
        @"iPod2,1",
        @"iPod3,1",
        @"iPod4,1",
        @"iPod5,1",
        @"iPod7,1",

        // iPad
        @"iPad1,1",
        @"iPad2,1",
        @"iPad2,2",
        @"iPad2,3",
        @"iPad2,4",
        @"iPad3,1",
        @"iPad3,2",
        @"iPad3,3",
        @"iPad3,4",
        @"iPad3,5",
        @"iPad3,6",

        // iPad mini
        @"iPad2,5",
        @"iPad2,6",
        @"iPad2,7",
    ];


    NSArray *modelNameArray = @[

        // iPhone Simulator
        @"iPhone Simulator i386",
        @"iPhone Simulator x86_64",

        // iPhone
        @"iPhone 2G",
        @"iPhone 3G",
        @"iPhone 3GS",
        @"iPhone 4(GSM)",
        @"iPhone 4(GSM Rev A)",
        @"iPhone 4(CDMA)",
        @"iPhone 4S",
        @"iPhone 5(GSM)",
        @"iPhone 5(GSM+CDMA)",
        @"iPhone 5c(GSM)",
        @"iPhone 5c(Global)",
        @"iphone 5s(GSM)",
        @"iphone 5s(Global)",
        @"iPhone 6 Plus (A1522/A1524)",
        @"iPhone 6 (A1549/A1586)",
        @"iPhone 6s (A1633/A1688/A1691/A1700)",
        @"iPhone 6s Plus (A1634/A1687/A1690/A1699)",

        // iPod Touch
        @"iPod Touch 1G",
        @"iPod Touch 2G",
        @"iPod Touch 3G",
        @"iPod Touch 4G",
        @"iPod Touch 5G",
        @"iPod Touch 6G (A1574)",

        // iPad
        @"iPad",
        @"iPad 2(WiFi)",
        @"iPad 2(GSM)",
        @"iPad 2(CDMA)",
        @"iPad 2(WiFi + New Chip)",
        @"iPad 3(WiFi)",
        @"iPad 3(GSM+CDMA)",
        @"iPad 3(GSM)",
        @"iPad 4(WiFi)",
        @"iPad 4(GSM)",
        @"iPad 4(GSM+CDMA)",

        // iPad mini
        @"iPad mini (WiFi)",
        @"iPad mini (GSM)",
        @"ipad mini (GSM+CDMA)"
    ];

    NSInteger modelIndex = -1;
    NSString *modelNameString = nil;
    modelIndex = [modelArray indexOfObject:deviceString];
    if (modelIndex >= 0 && modelIndex < [modelNameArray count])
    {
        modelNameString = [modelNameArray objectAtIndex:modelIndex];
    }
    else
    {
        modelNameString = deviceString;
    }

    return modelNameString;
}


@end
