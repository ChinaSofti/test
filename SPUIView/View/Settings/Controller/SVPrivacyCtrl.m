//
//  SVPrivacyCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/4/14.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVHtmlTools.h"
#import "SVPrivacyCtrl.h"
#import <WebKit/WebKit.h>

@interface SVPrivacyCtrl ()
@end

@implementation SVPrivacyCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = I18N (@"Privacy Instructions");

    //    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];

    // 初始化返回按钮
    [super initBackButtonWithTarget:self action:@selector (backButtonClick)];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.selectionGranularity = WKSelectionGranularityCharacter;

    WKWebView *webView =
    [[WKWebView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH) configuration:config];
    [self.view addSubview:webView];

    // 加载内置的网页
    SVHtmlTools *htmlTool = [[SVHtmlTools alloc] init];
    [htmlTool loadHtmlWithFileName:@"Privacy" webView:webView];
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
#pragma mark - 创建UI
- (void)createUI
{
    NSString *title11 = I18N (@"PrivacyText1");
    UILabel *label1 = [[UILabel alloc] init];
    //    label1.backgroundColor = [UIColor redColor];
    label1.text = title11;
    label1.textColor = [UIColor colorWithHexString:@"#000000"];
    label1.font = [UIFont systemFontOfSize:pixelToFontsize (58)];
    label1.frame =
    CGRectMake (FITWIDTH (44), statusBarH + NavBarH + FITHEIGHT (20), kScreenW - FITWIDTH (88),
                [CTWBViewTools fitHeightToView:label1 width:kScreenW - FITWIDTH (88)]);
    label1.numberOfLines = 0;
    //    //调整行间距
    //    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
    //    initWithString:title11];
    //    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //    [paragraphStyle setLineSpacing:10];
    //    [attributedString addAttribute:NSParagraphStyleAttributeName
    //                             value:paragraphStyle
    //                             range:NSMakeRange (0, [title11 length])];
    //    label1.attributedText = attributedString;
    [self.view addSubview:label1];

    NSString *title12 = I18N (@"PrivacyText2");
    UILabel *label2 = [[UILabel alloc] init];
    //    label2.backgroundColor = [UIColor blueColor];
    label2.text = title12;
    label2.textColor = [UIColor colorWithHexString:@"#000000"];
    label2.font = [UIFont systemFontOfSize:pixelToFontsize (58)];
    label2.frame =
    CGRectMake (FITWIDTH (44), label1.bottomY + FITHEIGHT (100), kScreenW - FITWIDTH (88),
                [CTWBViewTools fitHeightToView:label2 width:kScreenW - FITWIDTH (88)]);
    label2.numberOfLines = 0;
    [self.view addSubview:label2];
}

//返回按钮点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
