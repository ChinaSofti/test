//
//  SVAboutViewCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/5/19.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVAboutViewCtrl.h"
#import "SVHtmlTools.h"
#import <WebKit/WebKit.h>
@interface SVAboutViewCtrl ()

@end

@implementation SVAboutViewCtrl

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
    //    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    //    config.selectionGranularity = WKSelectionGranularityCharacter;
    //
    //    WKWebView *webView =
    //    [[WKWebView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)
    //    configuration:config];
    //    [self.view addSubview:webView];
    //
    //    // 加载内置网页
    //    SVHtmlTools *htmlTools = [[SVHtmlTools alloc] init];
    //    [htmlTools loadHtmlWithFileName:@"faq" webView:webView];
    UILabel *lable = [[UILabel alloc] init];
    lable.text = @"内容待添加";
    lable.textColor = [UIColor grayColor];
    lable.frame = CGRectMake (0, 0, 300, 30);
    lable.textAlignment = NSTextAlignmentCenter;
    lable.center = self.view.center;
    [self.view addSubview:lable];
}

//返回按钮点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
