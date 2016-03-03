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
#import <SPCommon/SVLog.h>
#import <SPService/SVAdvancedSetting.h>

@interface SVLanguageSettingViewCtrl ()

@property (nonatomic, strong) UIImageView *imageView;
@end

static int userLanguageIndex;

@implementation SVLanguageSettingViewCtrl
{
    UIButton *_saveBtn;
}

- (UIImageView *)imageView
{
    if (_imageView == nil)
    {
        _imageView = [[UIImageView alloc] init];
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
    // views
    UIView *views = [[UIView alloc] init];
    views.frame = CGRectMake (10, 74, kScreenW - 20, 131);
    views.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:views];

    SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];
    int languageIndex = [setting getLanguageIndex];
    NSString *title1 = I18N (@"Auto      ");
    NSString *title2 = I18N (@"Save");
    NSMutableArray *languageButtonArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i++)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (10, 74 + i * 43, kScreenW - 20, 44)];
        [button setTitle:titlesArr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.titleEdgeInsets = UIEdgeInsetsMake (0, -(kScreenW + 120) / 2, 0, 0);
        button.titleLabel.textAlignment = NSTextAlignmentLeft;
        button.layer.cornerRadius = 2;
        button.layer.borderColor = [UIColor colorWithWhite:200 / 255.0 alpha:0.5].CGColor;
        button.layer.borderWidth = 1;
        button.tag = Button_Tag + i;
        [button addTarget:self
                   action:@selector (buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [languageButtonArray addObject:button];
        if (i == languageIndex)
        {
            [self buttonClicked:button];
        }
    }

    //保存按钮高度
    CGFloat saveBtnH = 44;
    //保存按钮类型
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //保存按钮尺寸
    _saveBtn.frame = CGRectMake (saveBtnH, kScreenH - saveBtnH * 2, kScreenW - saveBtnH * 2, saveBtnH);
    //保存按钮背景颜色
    _saveBtn.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    //保存按钮文字和颜色
    [_saveBtn setTitle:title2 forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置居中
    _saveBtn.titleLabel.textAlignment = NSTextAlignmentCenter;

    //保存按钮点击事件
    [_saveBtn addTarget:self
                 action:@selector (saveBtnClicked:)
       forControlEvents:UIControlEventTouchUpInside];

    //保存按钮圆角
    _saveBtn.layer.cornerRadius = 5;

    [self.view addSubview:_saveBtn];
}

/**
 *  保存按钮
 *
 *  @param button 保存按钮
 */
- (void)buttonClicked:(UIButton *)button
{
    //按钮被点击后 右侧显示语言被选中
    UIImage *image = [UIImage imageNamed:@"ic_language_select"];
    self.imageView.frame = CGRectMake (kScreenW - 60, 17, 15, 10);
    self.imageView.image = image;

    switch (button.tag - Button_Tag)
    {
    case 0:
        //跟随系统
        SVInfo (@"跟随系统");
        userLanguageIndex = 0;
        break;
    case 1:
        //简体中文
        SVInfo (@"简体中文");
        userLanguageIndex = 1;
        break;
    case 2:
        // English
        SVInfo (@"English");
        userLanguageIndex = 2;
        break;

    default:
        break;
    }
    [button addSubview:self.imageView];
}

/**
 *  保存按钮
 *
 *  @param button 保存按钮
 */
- (void)saveBtnClicked:(UIButton *)button
{
    //弹出Alart让用户选择是否进行语言切换
    NSString *title1 = I18N (@"");
    NSString *title2 = I18N (@"The language switch will exit the application, restart after the "
                             @"entry into force, continue?");
    NSString *title3 = I18N (@"Return");
    NSString *title4 = I18N (@"Continue");

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title1
                                                    message:title2
                                                   delegate:self
                                          cancelButtonTitle:title3
                                          otherButtonTitles:title4, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //确定
    if (buttonIndex == 1)
    {
        //语言更换
        SVI18N *i18n = [SVI18N sharedInstance];
        switch (userLanguageIndex)
        {
        case 0:
            [i18n setLanguage:[SVI18N getSystemLanguage]];
            break;
        case 1:
            [i18n setLanguage:@"zh"];
            break;
        case 2:
            [i18n setLanguage:@"en"];
            break;
        default:
            break;
        }

        SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];
        [setting setLanguageIndex:userLanguageIndex];

        SVInfo (@"%@", @"按钮被点击了");
        //退出程序
        [self exitApplication];
    }
}


//退出程序方法
- (void)exitApplication
{

    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector (animationFinished:finished:context:)];
    [UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID
                 finished:(NSNumber *)finished
                  context:(void *)context
{

    if ([animationID compare:@"exitApplication"] == 0)
    {
        exit (0);
    }
}
@end
