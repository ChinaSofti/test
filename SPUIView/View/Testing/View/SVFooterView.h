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
// videotesting
@property (nonatomic, strong) UILabel *placeLabel; // 定义视频服务位置place
@property (nonatomic, strong) UILabel *resolutionLabel; // 定义分辨率resolution
@property (nonatomic, strong) UILabel *bitLabel; // 定义码率(比特率bit)
//对应的值
@property (nonatomic, strong) UILabel *placeNumLabel;
@property (nonatomic, strong) UILabel *resolutionNumLabel;
@property (nonatomic, strong) UILabel *bitNumLabel;

// webtesting
@property (nonatomic, strong) UILabel *urlLabel; //测试网址
@property (nonatomic, strong) UIView *abc;
//对应的值
@property (nonatomic, strong) UILabel *urlNumLabel;
// speedtesting
@property (nonatomic, strong) UILabel *ServerLocation; //测试服务器位置
@property (nonatomic, strong) UILabel *Carrier; //所属运营商
@property (nonatomic, strong) UIView *abcd;
//对应的值
@property (nonatomic, strong) UILabel *ServerLocationNumLabel;
@property (nonatomic, strong) UILabel *CarrierNumLabel;
@end
