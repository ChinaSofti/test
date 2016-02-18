//
//  SVLanguageSettingViewCtrl.m
//  SPUIView
//
//  Created by XYB on 16/2/16.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#define Button_Tag 20

#import "SVLanguageSettingViewCtrl.h"
#import <SPCommon/SVI18N.h>

@interface SVLanguageSettingViewCtrl ()

@property(nonatomic, strong) UIImageView *imageView;

@end

@implementation SVLanguageSettingViewCtrl {
  int _seletedIndex;
}

- (UIImageView *)imageView {
  if (_imageView == nil) {
    _imageView = [[UIImageView alloc] init];
  }
  return _imageView;
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
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI {
  NSArray *titlesArr = @[ @"跟随系统", @"简体中文", @"English" ];
  for (int i = 0; i < 3; i++) {
    UIButton *button = [[UIButton alloc]
        initWithFrame:CGRectMake(10, 74 + i * 43, kScreenW - 20, 44)];
    [button setTitle:titlesArr[i] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -(kScreenW + 120) / 2, 0, 0);

    button.layer.cornerRadius = 2;
    button.layer.borderColor =
        [UIColor colorWithWhite:200 / 255.0 alpha:0.5].CGColor;
    button.layer.borderWidth = 1;
    button.tag = Button_Tag + i;
    [button addTarget:self
                  action:@selector(buttonClicked:)
        forControlEvents:UIControlEventTouchUpInside];

    SVI18N *setting = [SVI18N sharedInstance];
    NSString *language = [setting getLanguage];
    if ([language containsString:@"zh"] && button.tag == 21) {
      // 简体中文
      [self buttonClicked:button];
    } else { // 简体中文
      [self buttonClicked:button];
    }

    //设置初始 默认选择位置
    //        if (button.tag == 20)
    //        {
    //            [self buttonClicked:button];
    //        }
    [self.view addSubview:button];
  }

  //保存按钮高度
  CGFloat saveBtnH = 44;
  //保存按钮类型
  UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  //保存按钮尺寸
  saveBtn.frame = CGRectMake(saveBtnH, kScreenH - saveBtnH * 2,
                             kScreenW - saveBtnH * 2, saveBtnH);
  //保存按钮背景颜色
  saveBtn.backgroundColor = [UIColor colorWithRed:51 / 255.0
                                            green:166 / 255.0
                                             blue:226 / 255.0
                                            alpha:1.0];
  //保存按钮文字和颜色
  [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
  [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  //设置居中
  saveBtn.titleLabel.textAlignment = NSTextAlignmentCenter;

  //保存按钮点击事件
  [saveBtn addTarget:self
                action:@selector(saveBtnClicked:)
      forControlEvents:UIControlEventTouchUpInside];

  //保存按钮圆角
  saveBtn.layer.cornerRadius = 5;

  //保存按钮交互
  //  saveBtn.userInteractionEnabled = YES;

  [self.view addSubview:saveBtn];
}
//语言按钮
- (void)buttonClicked:(UIButton *)button {

  //按钮被点击后 右侧显示排序箭头
  UIImage *image = [UIImage imageNamed:@"ic_language_select"];
  self.imageView.frame =
      CGRectMake(kScreenW - 60, button.titleLabel.frame.origin.y + 5, 15, 10);
  self.imageView.image = image;

  switch (button.tag - Button_Tag) {
  case 0:
    //跟随系统
    NSLog(@"跟随系统");

    _seletedIndex = 0;
    break;
  case 1:
    //简体中文
    NSLog(@"简体中文");
    _seletedIndex = 1;

    break;
  case 2:
    // English
    NSLog(@"English");
    _seletedIndex = 2;
    break;

  default:
    break;
  }
  [button addSubview:self.imageView];
}
//保存按钮
- (void)saveBtnClicked:(UIButton *)button {
  [self.navigationController popViewControllerAnimated:YES];
  SVI18N *setting = [SVI18N sharedInstance];
  NSArray *languages = [NSLocale preferredLanguages];
  NSString *language = [languages objectAtIndex:0];
  if (_seletedIndex == 1) {
    language = @"zh";
  } else if (_seletedIndex == 2) {
    language = @"en";
  }

  [setting setLanguage:language];
  NSLog(@"语言设置--保存");
}

@end
