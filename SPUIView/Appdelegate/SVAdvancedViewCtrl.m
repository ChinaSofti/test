//
//  SVAdvancedViewCtrl.m
//  SPUIView
//
//  Created by XYB on 16/2/16.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVAdvancedViewCtrl.h"
#import <SPService/SVAdvancedSetting.h>

@interface SVAdvancedViewCtrl ()

@end

@implementation SVAdvancedViewCtrl {
  UITextField *_textField;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];

  //设置LeftBarButtonItem
  [self createLeftBarButtonItem];

  [self createUI];
}

//进去时 隐藏tabBar
- (void)viewWillAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabBar"
                                                      object:nil];
}
//出来时 显示tabBar
- (void)viewWillDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabBar"
                                                      object:nil];
}

- (void)createLeftBarButtonItem {
  UIButton *leftBack =
      [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 25)];
  [leftBack setBackgroundImage:[UIImage imageNamed:@"homeindicator"]
                      forState:UIControlStateNormal];
  [leftBack addTarget:self
                action:@selector(leftBackButtonClick)
      forControlEvents:UIControlEventTouchUpInside];

  self.navigationItem.leftBarButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:leftBack];
}

- (void)leftBackButtonClick {
  SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];
  [setting setScreenSize:[_textField.text floatValue]];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI {
  //屏幕尺寸
  UILabel *lableScreenSize = [[UILabel alloc] init];
  lableScreenSize.frame = CGRectMake(10, 84, 70, 20);
  lableScreenSize.text = @"屏幕尺寸：";
  lableScreenSize.font = [UIFont systemFontOfSize:14];
  [self.view addSubview:lableScreenSize];

  SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];

  //文本框
  _textField = [[UITextField alloc] init];
  _textField.frame = CGRectMake(85, 84, kScreenW - 84 - 30, 20);
  _textField.text = setting.getScreenSize;
  _textField.placeholder = @"请输入13英寸~100英寸的数字";
  _textField.font = [UIFont systemFontOfSize:14];
  [self.view addSubview:_textField];

  //文本框下的细线
  UIView *viewLine = [[UIView alloc] init];
  viewLine.frame = CGRectMake(80, 104, kScreenW - 84 - 30, 1);
  viewLine.backgroundColor = [UIColor grayColor];
  [self.view addSubview:viewLine];

  //英寸
  UILabel *lableInch = [[UILabel alloc] init];
  lableInch.frame = CGRectMake(kScreenW - 30, 84, 30, 20);
  lableInch.text = @"英寸";
  lableInch.font = [UIFont systemFontOfSize:14];
  [self.view addSubview:lableInch];
}

@end
