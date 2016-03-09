//
//  SVHeaderView.h
//  SpeedPro
//
//  Created by WBapple on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVHeaderView : UIView

// videotesting
// HeaderView中的属性
@property (nonatomic, strong) UIView *uvMosBarView; // uvMos
@property (nonatomic, strong) UILabel *speedLabel; //测试速度
@property (nonatomic, strong) UILabel *speedLabel1; // 单位ms
@property (nonatomic, strong) UILabel *bufferLabel; //首次加载时间
//对应的值
@property (nonatomic, strong) UILabel *uvMosNumLabel;
@property (nonatomic, strong) UILabel *speedNumLabel;
@property (nonatomic, strong) UILabel *bufferNumLabel;
// webtesting
// HeaderView中的属性
@property (nonatomic, strong) UILabel *ResponseLabel; // 响应时间
@property (nonatomic, strong) UILabel *ResponseLabel1; // 单位s
@property (nonatomic, strong) UILabel *DownloadLabel; //下载速率
@property (nonatomic, strong) UILabel *DownloadLabel1; // 单位kbps
@property (nonatomic, strong) UILabel *LoadLabel; //完全加载时间
@property (nonatomic, strong) UILabel *LoadLabel1; // 单位s
//对应的值
@property (nonatomic, strong) UILabel *ResponseNumLabel;
@property (nonatomic, strong) UILabel *DownloadNumLabel;
@property (nonatomic, strong) UILabel *LoadNumLabel;
// speedtesting
// HeaderView中的属性
@property (nonatomic, strong) UILabel *Delay; // 时延
@property (nonatomic, strong) UILabel *Delay1; // 单位s
@property (nonatomic, strong) UILabel *Downloadspeed; //下载速率
@property (nonatomic, strong) UILabel *Downloadspeed1; // 单位kbps
@property (nonatomic, strong) UILabel *Uploadspeed; //上传速率
@property (nonatomic, strong) UILabel *Uploadspeed1; // 单位s
//对应的值
@property (nonatomic, strong) UILabel *DelayNumLabel;
@property (nonatomic, strong) UILabel *DownloadspeedNumLabel;
@property (nonatomic, strong) UILabel *UploadspeedNumLabel;
@end
