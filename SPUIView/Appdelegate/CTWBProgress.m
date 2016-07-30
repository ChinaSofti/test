//
//  CTWBProgresss.m
//  SpeedPro
//
//  Created by WBapple on 16/7/31.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "CTWBProgress.h"

@implementation CTWBProgress
//初始化进度条(此处设置进度条背景图片和进图条填充图片)
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        // 背景图像
        _trackView =
        [[UIImageView alloc] initWithFrame:CGRectMake (0, 0, frame.size.width, frame.size.height)];
        [_trackView setImage:[UIImage imageNamed:@"1.png"]];
        //当前view的主要作用是将出界了的_progressView剪切掉，所以需将clipsToBounds设置为YES
        _trackView.clipsToBounds = YES;
        [self addSubview:_trackView];
        // 填充图像
        _progressView = [[UIImageView alloc]
        initWithFrame:CGRectMake (0 - frame.size.width, 0, frame.size.width, frame.size.height)];
        [_progressView setImage:[UIImage imageNamed:@"2.png"]];
        [_trackView addSubview:_progressView];
    }
    return self;
}
//设置进度条的值
- (void)setProgress:(CGFloat)progress
{
    _targetProgress = progress;
    [self changeProgressViewFrame];
}
//修改显示内容
- (void)changeProgressViewFrame
{
    _progressView.frame = CGRectMake (self.frame.size.width * _targetProgress - self.frame.size.width,
                                      0, self.frame.size.width, self.frame.size.height);
}

@end