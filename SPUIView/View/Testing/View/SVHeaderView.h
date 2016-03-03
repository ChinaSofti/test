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
// uvMos
@property (nonatomic, strong) UIView *uvMosBarView;
//测试速度
@property (nonatomic, strong) UILabel *speedLabel;
// 单位ms
@property (nonatomic, strong) UILabel *speedLabel1;
//首次加载时间
@property (nonatomic, strong) UILabel *bufferLabel;
//对应的值
@property (nonatomic, strong) UILabel *uvMosNumLabel;
@property (nonatomic, strong) UILabel *speedNumLabel;
@property (nonatomic, strong) UILabel *bufferNumLabel;
@end
