//
//  SVFAQViewCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/3/4.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVFAQViewCtrl.h"
#import <SPCommon/SVLog.h>

@interface SVFAQViewCtrl ()

@end

@implementation SVFAQViewCtrl
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //设置LeftBarButtonItem
    [self createLeftBarButtonItem];
    [self createUI];
}

//进去时 隐藏tabBar
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabBar" object:nil];
}
//出来时 显示tabBar
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabBar" object:nil];
}

- (void)createLeftBarButtonItem
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, 45, 23)];
    [button setImage:[UIImage imageNamed:@"homeindicator"] forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *back0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil
                                                                           action:nil];
    back0.width = -15;
    self.navigationItem.leftBarButtonItems = @[back0, backButton];
    [button addTarget:self
               action:@selector (leftBackButtonClick)
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)leftBackButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    // label
    UILabel *label = [CTWBViewTools createLabelWithFrame:CGRectMake (10, 72, 200, 20)
                                                withFont:15
                                          withTitleColor:[UIColor blackColor]
                                               withTitle:@"123"];
    [self.view addSubview:label];
    // webview
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake (0, 95, kScreenW, kScreenH - 95)];
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:webview];
}

@end
