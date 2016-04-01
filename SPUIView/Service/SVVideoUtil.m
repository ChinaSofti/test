//
//  CTUtils.m
//  SPUIView
//
//  Created by Rain on 2/6/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVVideoUtil.h"

@implementation SVVideoUtil

/**
 *  获取屏幕尺寸
 *
 *  @return 屏幕尺寸
 */
+ (CGSize)getScreenSize
{
    //屏幕尺寸
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    return size;
}

/**
 *  获取屏幕分辨率
 *
 *  @return 屏幕分辨率
 */
+ (CGSize)getScreenScale
{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize Size = [MainScreen bounds].size;
    CGFloat scale = [MainScreen scale];
    return CGSizeMake (Size.width * scale, Size.height * scale);
}

@end
