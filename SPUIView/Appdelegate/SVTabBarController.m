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
#import "SVTestContextGetter.h"
#import "SVTestViewCtrl.h"


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

    // 测试
    SVTestViewCtrl *testCtrl = [SVTestViewCtrl new];
    [self addChildViewController:testCtrl imageName:@"tabbar_test" title:title1];

    // 结果
    SVResultViewCtrl *resultCtrl = [SVResultViewCtrl new];
    [self addChildViewController:resultCtrl imageName:@"tabbar_result" title:title2];

    // 设置
    SVSettingsViewCtrl *settingsCtrl = [SVSettingsViewCtrl new];
    [self addChildViewController:settingsCtrl imageName:@"tabbar_settings" title:title3];

    // 添加通知的监听
    [self addNotificataion];

    // 设置启动图片
    UIImage *image = [UIImage imageNamed:@"starting_window"];
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:imageView];

    // 设置进度条
    progressView = [[UIProgressView alloc]
    initWithFrame:CGRectMake (FITWIDTH (108), FITHEIGHT (960), FITWIDTH (864), FITHEIGHT (20))];

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

    // 如果网络无法连接，则直接进入
    SVRealReachability *realReachability = [SVRealReachability sharedInstance];
    SVRealReachabilityStatus currentStatus = realReachability.getNetworkStatus;
    if (currentStatus == SV_WWANTypeUnknown || currentStatus == SV_RealStatusNotReachable)
    {
        progressVlaue = 1;
        [progressView setProgress:progressVlaue];
        return;
    }

    // 根据测试数据是否加载完成来显示进度条的进度
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
    // 设置选中与未选中的图片-->指定一下渲染模式-->图片以原样的方式显示出来
    childCtrl.tabBarItem.image =
    [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childCtrl.tabBarItem.selectedImage =
    [[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", imageName]]
    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    // 设置标题
    childCtrl.title = title;

    // 指定未选中时属性
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    // 指定字体颜色
    dic[NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"869095"];

    // 指定字体
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:pixelToFontsize (28)];

    // 指定未选中状态下文字属性
    [childCtrl.tabBarItem setTitleTextAttributes:dic forState:UIControlStateNormal];

    // 指定选中时属性
    NSMutableDictionary *selectedDic = [NSMutableDictionary dictionary];

    // 指定字体颜色
    selectedDic[NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"29A5E5"];

    // 指定字体
    selectedDic[NSFontAttributeName] = [UIFont systemFontOfSize:pixelToFontsize (28)];

    // 指定选中状态下文字属性
    [childCtrl.tabBarItem setTitleTextAttributes:selectedDic forState:UIControlStateSelected];

    // 用UINavigationController包裹controller
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:childCtrl];

    // 设置navigationBar的高度
    CGRect rect = navCtrl.navigationBar.frame;

    // 设置新的高度
    [navCtrl.navigationBar
    setFrame:CGRectMake (rect.origin.x, rect.origin.y, rect.size.width, FITHEIGHT (144))];

    // 添加控制器
    [self addChildViewController:navCtrl];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

// 代理方法
- (void)setShadowView
{
    // 添加动画
    [UIView
    animateWithDuration:0.01
             animations:^{
               // 黑色透明阴影
               UIView *shadowView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
               shadowView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];

               if (!_alertView)
               {
                   _alertView = [[AlertView alloc]
                   initWithFrame:CGRectMake (FITWIDTH (58), FITHEIGHT (527),
                                             shadowView.frame.size.width - FITWIDTH (116), FITHEIGHT (634))
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

// 取消键盘
- (void)dismissTextField:(UIGestureRecognizer *)tap
{
    UIView *view = tap.view;
    [view endEditing:YES];
}

// 代理方法-宽带类型
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
// 代理方法-忽略
- (void)alertView:(AlertView *)alertView overLookBtnClick:(UIButton *)Btn
{
    SVInfo (@"忽略");
    UIView *shadowView = [[[Btn superview] superview] superview];
    [shadowView removeFromSuperview];
    alertView = nil;
}
// 代理方法-保存
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
