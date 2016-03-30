//
//  SVViewController.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/29.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVViewController.h"

@interface SVViewController ()

@end

@implementation SVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 在显示view的时候修改navigationBar的高度
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 设置navigationBar的高度
    CGRect rect = self.navigationController.navigationBar.frame;
    [self.navigationController.navigationBar
    setFrame:CGRectMake (rect.origin.x, rect.origin.y, rect.size.width, FITHEIGHT (144))];
}

// 在即将显示view的时候修改返回按钮和标题距离底部的距离
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // 设置标题距离底部的距离
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:0.0
                                                                  forBarMetrics:UIBarMetricsDefault];

    // 设置返回按钮距离底部的距离
    [self.navigationItem.leftBarButtonItem setBackgroundVerticalPositionAdjustment:0.0
                                                                     forBarMetrics:UIBarMetricsDefault];
}

@end
