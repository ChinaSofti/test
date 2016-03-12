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
@property (nonatomic, strong) UIView *grayView2; //定义gray遮挡View2
@property (nonatomic, strong) UIView *panelView2; //定义仪表盘panelView2
@property (nonatomic, strong) UILabel *label12; //定义label12
@property (nonatomic, strong) UILabel *label22; //定义label22
@property (nonatomic, strong) UILabel *label32; //定义label32,单位s
// SpeedTestingView中的属性
@property (nonatomic, strong) UIView *grayView3; //定义gray遮挡View2
@property (nonatomic, strong) UIView *panelView3; //定义仪表盘panelView3
@property (nonatomic, strong) UILabel *label13; //定义label13
@property (nonatomic, strong) UILabel *label23; //定义label23
@property (nonatomic, strong) UILabel *label33; //定义label23,单位Mbps


// video
//开始转动方法
- (void)start;
/**
 *  更新仪表盘UvMOS值
 *
 *  @param uvMOS uvMOS值
 */
- (void)updateUvMOS:(float)uvMOS;
// web
//开始转动方法
- (void)start2;
- (void)updateUvMOS2:(float)uvMOS;
// speed
//开始转动方法
- (void)start3;
- (void)updateUvMOS3:(float)uvMOS;
@end
