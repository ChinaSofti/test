//
//  SVTabBarController.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "AlertView.h"
#import "SVCurrentDevice.h"
#import "SVInitConfig.h"
#import "SVProbeInfo.h"
#import "SVResultViewCtrl.h"
#import "SVSettingsViewCtrl.h"
#import "SVTabBarController.h"
#import "SVTestContextGetter.h"
#import "SVTestViewCtrl.h"
#import "SVWifiInfo.h"


@interface SVTabBarController () <AlertViewDelegate>

@property (nonatomic, strong) AlertView *alertView;

@end

@implementation SVTabBarController

{
    UIView *launchImageView;
    UIProgressView *progressView;
    NSTimer *progressTimer;
    float progressVlaue;
    UILabel *loadingProcessLabelValue;
    UIView *contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SVInfo (@"SVTabbarController");
    NSString *title1 = I18N (@"Test");
    NSString *title2 = I18N (@"Result List");
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
    launchImageView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIImage *image = [UIImage imageNamed:@"starting_window"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = [UIScreen mainScreen].bounds;
    [launchImageView addSubview:imageView];
    [self.view addSubview:launchImageView];

    // 显示进度条
    [self showProgressView];
}

- (void)showProgressView
{
    // --------Content
    contentView = [[UIView alloc]
    initWithFrame:CGRectMake (FITWIDTH (108), FITHEIGHT (860), FITWIDTH (864), FITHEIGHT (100))];
    CGFloat contentViewHeight = contentView.frame.size.height;

    // 加载中文字的label
    NSString *prepareLabelMessage = I18N (@"Prepareing");
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:pixelToFontsize (46)],
    };

    CGRect textRect = [prepareLabelMessage boundingRectWithSize:CGSizeMake (FITWIDTH (864), FITHEIGHT (150))
                                                        options:NSStringDrawingTruncatesLastVisibleLine
                                                     attributes:attributes
                                                        context:nil];

    // 初始化loading图标
    UIActivityIndicatorView *activityView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setColor:[UIColor whiteColor]];

    // 设置loading图标位置
    CGFloat activityViewHeight = activityView.frame.size.height;
    CGFloat activityViewWidth = activityView.frame.size.width;
    CGFloat x = (FITWIDTH (864) - FITWIDTH (180) - activityViewWidth - textRect.size.width) / 2;
    [activityView setOrigin:CGPointMake (x, (contentViewHeight - activityViewHeight) / 2)];

    UILabel *loadingProcessLabel = [[UILabel alloc] init];
    [loadingProcessLabel setSize:CGSizeMake (textRect.size.width, textRect.size.height)];
    [loadingProcessLabel setOrigin:CGPointMake (activityView.rightX + FITWIDTH (30),
                                                (contentViewHeight - textRect.size.height) / 2)];
    [loadingProcessLabel setText:prepareLabelMessage];
    [loadingProcessLabel setTextColor:[UIColor whiteColor]];
    [loadingProcessLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (46)]];

    CGFloat loadingProcessLabelValueWidth = FITWIDTH (150);
    CGFloat loadingProcessLabelValueHeight = FITHEIGHT (80);
    loadingProcessLabelValue = [[UILabel alloc] init];
    [loadingProcessLabelValue setSize:CGSizeMake (loadingProcessLabelValueWidth, loadingProcessLabelValueHeight)];
    [loadingProcessLabelValue
    setOrigin:CGPointMake (loadingProcessLabel.rightX + FITWIDTH (20),
                           (contentViewHeight - loadingProcessLabelValueHeight) / 2)];
    [loadingProcessLabelValue setText:@"0%"];
    [loadingProcessLabelValue setTextColor:[UIColor whiteColor]];
    [loadingProcessLabelValue setFont:[UIFont systemFontOfSize:pixelToFontsize (46)]];

    [contentView addSubview:activityView];
    [contentView addSubview:loadingProcessLabel];
    [contentView addSubview:loadingProcessLabelValue];
    [activityView startAnimating];

    [self.view addSubview:contentView];
    //    [contentView addSubview:content];
    // --------Content  end--

    // 设置进度条
    progressView = [[UIProgressView alloc]
    initWithFrame:CGRectMake (FITWIDTH (108), FITHEIGHT (960), FITWIDTH (864), FITHEIGHT (20))];

    [progressView setProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:progressView];

    // 启动计算下载速度的定时器，当前时间100ms后，每隔1s执行一次
    progressVlaue = 0.0;
    progressTimer = [NSTimer timerWithTimeInterval:0.5
                                            target:self
                                          selector:@selector (changeProgress)
                                          userInfo:@"Progress"
                                           repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:progressTimer forMode:NSDefaultRunLoopMode];
}

// 改变进度条进度
- (void)changeProgress
{
    // 获取网络状态
    SVRealReachability *realReachability = [SVRealReachability sharedInstance];
    SVRealReachabilityStatus currentStatus = realReachability.getNetworkStatus;

    // 进度值为1，说明进度条已经满了
    if (progressVlaue >= 1)
    {
        // 取消定时器
        [progressTimer invalidate];
        progressTimer = nil;

        // 去掉进度条和启动图片
        [contentView removeFromSuperview];
        [progressView removeFromSuperview];
        [launchImageView removeFromSuperview];

        // 如果网络是wifi并且wifi信息没有记录过，则弹出带宽设置的窗口
        if (currentStatus == SV_RealStatusViaWiFi && [self isNewWifi])
        {
            [self setShadowView];
        }

        //        // 添加定时器，判断配置是否加载完成
        //        [NSTimer scheduledTimerWithTimeInterval:5.0
        //                                         target:self
        //                                       selector:@selector (reloadConfig)
        //                                       userInfo:nil
        //                                        repeats:YES];
        return;
    }

    // 如果网络无法连接，则直接进入
    if (currentStatus == SV_WWANTypeUnknown || currentStatus == SV_RealStatusNotReachable)
    {
        progressVlaue = 1;
        [progressView setProgress:progressVlaue];
        [loadingProcessLabelValue setText:@"100%"];
        return;
    }

    // 根据测试数据是否加载完成来显示进度条的进度
    SVTestContextGetter *contextGetter = [SVTestContextGetter sharedInstance];
    if (![contextGetter isInitCompleted])
    {
        if (progressVlaue < 0.8)
        {
            progressVlaue += 0.05;
            [progressView setProgress:progressVlaue];
            int value = progressVlaue * 100;
            [loadingProcessLabelValue setText:[NSString stringWithFormat:@"%d%%", value]];
        }
    }
    else
    {
        progressVlaue = 1;
        [progressView setProgress:progressVlaue];
        [loadingProcessLabelValue setText:@"100%"];
    }
}

/**
 * 定时检查配置是否成功
 */
- (void)reloadConfig
{
    SVInitConfig *initConfig = [SVInitConfig sharedManager];
    if ([initConfig isSuccess])
    {
        return;
    }
    [initConfig loadResouceForTimer];
}

/**
 * 判断是否是新的wifi网络
 */
- (BOOL)isNewWifi
{
    // 获取当前wifi的名称
    NSString *currWifiName = [SVCurrentDevice getWifiName];
    if (!currWifiName)
    {
        return NO;
    }

    // 获取之前记录过得wifi名称
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSMutableArray *wifiInfoArray = [probeInfo getWifiInfo];

    // 判断当前wifi是否记录过
    for (SVWifiInfo *wifiInfo in wifiInfoArray)
    {
        // 如果名称已经记录过，且带宽也设置过，则不是新的wifi
        if ([wifiInfo.wifiName isEqualToString:currWifiName] &&
            (wifiInfo.bandWidth && wifiInfo.bandWidth.length > 0))
        {
            return NO;
        }
    }

    // 将新的wifi信息记录一下
    SVWifiInfo *wifiInfo = [[SVWifiInfo alloc] init];
    [wifiInfo setWifiName:currWifiName];
    [wifiInfoArray addObject:wifiInfo];
    [probeInfo setWifiInfo:wifiInfoArray];

    return YES;
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
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:11];

    // 指定未选中状态下文字属性
    [childCtrl.tabBarItem setTitleTextAttributes:dic forState:UIControlStateNormal];

    // 指定选中时属性
    NSMutableDictionary *selectedDic = [NSMutableDictionary dictionary];

    // 指定字体颜色
    selectedDic[NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"29A5E5"];

    // 指定字体
    selectedDic[NSFontAttributeName] = [UIFont systemFontOfSize:11];

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
               shadowView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];

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
