//
//  SVHeaderView.h
//  SpeedPro
//
//  Created by WBapple on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVHeaderView : UIView

// webtesting
// HeaderView中的属性值
@property (nonatomic, strong) UILabel *ResponseLabel; // 响应时间
@property (nonatomic, strong) UILabel *ResponseLabel1; // 单位s
@property (nonatomic, strong) UILabel *DownloadLabel; //下载速率
@property (nonatomic, strong) UILabel *DownloadLabel1; // 单位kbps
@property (nonatomic, strong) UILabel *LoadLabel; //完全加载时间
@property (nonatomic, strong) UILabel *LoadLabel1; // 单位s
//对应的标题
@property (nonatomic, strong) UILabel *ResponseNumLabel;
@property (nonatomic, strong) UILabel *DownloadNumLabel;
@property (nonatomic, strong) UILabel *LoadNumLabel;
// speedtesting
// HeaderView中的属性值
@property (nonatomic, strong) UILabel *Delay; // 时延
@property (nonatomic, strong) UILabel *Delay1; // 单位s
@property (nonatomic, strong) UILabel *Downloadspeed; //下载速率
@property (nonatomic, strong) UILabel *Downloadspeed1; // 单位kbps
@property (nonatomic, strong) UILabel *Uploadspeed; //上传速率
@property (nonatomic, strong) UILabel *Uploadspeed1; // 单位s
//对应的标题
@property (nonatomic, strong) UILabel *DelayNumLabel;
@property (nonatomic, strong) UILabel *DownloadspeedNumLabel;
@property (nonatomic, strong) UILabel *UploadspeedNumLabel;

//初始化方法
- (instancetype)initWithDic:(NSMutableDictionary *)dic;

/**
 * 将左侧的labe换成view
 */
- (void)replaceLeftLabelWithView:(UIView *)view;

/**
 * 更新左侧的label内容
 */
- (void)updateLeftValue:(NSString *)value;

/**
 * 更新中间的label内容
 */
- (void)updateMiddleValue:(NSString *)value;

/**
 * 更新右侧的label内容
 */
- (void)updateRightValue:(NSString *)value;

@end
