//
//  CTViewTools.h
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTViewTools : UIView
/**
 *获取图片某点或区域的颜色(此处为了画边框的颜色)
 **/
+ (UIColor *)colorWithImg:(UIImage *)img point:(CGPoint)point;

@end
