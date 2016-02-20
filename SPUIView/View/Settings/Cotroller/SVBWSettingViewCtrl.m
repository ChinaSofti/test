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

@interface SVBWSettingViewCtrl ()

@property (strong, nonatomic) UIButton *button;
@property (nonatomic, strong) UIView *imageView;


@end

@implementation SVBWSettingViewCtrl

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
    NSString *title1 = I18N (@"Bandwidth Settings");
    NSString *title2 = I18N (@"unknown");
    NSString *title3 = I18N (@"Fiber");
    NSString *title4 = I18N (@"Copper");
    NSString *title5 = I18N (@"Package");
    NSString *title7 = I18N (@"Carrier");
    NSString *title8 = I18N (@"China Unicom Beijing");
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

    //三个button
    NSArray *titleArr = @[title2, title3, title4];
    for (int i = 0; i < 3; i++)
    {
        _button = [[UIButton alloc] init];
        _button.frame = CGRectMake (50 + i * (50 + 20), 35, 60, 30);
        [_button setTitle:titleArr[i] forState:UIControlStateNormal];
        // button普通状态下的字体颜色
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        // button选中状态下的字体颜色
        [_button
        setTitleColor:[UIColor colorWithRed:61 / 255.0 green:173 / 255.0 blue:231 / 255.0 alpha:1]
             forState:UIControlStateSelected | UIControlStateHighlighted];
        [_button
        setTitleColor:[UIColor colorWithRed:61 / 255.0 green:173 / 255.0 blue:231 / 255.0 alpha:1]
             forState:UIControlStateSelected];

        _button.titleLabel.font = [UIFont systemFontOfSize:14];


        //按钮被点击后 按钮外部显示边框
        //            _button.layer.cornerRadius = 2;
        //            _button.layer.borderColor = [UIColor colorWithWhite:200 / 255.0
        //            alpha:0.5].CGColor;
        //            _button.layer.borderWidth = 1;


        [_button addTarget:self
                    action:@selector (buttonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
        _button.tag = BUTTON_TAG + i;
        //设置初始默认选择按钮
        if (_button.tag == 30)
        {
            _button.selected = YES;
            self.imageView.frame = CGRectMake (60, 110, 60, 30);

            [self.imageView removeFromSuperview];
            [self.view addSubview:self.imageView];
        }
        //      _button.selected = NO;
        //   _button.userInteractionEnabled = YES;

        [views addSubview:_button];
    }


    // lableBWPackage
    UILabel *lableBWPackage = [[UILabel alloc] init];
    lableBWPackage.frame = CGRectMake (10, 70, 100, 20);
    lableBWPackage.text = title5;
    lableBWPackage.font = [UIFont systemFontOfSize:14];
    [views addSubview:lableBWPackage];

    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake (10, 90, kScreenW - 40, 20);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.text = @"-1.0";
    textField.placeholder = @"Please input bandwidth";
    textField.font = [UIFont systemFontOfSize:14];
    textField.keyboardType = UIKeyboardTypeDefault;

    [views addSubview:textField];


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
    //  saveBtn.userInteractionEnabled = YES;

    [self.view addSubview:saveBtn];
}
- (void)buttonClicked:(UIButton *)button
{
    if (button != self.button)
    {
        self.button.selected = NO;
        self.button = button;
    }

    self.button.selected = YES;

    switch (button.tag - BUTTON_TAG)
    {
    case 0:
        //跟随系统
        NSLog (@"未知");

        self.imageView.frame = CGRectMake (60, 110, 60, 30);

        [self.imageView removeFromSuperview];
        [self.view addSubview:self.imageView];

        break;
    case 1:
        //简体中文
        NSLog (@"光纤");
        self.imageView.frame = CGRectMake (130, 110, 60, 30);

        [self.imageView removeFromSuperview];
        [self.view addSubview:self.imageView];

        break;
    case 2:
        // English
        NSLog (@"铜线");
        self.imageView.frame = CGRectMake (200, 110, 60, 30);

        [self.imageView removeFromSuperview];
        [self.view addSubview:self.imageView];

        break;

    default:
        break;
    }
}
//保存按钮
- (void)saveBtnClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
    NSLog (@"带宽设置--保存");
}

@end
