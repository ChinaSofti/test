//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlertView;

//定义代理协议
@protocol AlertViewDelegate <NSObject>

//声明代理方法
- (void)alertView:(AlertView *)alertView didClickBtn:(NSInteger)index;

- (void)alertView:(AlertView *)alertView overLookBtnClick:(UIButton *)Btn;

- (void)alertView:(AlertView *)alertView saveBtnClick:(UIButton *)Btn;

@end

@interface AlertView : UIView

//设置代理属性
@property (nonatomic, weak) id<AlertViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame bgColor:(UIColor *)color;

@property (nonatomic, copy) UITextField *mealTextField;
@property (nonatomic, copy) UILabel *contentLabel;

@end
