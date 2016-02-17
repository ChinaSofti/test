//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "CTYYLToolView.h"

@implementation CTYYLToolView

#pragma mark - Label

+ (UILabel *)createLabelWithFrame:(CGRect)frame
                         withFont:(CGFloat)font
                   withTitleColor:(UIColor *)color
                        withTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];

    label.font = [UIFont systemFontOfSize:font];

    label.textColor = color;

    label.text = title;

    return label;
}

#pragma mark - 线view
//线view
+ (UIView *)lineViewWithFrame:(CGRect)frame withColor:(UIColor *)color
{
    UIView *lineView = [[UIView alloc] initWithFrame:frame];

    lineView.backgroundColor = color;

    return lineView;
}

#pragma mark - 输入框
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame
                              placeholder:(NSString *)placeholder
                                     Font:(float)font
                                fontColor:(UIColor *)color
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    //灰色提示框
    textField.placeholder = placeholder;
    //文字对齐方式
    textField.textAlignment = NSTextAlignmentRight;
    //清除按钮
    textField.clearButtonMode = NO;
    //编辑状态下一直存在
    textField.rightViewMode = UITextFieldViewModeWhileEditing;
    //字体
    textField.font = [UIFont systemFontOfSize:font];
    //字体颜色
    textField.textColor = color;

    return textField;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake (0, 0, size.width, size.height);

    UIGraphicsBeginImageContext (rect.size);

    CGContextRef context = UIGraphicsGetCurrentContext ();

    CGContextSetFillColorWithColor (context, [color CGColor]);

    CGContextFillRect (context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext ();

    UIGraphicsEndImageContext ();

    return image;
}

@end
