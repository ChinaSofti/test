//
//  SVAboutViewCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/5/19.
//  Copyright © 2016年 Huawei. All rights reserved.
//
#import "SVAboutViewCtrl.h"
#import "SVAppVersionChecker.h"
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
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    // 设置内容大小
    //根据设备尺寸不同设置内容大小
    // 4s: *5
    // 5s:
    // 6s:*3.1
    // 6sp:
    scrollView.contentSize = CGSizeMake (kScreenW, kScreenH * 5);
    [self.view addSubview:scrollView];
    //添加logoimage
    UIImageView *imageView = [[UIImageView alloc]
    initWithFrame:CGRectMake (0, StatusBarH + NavBarH - FITHEIGHT (70), FITWIDTH (489), FITHEIGHT (83))];
    imageView.centerX = self.view.centerX;
    imageView.image = [UIImage imageNamed:@"aboutLogo489"];
    [scrollView addSubview:imageView];
    //添加LabV0.0.1版本号
    UILabel *labV = [[UILabel alloc]
    initWithFrame:CGRectMake (0, imageView.bottomY + FITHEIGHT (30), kScreenW, FITHEIGHT (120))];
    labV.centerX = self.view.centerX;
    labV.text = [SVAppVersionChecker currentVersion];
    labV.textAlignment = NSTextAlignmentCenter;
    labV.textColor = [UIColor colorWithHexString:@"#000000"];
    labV.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    labV.alpha = 0.7;
    [scrollView addSubview:labV];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.selectionGranularity = WKSelectionGranularityCharacter;

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake (0, labV.bottomY, kScreenW, kScreenH * 5)
                                            configuration:config];
    [scrollView addSubview:webView];

    // 加载内置的网页
    SVHtmlTools *htmlTool = [[SVHtmlTools alloc] init];
    [htmlTool loadHtmlWithFileName:@"about" webView:webView];
}

//返回按钮点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
