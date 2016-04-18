//
//  SVPrivacyCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/4/14.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVPrivacyCtrl.h"
#import <WebKit/WebKit.h>

@interface SVPrivacyCtrl ()
@end

@implementation SVPrivacyCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];

    //    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];

    // 初始化返回按钮
    [super initBackButtonWithTarget:self action:@selector (backButtonClick)];

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];


    //调用逻辑

    NSString *htmlPath = [NSString stringWithFormat:@"file://%@", [self getHtmlPath]];
    SVInfo (@"load Privacy html from resource directory. URL:%@", htmlPath);
    NSURL *fileURL = [NSURL URLWithString:htmlPath];

    if (fileURL)
    {
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
        {
            // iOS9. One year later things are OK.
            [webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        }
        else
        {
            // iOS8. Things can be workaround-ed
            //   Brave people can do just this
            //   fileURL = try! pathForBuggyWKWebView8(fileURL)
            //   webView.loadRequest(NSURLRequest(URL: fileURL))
            NSURL *url = [self fileURLForBuggyWKWebView8:fileURL];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
        }
    }
    [webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];

    [self.view addSubview:webView];
    //    [self createUI];
}

//将文件copy到tmp目录
- (NSURL *)fileURLForBuggyWKWebView8:(NSURL *)fileURL
{
    NSError *error = nil;
    if (!fileURL.fileURL || ![fileURL checkResourceIsReachableAndReturnError:&error])
    {
        return nil;
    }
    // Create "/temp/www" directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory ()] URLByAppendingPathComponent:@"www"];
    [fileManager createDirectoryAtURL:temDirURL
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];

    NSURL *dstURL = [temDirURL URLByAppendingPathComponent:fileURL.lastPathComponent];
    // Now copy given file to the temp directory
    [fileManager removeItemAtURL:dstURL error:&error];
    [fileManager copyItemAtURL:fileURL toURL:dstURL error:&error];
    // Files in "/temp/www" load flawlesly :)
    return dstURL;
}

- (NSString *)getHtmlPath
{
    // 资源目录
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirArray = [fileManager subpathsAtPath:resourcePath];
    SVI18N *i18n = [SVI18N sharedInstance];
    NSString *language = [i18n getLanguage];

    NSString *playerHtmlPath;
    for (NSString *path in dirArray)
    {
        if ([path containsString:@"html"])
        {
            NSLog (@"%@", path);
        }
        if ([language containsString:@"en"] && [path containsString:@"Privacy_en.html"])
        {
            playerHtmlPath = [resourcePath stringByAppendingPathComponent:path];
            break;
        }
        else if ([language containsString:@"zh"] && [path containsString:@"Privacy_cn.html"])
        {
            playerHtmlPath = [resourcePath stringByAppendingPathComponent:path];
            break;
        }
    }

    return playerHtmlPath;
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
    label1.textColor = [UIColor colorWithHexString:@"#4C000000"];
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
    label2.textColor = [UIColor colorWithHexString:@"#4C000000"];
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
