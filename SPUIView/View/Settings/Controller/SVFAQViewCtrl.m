//
//  SVFAQViewCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/3/4.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVFAQViewCtrl.h"
#import "SVHtmlTools.h"

@interface SVFAQViewCtrl ()

@end

@implementation SVFAQViewCtrl
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 初始化返回按钮
    [super initBackButtonWithTarget:self action:@selector (backButtonClick)];
    [self createUI];
}

//进去时 隐藏tabBar
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabBar" object:nil];
}
//出来时 显示tabBar
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabBar" object:nil];
}

- (void)createUI
{
    // 创建WKWebView并且加载内置网页
    SVHtmlTools *htmlTools = [[SVHtmlTools alloc] init];
    [htmlTools createWebViewWithFileName:@"faq" superView:self.view];
}

//返回按钮点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
