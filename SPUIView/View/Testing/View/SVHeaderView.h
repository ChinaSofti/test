//
//  SVHeaderView.h
//  SpeedPro
//
//  Created by WBapple on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVHeaderView : UIView

// HeaderView中的属性
@property (nonatomic, strong) UIView *uvMosBarView; // uvMos
@property (nonatomic, strong) UILabel *speedLabel; //测试速度
@property (nonatomic, strong) UILabel *speedLabel1; // 单位ms
@property (nonatomic, strong) UILabel *bufferLabel; //首次加载时间
//对应的值
@property (nonatomic, strong) UILabel *uvMosNumLabel;
@property (nonatomic, strong) UILabel *speedNumLabel;
@property (nonatomic, strong) UILabel *bufferNumLabel;

@end
