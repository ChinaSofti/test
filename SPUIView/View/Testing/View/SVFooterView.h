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

@end
