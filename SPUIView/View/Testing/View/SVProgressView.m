//
//  SVProgressView.m
//  SpeedPro
//
//  Created by WBapple on 16/4/13.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVProgressView.h"
#import "SVVideoView.h"
@implementation SVProgressView
{
    //定时器
    NSTimer *progressTimer;

    //进度条的进度值
    float progressVlaue;

    //进度条播放总时间
    float totalTimed;
}

/**
 * 初始化方法
 */
- (instancetype)initWithheight:(int)height
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    // 初始化进度条
    [self setFrame:CGRectMake (0, StatusBarH + height, kScreenW, 0)];
    //样式
    [self setProgressViewStyle:UIProgressViewStyleDefault];
    //进度条颜色
    self.progressTintColor = [UIColor colorWithHexString:@"#29A5E5"];
    //背景颜色
    self.trackTintColor = [UIColor whiteColor];
    //初始值
    progressVlaue = 0.0;
    return self;
}

/**
 * 绑定定时器
 */
- (void)bindTimerTotalTime:(float)totalTime
{
    totalTimed = totalTime;
    //定时器(1s秒执行一次)
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector (changeProgress)
                                                   userInfo:@"Progress"
                                                    repeats:YES];
}

/**
 * 改变进度条进度
 */
- (void)changeProgress
{
    // 进度值为1，说明进度条已经满了
    if (progressVlaue >= 1)
    {
        // 取消定时器
        [progressTimer invalidate];
        progressTimer = nil;
        return;
    }

    //每秒钟增加多少 = 1/总时间(s)
    progressVlaue += 1 / totalTimed;
    [self setProgress:progressVlaue];
}

/**
 * 取消定时器
 */
- (void)cancelTimer
{
    if (progressTimer)
    {
        // 取消定时器
        [progressTimer invalidate];
        progressTimer = nil;
    }
}
@end
