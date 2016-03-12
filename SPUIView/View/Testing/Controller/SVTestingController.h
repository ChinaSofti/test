//
//  SVTestingController.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/10.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVTestingController : UIViewController

@property (nonatomic, retain) NSArray *selectedA;

@property (nonatomic, retain) NSMutableArray *nextController;

@property (nonatomic, retain) UINavigationController *navigationController;

@property UITabBarController *tabBarController;

@property SVCurrentResultModel *currentResultModel;

@end
