//
//  SVPointView.h
//  SPUIView
//
//  Created by WBapple on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
/*

 指针转动XIB页面

 */

#import <UIKit/UIKit.h>

@interface SVPointView : UIView

// HeaderView中的属性
@property (nonatomic, strong) UIView *uvMosBarView;
//测试速度
@property (nonatomic, strong) UILabel *speedLabel;
//首次加载时间
@property (nonatomic, strong) UILabel *bufferLabel;
@property (nonatomic, strong) UILabel *uvMosNumLabel;
@property (nonatomic, strong) UILabel *speedNumLabel;
@property (nonatomic, strong) UILabel *bufferNumLabel;


// TestingView中的属性
//定义随机数
@property (nonatomic, assign) float num;
//定义指针View
@property (nonatomic, strong) UIView *pointView;
//定义gray遮挡View
@property (nonatomic, strong) UIView *grayView;
//定义grayViewSuperView
@property (nonatomic, weak) UIView *grayViewSuperView;
//定义IndexIn(插入view的位置)
@property (nonatomic, assign) NSInteger grayViewIndexInSuperView;
//定义仪表盘panelView
@property (nonatomic, strong) UIView *panelView;


//定义中间半圆middleView
@property (nonatomic, strong) UIView *middleView;
//定义label1
@property (nonatomic, strong) UILabel *label1;
//定义label2
@property (nonatomic, strong) UILabel *label2;
//定义label2SuperView
@property (nonatomic, weak) UIView *label2SuperView;
//定义label2IndexInSuperView(插入label的位置)
@property (nonatomic, assign) NSInteger label2IndexInSuperView;

//定义videoView中的属性
@property (nonatomic, strong) UIView *vView;
//定义videoView中的属性
@property (nonatomic, strong) UIView *vvView;

//定义FooterView中的属性
// footerView参数
// 定义视频服务位置place
// 定义分辨率resolution
// 定义码率(比特率bit)
@property (nonatomic, strong) UILabel *placeLabel;
@property (nonatomic, strong) UILabel *resolutionLabel;
@property (nonatomic, strong) UILabel *bitLabel;
@property (nonatomic, strong) UILabel *placeNumLabel;
@property (nonatomic, strong) UILabel *resolutionNumLabel;
@property (nonatomic, strong) UILabel *bitNumLabel;

//指针转动页面用XIB页面
- (UIView *)pointView;
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
