//
//  SVFAQViewCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/3/4.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVFAQViewCtrl.h"
#import "SVHtmlTools.h"
#import <WebKit/WebKit.h>

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
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    [self.view addSubview:webView];
    
    // 并且加载内置网页
    SVHtmlTools *htmlTools = [[SVHtmlTools alloc] init];
    [htmlTools createWebViewWithFileName:@"faq" webView:webView];
}

//返回按钮点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
