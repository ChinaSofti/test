//
//  SVPointView.h
//  SPUIView
//
//  Created by WBapple on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface SVPointView : UIView

@property (nonatomic, assign) float num; //定义随机数
// VideoTestingView中的属性
@property (nonatomic, strong) UIView *pointView; //定义指针View
@property (nonatomic, strong) UIView *grayView; //定义gray遮挡View
@property (nonatomic, strong) UIView *panelView; //定义仪表盘panelView
@property (nonatomic, strong) UIView *middleView; //定义中间半圆middleView
@property (nonatomic, strong) UILabel *label1; //定义label1
@property (nonatomic, strong) UILabel *label2; //定义label2
// WebTestingView中的属性
@property (nonatomic, strong) UIView *panelView2; //定义仪表盘panelView2
@property (nonatomic, strong) UILabel *label12; //定义label12
@property (nonatomic, strong) UILabel *label22; //定义label22
@property (nonatomic, strong) UILabel *label32; //定义label32,单位s
//开始转动方法
- (void)start;
//转动角度,速度控制
//- (void)rotate;
//每5s产生一个随机数
//- (void)suijishu;
/**
 *  更新仪表盘UvMOS值
 *
 *  @param uvMOS uvMOS值
 */
- (void)updateUvMOS:(float)uvMOS;

@end
