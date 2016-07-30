//
//  CTWBProgress.h
//  SpeedPro
//
//  Created by WBapple on 16/7/31.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTWBProgress : UIView
// 进度条背景图片
@property (retain, nonatomic) UIImageView *trackView;
// 进图条填充图片
@property (retain, nonatomic) UIImageView *progressView;
//进度
@property (nonatomic) CGFloat targetProgress;
//设置进度条的值
- (void)setProgress:(CGFloat)progress;
@end