//
//  UIColor+Hex.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/29.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    // 处理字符串
    NSString *cString = [self dealColorStr:color];
    if (!cString)
    {
        return [UIColor clearColor];
    }

    return [self initUIColor:cString alpha:alpha];
}

// 默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color
{
    // 处理字符串
    NSString *cString = [self dealColorStr:color];
    if (!cString)
    {
        return [UIColor clearColor];
    }

    return [self initUIColor:cString alpha:1.0f];
}

+ (NSString *)dealColorStr:(NSString *)color
{
    // 删除字符串中的空格
    NSString *cString =
    [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return nil;
    }

    // 如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }

    // 如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }

    if ([cString length] != 8 && [cString length] != 6)
    {
        return nil;
    }

    return cString;
}

+ (UIColor *)initUIColor:(NSString *)colorStr alpha:(CGFloat)alpha
{
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;

    // 如果是8位，前两位是透明度
    if ([colorStr length] == 8)
    {
        NSString *alphaStr = [colorStr substringWithRange:range];
        unsigned int a;
        [[NSScanner scannerWithString:alphaStr] scanHexInt:&a];
        alpha = (float)a;
        range.location += 2;
    }

    // r
    NSString *rString = [colorStr substringWithRange:range];

    // g
    range.location += 2;
    NSString *gString = [colorStr substringWithRange:range];

    // b
    range.location += 2;
    NSString *bString = [colorStr substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:alpha];
}

@end
