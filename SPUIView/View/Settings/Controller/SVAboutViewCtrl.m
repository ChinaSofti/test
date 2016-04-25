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
    //添加imageView
    UIImageView *imageView =
    [[UIImageView alloc] initWithFrame:CGRectMake (0, 0, FITHEIGHT (230), FITHEIGHT (230))];
    imageView.image = [UIImage imageNamed:@"icon"];
    //创建手势添加的View
    UIView *view = [[UIView alloc]
    initWithFrame:CGRectMake (FITWIDTH (115), FITHEIGHT (290), FITWIDTH (230), FITHEIGHT (230))];
    //    view.backgroundColor = [UIColor redColor];
    [view addSubview:imageView];
    [self.view addSubview:view];
    //添加手势
    //单击
    UITapGestureRecognizer *singTap = [[UITapGestureRecognizer alloc] init];
    [singTap addTarget:self action:@selector (handleSingTap)];
    [singTap setNumberOfTapsRequired:1];
    [view addGestureRecognizer:singTap];
    //双击
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] init];
    [doubleTap addTarget:self action:@selector (handleDoubleTap)];
    [doubleTap setNumberOfTapsRequired:2];
    [view addGestureRecognizer:doubleTap];
    //区分单双击
    [singTap requireGestureRecognizerToFail:doubleTap];

    //添加LabSpeedPro
    UILabel *labSpeedPro =
    [[UILabel alloc] initWithFrame:CGRectMake (CGRectGetMaxX (view.frame) + FITWIDTH (58),
                                               view.frame.origin.y, FITWIDTH (348), FITHEIGHT (126))];
    labSpeedPro.text = @"SpeedPro";
    labSpeedPro.textColor = [UIColor blackColor];
    labSpeedPro.font = [UIFont systemFontOfSize:pixelToFontsize (80)];
    [self.view addSubview:labSpeedPro];

    //添加LabV0.0.1
    UILabel *labV = [[UILabel alloc]
    initWithFrame:CGRectMake (CGRectGetMaxX (view.frame) + FITWIDTH (58),
                              view.frame.origin.y + FITHEIGHT (129), FITWIDTH (348), FITHEIGHT (126))];
    labV.text = [SVAppVersionChecker currentVersion];
    labV.textColor = [UIColor grayColor];
    labV.font = [UIFont systemFontOfSize:pixelToFontsize (60)];
    [self.view addSubview:labV];

    //添加ViewLine
    UIView *viewLine = [[UIImageView alloc]
    initWithFrame:CGRectMake (FITWIDTH (115), FITHEIGHT (580), kScreenW - FITWIDTH (230), FITHEIGHT (3))];
    viewLine.backgroundColor = [UIColor grayColor];
    viewLine.alpha = 0.2;
    [self.view addSubview:viewLine];

    //添加LabCopyright
    UILabel *labCopyright = [[UILabel alloc]
    initWithFrame:CGRectMake (viewLine.frame.origin.x, viewLine.frame.origin.y + FITHEIGHT (58),
                              FITWIDTH (930), FITHEIGHT (126))];
    labCopyright.text = @"Copyright @ Huawei Software Technologies Co.,";
    labCopyright.textColor = [UIColor grayColor];
    //    labCopyright.backgroundColor = [UIColor redColor];
    labCopyright.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    [self.view addSubview:labCopyright];

    //添加LabLtd
    UILabel *labLtd = [[UILabel alloc]
    initWithFrame:CGRectMake (labCopyright.frame.origin.x, labCopyright.frame.origin.y + FITHEIGHT (58),
                              kScreenW - FITWIDTH (230), FITHEIGHT (126))];
    labLtd.text = @"Ltd. 2014-2016.";
    labLtd.textColor = [UIColor grayColor];
    labLtd.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    [self.view addSubview:labLtd];

    //添加LabAllRights
    UILabel *labAllRights = [[UILabel alloc]
    initWithFrame:CGRectMake (labLtd.frame.origin.x, labLtd.frame.origin.y + FITHEIGHT (58),
                              kScreenW - FITWIDTH (230), FITHEIGHT (126))];
    labAllRights.text = @"All rights reserved.";
    labAllRights.textColor = [UIColor grayColor];
    labAllRights.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    [self.view addSubview:labAllRights];
}
#pragma mark - 点击事件
/**
 *  单击事件
 */
- (void)handleSingTap
{
    SVInfo (@"单击了");
}
/**
 *  双击事件
 */
- (void)handleDoubleTap
{
    SVInfo (@"双击了");
}
//返回按钮点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
