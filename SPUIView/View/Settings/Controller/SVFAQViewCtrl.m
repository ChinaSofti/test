//
//  SVFAQViewCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/3/4.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVFAQViewCtrl.h"

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
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    NSURL *url = [NSURL URLWithString:@"http://58.60.106.185:12210/faq-ios.html"];
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:webview];
}

//返回按钮点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
