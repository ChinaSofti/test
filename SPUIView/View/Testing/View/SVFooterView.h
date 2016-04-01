//
//  SVFooterView.h
//  SpeedPro
//
//  Created by WBapple on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface SVFooterView : UIView

//定义FooterView中的属性

// 左侧的View
@property (nonatomic, strong) UIView *leftView;

// 右侧的View
@property (nonatomic, strong) UIView *rightView;

// 去掉左侧View的边框
- (void)removeBoderWidth;


@end
