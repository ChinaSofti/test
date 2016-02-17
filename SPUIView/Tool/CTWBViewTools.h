//
//  CTWBViewTools.h
//  SPUIView
//
//  Created by WBapple on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTWBViewTools : NSObject

#pragma mark - 通用白色圆角背景
+ (UIView *)createBackgroundViewWithFrame:(CGRect)frame cornerRadius:(CGFloat)radius;

#pragma mark - Label
+ (UILabel *)createLabelWithFrame:(CGRect)frame withFont:(CGFloat)font withTitleColor:(UIColor *)color withTitle:(NSString *)title;

#pragma mark - 输入框
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftView:(UIView*)leftView rightView:(UIView*)rightView Font:(float)font fontColor:(UIColor *)color;

+ (UITextField*)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftView:(UIView*)leftView rightView:(UIView*)rightView Font:(float)font withLineColor:(UIColor *)lineColor lineWidth:(CGFloat)linewidth;

//输入框左view
+ (UIView *)viewWithFrame:(CGRect)frame withImage:(UIImage *)image withTitle:(NSString *)title;

#pragma mark - Button

// 普通button
+ (UIButton *)createBtnWithFrame:(CGRect)frame backgroundImage:(NSString *)backgroundImage hightlightedImage:(NSString *)hightlighted title:(NSString *)title titleColor:(UIColor *)titleColor;

+ (UIButton *)createBtnWithFrame:(CGRect)frame normalImage:(NSString *)normalImage highlighImage:(NSString *)highlighImage seleceImage:(NSString *)selectImage normalTitle:(NSString *)normalTitle normalColor:(UIColor *)normalColor;

// 文字与图片有偏移
+ (UIButton *)createBtnWithFrame:(CGRect)frame normalImage:(NSString *)normalImage highlighImage:(NSString *)highlighImage seleceImage:(NSString *)selectImage normalTitle:(NSString *)normalTitle normalColor:(UIColor *)normalColor titleEdge:(UIEdgeInsets)titleEdge imageEdge:(UIEdgeInsets)imageEdge;

//自定义UIBarButtonItem
+ (UIBarButtonItem *)itemWithImage:(NSString *)imageName selectedImage:(NSString *)selectedImageName Target:(id)target action:(SEL)action;


#pragma mark - 线view
+ (UIView *)lineViewWithFrame:(CGRect)frame withColor:(UIColor *)color;

#pragma mark - 计算文字大小
+ (CGSize)getSizeWith:(NSString *)string size:(CGSize)bigSize font:(CGFloat)font;


#pragma mark - alertControl
#pragma mark AlertView
+ (UIAlertController *)alertViewWithTitle:(NSString *)title message:(NSString *)message okTitle:(NSString *)okTitle okClick:(void(^)(void))okClick  cancelTitle:(NSString *)cancelTitle  cancelClick:(void(^)(void))cancelClick;

#pragma mark ActionSheet
//+ (UIAlertController *)actionSheetWithTitle:(NSString *)title message:(NSString *)message titleArray:(NSArray *)titleArray cancelTitle:(NSString *)cancelTitle;

#pragma mark - 生成图片缩略图
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

#pragma mark - 表情输入
+ (BOOL)isContainsEmoji:(NSString *)string;

#pragma mark - 取消searchbar背景色
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
