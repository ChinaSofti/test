//
//  SVBWSettingViewCtrl.m
//  SPUIView
//
//  Created by XYB on 16/2/16.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#define BUTTON_TAG 30

#import "SVBWSettingViewCtrl.h"
#import <SPCommon/SVI18N.h>
#import <SPService/SVAdvancedSetting.h>

@interface SVBWSettingViewCtrl ()

@property (nonatomic, strong) UIView *imageView;


@end

@implementation SVBWSettingViewCtrl
{
    UITextField *_textField;
    int _bandwidthTypeIndex;
    NSMutableArray *bandwidthTypeButtonArray;
}


- (UIView *)imageView
{
    if (_imageView == nil)
    {
        _imageView = [[UIView alloc] init];
        _imageView.layer.borderWidth = 1;
        _imageView.layer.borderColor =
        [[UIColor colorWithRed:61 / 255.0 green:173 / 255.0 blue:231 / 255.0 alpha:1] CGColor];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 8;
    }
    return _imageView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
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
    NSString *title1 = I18N (@"Type");
    NSString *title2 = I18N (@"unknown");
    NSString *title3 = I18N (@"Fiber");
    NSString *title4 = I18N (@"Copper");
    NSString *title5 = I18N (@"Package");
    NSString *title7 = I18N (@"Carrier");
    //    NSString *title8 = I18N (@"China Unicom Beijing");
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSString *title8 = probeInfo.isp;
    NSString *title9 = I18N (@"Save");


    // views
    UIView *views = [[UIView alloc] init];
    views.frame = CGRectMake (10, 74, kScreenW - 20, 180);
    views.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:views];

    // lableBWType
    UILabel *lableBWType = [[UILabel alloc] init];
    lableBWType.frame = CGRectMake (10, 10, 200, 20);
    lableBWType.text = title1;
    lableBWType.font = [UIFont systemFontOfSize:14];
    [views addSubview:lableBWType];

    SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];
    NSString *type = [setting getBandwidthType];
    int bandwidthTypeIndex = [type intValue];

    bandwidthTypeButtonArray = [[NSMutableArray alloc] init];
    //三个button
    NSArray *titleArr = @[title2, title3, title4];
    UIButton *selectedButton = nil;
    for (int i = 0; i < 3; i++)
    {
        UIButton *button = [[UIButton alloc] init];
        [bandwidthTypeButtonArray addObject:button];
        button.frame = CGRectMake (50 + i * (50 + 20), 35, 60, 30);
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        // button普通状态下的字体颜色
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        // button选中状态下的字体颜色
        [button
        setTitleColor:[UIColor colorWithRed:61 / 255.0 green:173 / 255.0 blue:231 / 255.0 alpha:1]
             forState:UIControlStateSelected | UIControlStateHighlighted];
        [button
        setTitleColor:[UIColor colorWithRed:61 / 255.0 green:173 / 255.0 blue:231 / 255.0 alpha:1]
             forState:UIControlStateSelected];

        button.titleLabel.font = [UIFont systemFontOfSize:12];

        [button addTarget:self
                   action:@selector (buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        button.tag = BUTTON_TAG + i;
        [views addSubview:button];
        //设置初始默认选择按钮
        NSLog (@"%d  %d", i, bandwidthTypeIndex);
        if (!bandwidthTypeIndex && i == 0)
        {
            selectedButton = button;
        }

        if (bandwidthTypeIndex && bandwidthTypeIndex == i)
        {
            selectedButton = button;
        }
    }

    [self buttonClicked:selectedButton];

    // lableBWPackage
    UILabel *lableBWPackage = [[UILabel alloc] init];
    lableBWPackage.frame = CGRectMake (10, 70, 100, 20);
    lableBWPackage.text = title5;
    lableBWPackage.font = [UIFont systemFontOfSize:14];
    [views addSubview:lableBWPackage];

    _textField = [[UITextField alloc] init];
    _textField.frame = CGRectMake (10, 90, kScreenW - 40, 20);
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.text = [setting getBandwidth];
    _textField.placeholder = @"Please input bandwidth";
    _textField.font = [UIFont systemFontOfSize:14];
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    [views addSubview:_textField];

    UILabel *M = [[UILabel alloc] initWithFrame:CGRectMake (FITWIDTH (280), 90, 20, 20)];
    M.font = [UIFont systemFontOfSize:14];
    M.text = @"M";
    [views addSubview:M];

    // lableCarrier
    UILabel *lableCarrier = [[UILabel alloc] init];
    lableCarrier.frame = CGRectMake (10, 130, 100, 20);
    lableCarrier.text = title7;
    lableCarrier.font = [UIFont systemFontOfSize:14];
    [views addSubview:lableCarrier];

    UILabel *lableCarriers = [[UILabel alloc] init];
    lableCarriers.frame = CGRectMake (10, 160, 150, 20);
    lableCarriers.text = title8;
    lableCarriers.font = [UIFont systemFontOfSize:14];
    [views addSubview:lableCarriers];


    //添加保存按钮
    //保存按钮高度
    CGFloat saveBtnH = 44;
    //保存按钮类型
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //保存按钮尺寸
    saveBtn.frame = CGRectMake (saveBtnH, kScreenH - saveBtnH * 2, kScreenW - saveBtnH * 2, saveBtnH);
    //保存按钮背景颜色
    saveBtn.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    //保存按钮文字和颜色
    [saveBtn setTitle:title9 forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置居中
    saveBtn.titleLabel.textAlignment = NSTextAlignmentCenter;

    //保存按钮点击事件
    [saveBtn addTarget:self
                action:@selector (saveBtnClicked:)
      forControlEvents:UIControlEventTouchUpInside];

    //保存按钮圆角
    saveBtn.layer.cornerRadius = 5;

    //保存按钮交互
    saveBtn.userInteractionEnabled = YES;

    [self.view addSubview:saveBtn];
}
- (void)buttonClicked:(UIButton *)button
{
    for (UIButton *bb in bandwidthTypeButtonArray)
    {
        bb.selected = NO;
    }

    button.selected = YES;

    switch (button.tag - BUTTON_TAG)
    {
    case 0:
        //跟随系统
        NSLog (@"未知");

        self.imageView.frame = CGRectMake (60, 110, 60, 30);

        [self.imageView removeFromSuperview];
        [self.view addSubview:self.imageView];
        _bandwidthTypeIndex = 0;
        break;
    case 1:
        //简体中文
        NSLog (@"光纤");
        self.imageView.frame = CGRectMake (130, 110, 60, 30);

        [self.imageView removeFromSuperview];
        [self.view addSubview:self.imageView];
        _bandwidthTypeIndex = 1;
        break;
    case 2:
        // English
        NSLog (@"铜线");
        self.imageView.frame = CGRectMake (200, 110, 60, 30);

        [self.imageView removeFromSuperview];
        [self.view addSubview:self.imageView];
        _bandwidthTypeIndex = 2;
        break;

    default:
        break;
    }
}
//保存按钮
- (void)saveBtnClicked:(UIButton *)button
{
    NSLog (@"带宽设置--保存");
    if (_textField.text)
    {
        NSLog (@"%@", _textField.text);
        SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];
        [setting setBandwidth:_textField.text];
    }

    if (_bandwidthTypeIndex > 0)
    {
        NSLog (@"%d", _bandwidthTypeIndex);
        SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];
        [setting setBandwidthType:[NSString stringWithFormat:@"%d", _bandwidthTypeIndex]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
