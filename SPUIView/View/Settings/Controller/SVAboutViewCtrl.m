//
//  SVAboutViewCtrl.m
//  SPUIView
//
//  Created by XYB on 16/2/16.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVAboutViewCtrl.h"
#import "SVAppVersionChecker.h"

@interface SVAboutViewCtrl ()
@end

@implementation SVAboutViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];

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
#pragma mark - 创建UI
- (void)createUI
{
    //添加logoimage
    UIImageView *imageView = [[UIImageView alloc]
    initWithFrame:CGRectMake (0, StatusBarH + NavBarH + FITHEIGHT (70), FITWIDTH (489), FITHEIGHT (83))];
    imageView.centerX = self.view.centerX;
    imageView.image = [UIImage imageNamed:@"aboutLogo489"];
    [self.view addSubview:imageView];
    //添加LabV0.0.1版本号
    UILabel *labV = [[UILabel alloc]
    initWithFrame:CGRectMake (0, imageView.bottomY + FITHEIGHT (30), kScreenW, FITHEIGHT (120))];
    labV.centerX = self.view.centerX;
    labV.text = [SVAppVersionChecker currentVersion];
    labV.textAlignment = NSTextAlignmentCenter;
    labV.textColor = [UIColor colorWithHexString:@"#000000"];
    labV.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    labV.alpha = 0.7;
    [self.view addSubview:labV];
    //添加二维码背景view
    UIView *whiteView = [[UIView alloc]
    initWithFrame:CGRectMake (0, StatusBarH + NavBarH + FITHEIGHT (306), kScreenW, FITHEIGHT (926))];
    whiteView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [self.view addSubview:whiteView];
    //添加二维码图片
    UIImageView *imageViewQR =
    [[UIImageView alloc] initWithFrame:CGRectMake (0, 0, FITWIDTH (666), FITWIDTH (666))];
    imageViewQR.centerX = self.view.centerX;
    imageViewQR.centerY = whiteView.centerY;
    imageViewQR.image = [UIImage imageNamed:@"SpeedPro666"];
    [self.view addSubview:imageViewQR];
    //添加扫一扫文字
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake (0, 0, kScreenW, FITHEIGHT (100))];
    lable.centerX = self.view.centerX;
    lable.bottomY = whiteView.bottomY;
    lable.text = I18N (@"Sweep, Download SpeedPro");
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor colorWithHexString:@"#000000"];
    lable.font = [UIFont systemFontOfSize:pixelToFontsize (48)];
    lable.alpha = 0.8;
    [self.view addSubview:lable];
    //添加公司信息lableCopy
    UILabel *lableCopy1 = [[UILabel alloc]
    initWithFrame:CGRectMake (0, whiteView.bottomY + FITHEIGHT (93), kScreenW, FITHEIGHT (80))];
    lableCopy1.centerX = self.view.centerX;
    lableCopy1.text = @"Copyright @ Huawei Software Technologies Co.,Ltd. 2014-2016.";
    lableCopy1.textAlignment = NSTextAlignmentCenter;
    lableCopy1.textColor = [UIColor colorWithHexString:@"#000000"];
    lableCopy1.font = [UIFont systemFontOfSize:pixelToFontsize (30)];
    lableCopy1.alpha = 0.6;
    [self.view addSubview:lableCopy1];
    UILabel *lableCopy2 =
    [[UILabel alloc] initWithFrame:CGRectMake (0, lableCopy1.bottomY, kScreenW, FITHEIGHT (80))];
    lableCopy2.centerX = self.view.centerX;
    lableCopy2.text = @"All rights reserved.";
    lableCopy2.textAlignment = NSTextAlignmentCenter;
    lableCopy2.textColor = [UIColor colorWithHexString:@"#000000"];
    lableCopy2.font = [UIFont systemFontOfSize:pixelToFontsize (30)];
    lableCopy2.alpha = 0.6;
    [self.view addSubview:lableCopy2];
}
//返回按钮点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
