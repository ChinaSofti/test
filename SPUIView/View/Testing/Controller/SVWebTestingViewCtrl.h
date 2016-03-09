//
//  SVWebTestingViewCtrl.h
//  SpeedPro
//
//  Created by WBapple on 16/3/8.
//  Copyright © 2016年 chinasofti. All rights reserved.
//


/**
 *  网页测试中界面
 */
#import "SVCurrentResultModel.h"
#import <SPService/SVVideoTest.h>
#import <UIKit/UIKit.h>

@interface SVWebTestingViewCtrl : UIViewController <SVVideoTestDelegate>

@property (nonatomic, retain) NSArray *selectedA;

@property (nonatomic, retain) UINavigationController *navigationController;

@property UITabBarController *tabBarController;

@property SVCurrentResultModel *currentResultModel;

@end
