//
//  SVProgressView.h
//  SpeedPro
//
//  Created by WBapple on 16/4/13.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVProgressView : UIProgressView
//初始化方法
/**
 *  ProgressView进度条初始化方法
 *
 *  @param totalTime 进度条运行的总时间
 *  @param height    导航栏的高度(已经写好宏NavBarH)
 *
 *  @return 一个运行总长为totalTiem的ProgressView进度条
 */
- (instancetype)initWithheight:(int)height;
- (void)bindTimerTotalTime:(float)totalTime;
@end
