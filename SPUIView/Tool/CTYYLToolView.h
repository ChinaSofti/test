//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

/**
 *工具类
 **/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTYYLToolView : NSObject

#pragma mark - Label
+ (UILabel *)createLabelWithFrame:(CGRect)frame
                         withFont:(CGFloat)font
                   withTitleColor:(UIColor *)color
                        withTitle:(NSString *)title;

#pragma mark - 线view
+ (UIView *)lineViewWithFrame:(CGRect)frame withColor:(UIColor *)color;

#pragma mark - 输入框
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame
                              placeholder:(NSString *)placeholder
                                     Font:(float)font
                                fontColor:(UIColor *)color;
#pragma mark - 图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
