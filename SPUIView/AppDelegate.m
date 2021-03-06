//
//  AppDelegate.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "AppDelegate.h"
#import "SVAppVersionChecker.h"
#import "SVCurrentDevice.h"
#import "SVCurrentDevice.h"
#import "SVDBManager.h"
#import "SVProbeInfo.h"
#import "SVTabBarController.h"
#import "SVToast.h"
//微信分享
#import "WXApi.h"
//分享
#import "SVCurentLocation.h"
#import "SVInitConfig.h"
#import "SVReloadingDataAlertViewManager.h"
#import "UMSocial.h"
#import "UMSocialFacebookHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialWechatHandler.h"

@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate
{
    BOOL noFirstStart;
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);

    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastversion"];
    NSString *currentVersion = [SVAppVersionChecker currentVersion];
    // 判断是否是安装后第一次启动APP
    if (!lastVersion || ![lastVersion isEqualToString:currentVersion])
    {
        // 第一次启动APP，清除旧数据
        SVDBManager *manager = [SVDBManager sharedInstance];
        [manager removeDatabase];

        [[NSUserDefaults standardUserDefaults] setValue:currentVersion forKey:@"lastversion"];
    }

    /*****************************************分享代码********************************/
    // 1.友盟分享的Key
    NSString *UmengAppkey = @"57173b1ce0f55add74000285";
    // 2.要分享的URL
    NSString *Url = I18N (@"myurl");
    // 3.1设置友盟社会化组件appkey
    [UMSocialData setAppKey:UmengAppkey];
    // 3.2设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wx1d6b749a18f33c50"
                            appSecret:@"c8e7605d0bd5f02add0e35bdbc6f2b30"
                                  url:Url];
    // 3.3打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"1657697846"
                                              secret:@"d09a66e00701f15f5f5bcc20f514fc53"
                                         RedirectURL:Url];
    // 3.4设置Facebook，AppID和分享url(根据bundel不同需要更换APPID)
    /*
     bundel id:com.huawei.speedpro
     576212805892427
     bundel id:com.huawei.speedpro.debug
     221368888244101
     */
    [UMSocialFacebookHandler setFacebookAppID:@"576212805892427" shareFacebookWithURL:Url];
    // 4.1支持横屏
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
    // 4.2对未安装客户端平台进行隐藏(苹果审核需要,如果不加审核不过)
    [UMSocialConfig hiddenNotInstallPlatforms:@[
        UMShareToWechatSession,
        UMShareToWechatTimeline,
        UMShareToSina,
        UMShareToFacebook
    ]];
    // 4.4分享链接
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeWeb url:Url];
    /*****************************************分享代码********************************/
    //设置navigationBar的颜色
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#263841"]];

    // 设置tabbar的背景颜色
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:@"EEEEEE"]];

    // 1.初始化一个window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    // 2.设置根控制器
    self.window.rootViewController = [SVTabBarController new];

    // 3.让显示并成为主窗口
    [self.window makeKeyAndVisible];


    SVRealReachability *realReachability = [SVRealReachability sharedInstance];
    [realReachability addDelegate:self];

    // 获取定位信息
    [[SVCurentLocation sharedInstance] getUserLocation];
    return YES;
}

void UncaughtExceptionHandler (NSException *exception)
{
    /**
     *  获取异常崩溃信息
     */
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString
    stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",
                     name, reason, [callStack componentsJoinedByString:@"\n"]];

    SVError (@"%@", content);
}

#pragma mark - 分享的方法
//回调函数
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE)
    {
        //调用其他SDK，例如支付宝SDK等
        SVInfo (@"分享回调函数");
    }
    return result;
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if (response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        SVInfo (@"share to sns name is %@", [[response.data allKeys] objectAtIndex:0]);
    }
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url];
}
//弹出列表方法presentSnsIconSheetView需要设置delegate为self
- (BOOL)isDirectShareInIconActionSheet
{
    return YES;
}

#pragma mark - 网络状态
- (void)networkStatusChange:(SVRealReachabilityStatus)status
{
    switch (status)
    {
    case SV_RealStatusNotReachable:
    {
        SVInfo (@"%@", @"Network unreachable!");
        [SVToast showWithText:I18N (@"Network unreachable!")];
        [[SVProbeInfo sharedInstance] setNetworkType:1];
        break;
    }
    case SV_RealStatusViaWWAN:
        SVInfo (@"%@", @"Network WWAN! In charge!");
        [SVToast showWithText:I18N (@"Network WWAN!")];
        [[SVProbeInfo sharedInstance] setNetworkType:0];
        break;
    case SV_RealStatusViaWiFi:
        SVInfo (@"%@", @"Network wifi! Free!");
        [SVToast showWithText:I18N (@"Network wifi!")];
        [[SVProbeInfo sharedInstance] setNetworkType:1];
        break;
    case SV_WWANType2G:
        SVInfo (@"%@", @"RealReachabilityStatus2G");
        [SVToast showWithText:I18N (@"Network 2G!")];
        [[SVProbeInfo sharedInstance] setNetworkType:0];
        break;
    case SV_WWANType3G:
        SVInfo (@"%@", @"RealReachabilityStatus3G");
        [SVToast showWithText:I18N (@"Network 3G!")];
        [[SVProbeInfo sharedInstance] setNetworkType:0];
        break;
    case SV_WWANType4G:
        SVInfo (@"%@", @"RealReachabilityStatus4G");
        [SVToast showWithText:I18N (@"Network 4G!")];
        [[SVProbeInfo sharedInstance] setNetworkType:0];
        break;
    default:
        SVInfo (@"%@", @"Unknown RealReachability WWAN Status, might be iOS6");
        [[SVProbeInfo sharedInstance] setNetworkType:0];
        break;
    }

    // 如果网络不可达，则发送通知
    if (status == SV_RealStatusNotReachable)
    {
        // 发送消息
        [self sendNotificationWithName:@"networkStatusError"];
    }

    if (!noFirstStart && status != SV_RealStatusNotReachable)
    {
        // 当网络正常时，从服务器加载测试相关配置信息
        [self loadResouceFromServer];
        noFirstStart = YES;

        SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
        NSString *wifiName = [SVCurrentDevice getWifiName];
        [probeInfo setWifiName:wifiName];

        // 发送消息，通知部分界面重新加载数据
        dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          while (![SVInitConfig sharedManager].initServerIsSuccess)
          {
              [NSThread sleepForTimeInterval:0.5];
          }
          [self sendNotificationWithName:@"reloadInfo"];
        });
        return;
    }

    if (status != SV_RealStatusNotReachable)
    {
        [self reloadData];
    }
}

- (void)loadResouceFromServer
{
    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

      NSString *wifiName = [SVCurrentDevice getWifiName];
      SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
      [probeInfo setWifiName:wifiName];

      // 初始化配置
      [[SVInitConfig sharedManager] loadResouceFromServer];
    });
}

- (void)sendNotificationWithName:(NSString *)name
{
    // 创建一个消息对象
    NSNotification *notice = [NSNotification notificationWithName:name object:nil userInfo:nil];

    //发送消息
    [[NSNotificationCenter defaultCenter] postNotification:notice];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
    // 如果正在测试，则终止当前测试。
    SVProbeInfo *probe = [[SVProbeInfo alloc] init];
    if (probe.isTesting)
    {
        SVInfo (@"SpeedPro exit...");
        exit (0);
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
    //    SVRealReachability *realReachability = [SVRealReachability sharedInstance];
    //    if ([realReachability isReachable])
    //    {
    //        [self reloadData];
    //    }
}

- (void)reloadData
{
    // 获取wifi信息
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSString *lastWifiName = probeInfo.wifiName;
    NSString *wifiName = [SVCurrentDevice getWifiName];

    // 如果上次wifi信息，和当前wifi信息不一致也需要重新加载数据
    if (lastWifiName)
    {
        if (![wifiName isEqualToString:@"None"] && ![lastWifiName isEqualToString:wifiName])
        {
            SVReloadingDataAlertViewManager *rdAlertViewManager =
            [SVReloadingDataAlertViewManager sharedInstance];
            [rdAlertViewManager showAlertView];
            [probeInfo setWifiName:wifiName];
        }
    }
    else
    {
        if (wifiName && ![wifiName isEqualToString:@"None"])
        {
            SVReloadingDataAlertViewManager *rdAlertViewManager =
            [SVReloadingDataAlertViewManager sharedInstance];
            [rdAlertViewManager showAlertView];
            [probeInfo setWifiName:wifiName];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

@end
