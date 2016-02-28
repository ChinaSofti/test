//
//  SVAdvancedViewCtrl.m
//  SPUIView
//
//  Created by XYB on 16/2/16.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVAdvancedViewCtrl.h"
#import <SPCommon/SVI18N.h>
#import <SPService/SVAdvancedSetting.h>
@interface SVAdvancedViewCtrl ()

@end

@implementation SVAdvancedViewCtrl
{
    UITextField *_textField;
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
    SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];
    [setting setScreenSize:[_textField.text floatValue]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI
{
    NSString *title1 = I18N (@"Screen Size:");
    NSString *title2 = I18N (@"Inch");
    // views
    UIView *views = [[UIView alloc] init];
    views.frame = CGRectMake (10, 74, kScreenW - 20, 44);
    views.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:views];

    //屏幕尺寸
    UILabel *lableScreenSize = [[UILabel alloc] init];
    lableScreenSize.frame = CGRectMake (20, 84, 100, 20);
    lableScreenSize.text = title1;
    lableScreenSize.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:lableScreenSize];

    SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];

    //文本框
    _textField = [[UITextField alloc] init];
    _textField.frame = CGRectMake (110, 84, kScreenW - 84 - 40, 20);
    _textField.text = setting.getScreenSize;
    _textField.placeholder = @"请输入13英寸~100英寸的数字";
    _textField.font = [UIFont systemFontOfSize:14];
    //设置文本框类型
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    //输入键盘类型
    _textField.keyboardType = UIKeyboardTypeDecimalPad;
    [self.view addSubview:_textField];


    //英寸
    UILabel *lableInch = [[UILabel alloc] init];
    lableInch.frame = CGRectMake (kScreenW - 45, 84, 30, 20);
    lableInch.text = title2;
    lableInch.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:lableInch];
}

@end
