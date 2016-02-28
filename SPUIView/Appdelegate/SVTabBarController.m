//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "AlertView.h"
#import "SVResultViewCtrl.h"
#import "SVSettingsViewCtrl.h"
#import "SVTabBarController.h"
#import "SVTestViewCtrl.h"
#import <SPCommon/SVI18N.h>
#import <SPCommon/SVSystemUtil.h>
#import <SPService/SVAdvancedSetting.h>

@interface SVTabBarController () <AlertViewDelegate>

@property (nonatomic, strong) AlertView *alertView;

@end

@implementation SVTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog (@"SVTabbarController");
    NSString *title1 = I18N (@"Testing");
    NSString *title2 = I18N (@"Result");
    NSString *title3 = I18N (@"Settings");

    //测试
    SVTestViewCtrl *testCtrl = [SVTestViewCtrl new];
    [self addChildViewController:testCtrl imageName:@"tabbar_test" title:title1];
    //结果
    SVResultViewCtrl *resultCtrl = [SVResultViewCtrl new];
    [self addChildViewController:resultCtrl imageName:@"tabbar_result" title:title2];
    //设置
    SVSettingsViewCtrl *settingsCtrl = [SVSettingsViewCtrl new];
    [self addChildViewController:settingsCtrl imageName:@"tabbar_settings" title:title3];
    //添加通知的监听
    [self addNotificataion];
}
- (void)addNotificataion
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (hideTabBar)
                                                 name:@"HideTabBar"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (showTabBar)
                                                 name:@"ShowTabBar"
                                               object:nil];
}
- (void)showTabBar
{
    self.tabBar.hidden = NO;
}

- (void)hideTabBar
{
    self.tabBar.hidden = YES;
}


//添加子控制器,设置标题与图片
- (void)addChildViewController:(UIViewController *)childCtrl
                     imageName:(NSString *)imageName
                         title:(NSString *)title
{
    //设置选中与未选中的图片-->指定一下渲染模式-->图片以原样的方式显示出来
    childCtrl.tabBarItem.image =
    [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childCtrl.tabBarItem.selectedImage =
    [[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", imageName]]
    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //设置标题
    //    childCtrl.tabBarItem.title = title;
    //    childCtrl.navigationItem.title = title;
    childCtrl.title = title;
    //指定一下属性
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSForegroundColorAttributeName] = [UIColor orangeColor];
    //指定字体
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    //指定选中状态下文字颜色
    [childCtrl.tabBarItem setTitleTextAttributes:@{
        NSForegroundColorAttributeName:
        [UIColor colorWithRed:29 / 255.0 green:145 / 255.0 blue:226 / 255.0 alpha:1.0]
    }
                                        forState:UIControlStateSelected];

    //用UINavigationController包裹controller
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:childCtrl];
    //添加控制器
    [self addChildViewController:navCtrl];

    //    [[UITableView appearance] setBackgroundColor:[UIColor whiteColor]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  **************************以下代码都是弹框页代码************************************
 */
//生命周期(当屏幕出现时就创建)
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    BOOL isConnectionAvailable = [SVSystemUtil isConnectionAvailable];
    if (isConnectionAvailable)
    {
        SVAdvancedSetting *setting = [SVAdvancedSetting sharedInstance];
        if (![setting getBandwidth])
        {
            [self setShadowView];
        }
    }
}
/**
 *  创建阴影背景
 */

//代理方法
- (void)setShadowView
{
    //添加动画
    [UIView
    animateWithDuration:0.01
             animations:^{
               //黑色透明阴影
               UIView *shadowView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
               shadowView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];

               if (!_alertView)
               {
                   _alertView = [[AlertView alloc]
                   initWithFrame:CGRectMake (FITWIDTH (20), FITWIDTH (183),
                                             shadowView.frame.size.width - FITWIDTH (40), FITWIDTH (220))
                         bgColor:[UIColor whiteColor]];

                   _alertView.delegate = self;
               }

               [shadowView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                        action:@selector (dismissTextField:)]];

               [shadowView addSubview:_alertView];

               [self.view.window addSubview:shadowView];
             }];
}
//取消键盘
- (void)dismissTextField:(UIGestureRecognizer *)tap
{
    UIView *view = tap.view;
    [view endEditing:YES];
}

//代理方法-宽带类型
- (void)alertView:(AlertView *)alertView didClickBtn:(NSInteger)index
{
    switch (index)
    {
    case 0 + 10086:
        NSLog (@"未知");
        break;
    case 1 + 10086:
        NSLog (@"光纤");
        break;
    case 2 + 10086:
        NSLog (@"铜线");
        break;
    default:
        break;
    }
}
//代理方法-忽略
- (void)alertView:(AlertView *)alertView overLookBtnClick:(UIButton *)Btn
{
    NSLog (@"忽略");
    UIView *shadowView = [[[Btn superview] superview] superview];
    [shadowView removeFromSuperview];
    alertView = nil;
}
//代理方法-保存
- (void)alertView:(AlertView *)alertView saveBtnClick:(UIButton *)Btn
{
    NSLog (@"保存");
    UIView *shadowView = [[[Btn superview] superview] superview];
    [shadowView removeFromSuperview];
    alertView = nil;
}
/**
 ******************************以上弹框代码结束*****************************************
 **/

@end
