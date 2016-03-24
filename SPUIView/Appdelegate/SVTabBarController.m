//
//  SVTabBarController.m
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
#import <SPCommon/SVLog.h>
#import <SPCommon/SVSystemUtil.h>


@interface SVTabBarController () <AlertViewDelegate>

@property (nonatomic, strong) AlertView *alertView;

@end

@implementation SVTabBarController

{
    UIImageView *imageView;
    UIProgressView *progressView;
    NSTimer *progressTimer;
    float progressVlaue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SVInfo (@"SVTabbarController");
    NSString *title1 = I18N (@"Test");
    NSString *title2 = I18N (@"Results");
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

    // 设置启动图片
    UIImage *image = [UIImage imageNamed:@"starting_window"];
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:imageView];

    // 设置进度条
    CGRect rect = [UIScreen mainScreen].bounds;
    progressView = [[UIProgressView alloc]
    initWithFrame:CGRectMake (rect.size.width * 0.1, rect.size.height / 2, rect.size.width * 0.8, 10)];

    [progressView setProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:progressView];

    // 启动计算下载速度的定时器，当前时间100ms后，每隔1s执行一次
    progressVlaue = 0.0;
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                     target:self
                                                   selector:@selector (changeProgress)
                                                   userInfo:@"Progress"
                                                    repeats:YES];
}

// 改变进度条进度
- (void)changeProgress
{
    // 进度值为1，说明进度条已经满了
    if (progressVlaue >= 1)
    {
        // 取消定时器
        [progressTimer invalidate];
        progressTimer = nil;

        // 去掉进度条和启动图片
        [progressView removeFromSuperview];
        [imageView removeFromSuperview];

        // 显示主页面
        [self setShadowView];
        return;
    }

    // 根据测试数据是否加载完成来显示进度条的进度，当进度条走到80%时，会一直等待知道加载完成
    SVTestContextGetter *contextGetter = [SVTestContextGetter sharedInstance];
    if (![contextGetter isInitSuccess])
    {
        progressVlaue += 0.05;
        [progressView setProgress:progressVlaue];
    }
    else
    {
        progressVlaue = 1;
        [progressView setProgress:progressVlaue];
    }
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
        SVInfo (@"未知");
        break;
    case 1 + 10086:
        SVInfo (@"光纤");
        break;
    case 2 + 10086:
        SVInfo (@"铜线");
        break;
    default:
        break;
    }
}
//代理方法-忽略
- (void)alertView:(AlertView *)alertView overLookBtnClick:(UIButton *)Btn
{
    SVInfo (@"忽略");
    UIView *shadowView = [[[Btn superview] superview] superview];
    [shadowView removeFromSuperview];
    alertView = nil;
}
//代理方法-保存
- (void)alertView:(AlertView *)alertView saveBtnClick:(UIButton *)Btn
{
    SVInfo (@"保存");
    UIView *shadowView = [[[Btn superview] superview] superview];
    [shadowView removeFromSuperview];
    alertView = nil;
}
/**
 ******************************以上弹框代码结束*****************************************
 **/

@end
