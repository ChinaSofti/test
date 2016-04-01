//
//  SVFooterView.m
//  SpeedPro
//
//  Created by WBapple on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVFooterView.h"
@implementation SVFooterView

//初始化方法
- (instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    // 设置view大小
    [self setFrame:CGRectMake (0, FITHEIGHT (1366), kScreenW, FITHEIGHT (410))];

    // 初始化左侧的View
    _leftView = [[UIView alloc]
    initWithFrame:CGRectMake (FITWIDTH (30), FITHEIGHT (30), FITWIDTH (524), FITHEIGHT (312))];
    [_leftView.layer setBorderColor:[UIColor colorWithHexString:@"#DDDDDD"].CGColor];
    [_leftView.layer setBorderWidth:FITHEIGHT (1)];

    // 初始化右侧的View
    _rightView = [[UIView alloc]
    initWithFrame:CGRectMake (_leftView.rightX, FITHEIGHT (30), FITWIDTH (526), FITHEIGHT (312))];


    [self addSubview:_leftView];
    [self addSubview:_rightView];
    return self;
}

// 去掉左侧View的边框
- (void)removeBoderWidth
{
    [_leftView.layer setBorderWidth:0];
}

@end
