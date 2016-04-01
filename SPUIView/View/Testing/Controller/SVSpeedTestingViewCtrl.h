//
//  SVSpeedTestingViewCtrl.h
//  SpeedPro
//
//  Created by WBapple on 16/3/8.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

/**
 *  带宽测试中界面
 */

#import "SVCurrentResultModel.h"
#import "SVSpeedTest.h"

@interface SVSpeedTestingViewCtrl : SVViewController <SVSpeedTestDelegate>

@property (nonatomic, retain) NSArray *selectedA;

@property UINavigationController *navigationController;

@property UITabBarController *tabBarController;

@property SVCurrentResultModel *currentResultModel;

- (id)initWithResultModel:(SVCurrentResultModel *)resultModel;

@end