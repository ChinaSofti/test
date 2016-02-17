//
//  SVBackView.h
//  SPUIView
//
//  Created by WBapple on 16/1/26.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
//


/**
 *****点击back按钮弹窗界面***
 **/

#import <UIKit/UIKit.h>
@class SVBackView;

//定义代理协议
@protocol SVBackViewDelegate <NSObject>

//声明代理方法

- (void)backView:(SVBackView *)backView didClickBtn:(NSInteger)index;

- (void)backView:(SVBackView *)backView overLookBtnClick:(UIButton *)Btn;

- (void)backView:(SVBackView *)backView saveBtnClick:(UIButton *)Btn;

@end

@interface SVBackView : UIView

//设置代理属性
@property (nonatomic, weak) id<SVBackViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame bgColor:(UIColor *)color;

@property (nonatomic, copy) UITextField *mealTextField;
@property (nonatomic, copy) UILabel *contentLabel;

@end