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
@property (nonatomic, strong) UIView *pointView; //定义指针View
@property (nonatomic, strong) UIView *grayView; //定义gray遮挡View
@property (nonatomic, strong) UIView *panelView; //定义仪表盘panelView
@property (nonatomic, strong) UIView *middleView; //定义中间半圆middleView
@property (nonatomic, strong) UILabel *titleLabel; //定义指标名称label
@property (nonatomic, strong) UILabel *valueLabel; //定义指标值label
@property (nonatomic, strong) UILabel *unitLabel; //定义指标单位label

// 根据字典内容初始化表盘
- (instancetype)initWithDic:(NSMutableDictionary *)dic;

//开始转动方法
- (void)start;

/**
 *  更新仪表盘UvMOS值
 *
 *  @param uvMOS uvMOS值
 */
- (void)updateValue:(float)value;

@end
