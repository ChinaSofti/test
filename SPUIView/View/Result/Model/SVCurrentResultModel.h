//
//  SVCurrentResultModel.h
//  SPUIView
//
//  Created by Rain on 2/14/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVCurrentResultModel : NSObject

// 基本参数
@property (nonatomic, retain) NSArray *selectedA;
@property (nonatomic, retain) UINavigationController *navigationController;
@property UITabBarController *tabBarController;

// 测试例 ID， 标示唯一
@property long long testId;

// 视频测试结果相关指标
@property BOOL videoTest;
@property float uvMOS;
@property int firstBufferTime;
@property int cuttonTimes;

// 网页测试相关指标
@property BOOL webTest;
@property double responseTime;
@property double totalTime;
@property double downloadSpeed;

// 带宽测试相关指标
@property BOOL speedTest;
@property double stDelay;
@property double stDownloadSpeed;
@property double stUploadSpeed;
@property NSString *stLocation;
@property NSString *stIsp;


- (id)init;

- (void)pushNextCtrl;

- (void)addCtrl:(UIViewController *)ctrl;

// 将已经推送完成的controller重新放入待推送的controller数组，并将已经推送完成的controller数组清空
- (void)copyCompleteCtrlToCtrlArray;

@end
