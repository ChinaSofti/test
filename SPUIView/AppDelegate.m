//
//  AppDelegate.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "AppDelegate.h"
#import "SVTabBarController.h"
#import "SVToast.h"
#import <SPService/SVProbeInfo.h>
#import <SPService/SVSpeedTestServers.h>
#import <SPService/SVTestContextGetter.h>
//微信分享
#import "WXApi.h"
@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //微信分享api注册
    [WXApi registerApp:@"wx2cce736067ee4a2d"];

    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#45545C"]];
    // 设置tabbar的背景颜色
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:@"EEEEEE"]];

    // 去掉tabbar边框
    //        [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    //        [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];

    // 1.初始化一个window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    // 2.设置根控制器
    self.window.rootViewController = [SVTabBarController new];

    // 3.让显示并成为主窗口
    [self.window makeKeyAndVisible];

    SVRealReachability *realReachability = [SVRealReachability sharedInstance];
    [realReachability addDelegate:self];

    return YES;
}


- (void)networkStatusChange:(SVRealReachabilityStatus)status
{
    switch (status)
    {
    case SV_RealStatusNotReachable:
        SVInfo (@"%@", @"Network unreachable!");
        [SVToast showWithText:I18N (@"Network unreachable!")];
        [[SVProbeInfo sharedInstance] setNetworkType:@"1"];
        break;
    case SV_RealStatusViaWWAN:
        SVInfo (@"%@", @"Network WWAN! In charge!");
        [SVToast showWithText:I18N (@"Network WWAN!")];
        [[SVProbeInfo sharedInstance] setNetworkType:@"0"];
        break;
    case SV_RealStatusViaWiFi:
        SVInfo (@"%@", @"Network wifi! Free!");
        [SVToast showWithText:I18N (@"Network wifi!")];
        [[SVProbeInfo sharedInstance] setNetworkType:@"1"];
        break;
    case SV_WWANType2G:
        SVInfo (@"%@", @"RealReachabilityStatus2G");
        [SVToast showWithText:I18N (@"Network 2G!")];
        [[SVProbeInfo sharedInstance] setNetworkType:@"0"];
        break;
    case SV_WWANType3G:
        SVInfo (@"%@", @"RealReachabilityStatus3G");
        [SVToast showWithText:I18N (@"Network 3G!")];
        [[SVProbeInfo sharedInstance] setNetworkType:@"0"];
        break;
    case SV_WWANType4G:
        SVInfo (@"%@", @"RealReachabilityStatus4G");
        [SVToast showWithText:I18N (@"Network 4G!")];
        [[SVProbeInfo sharedInstance] setNetworkType:@"0"];
        break;
    default:
        SVInfo (@"%@", @"Unknown RealReachability WWAN Status, might be iOS6");
        [[SVProbeInfo sharedInstance] setNetworkType:@"1"];
        break;
    }

    if (status != SV_RealStatusNotReachable)
    {
        // 当网络正常时，从服务器加载测试相关配置信息
        [self loadResouceFromServer];
    }
}

- (void)loadResouceFromServer
{
    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

      SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
      [servers initSpeedTestServer];

      // 初始化Test Context
      SVTestContextGetter *contextGetter = [SVTestContextGetter sharedInstance];
      if (![contextGetter isInitSuccess])
      {
          // 初始化本机IP和运营商等信息
          [contextGetter initIPAndISP];
          //从服务器请求Test Context Data相关信息
          [contextGetter requestContextDataFromServer];
          // 解析服务器返回的Test Context Data
          [contextGetter parseContextData];
      }

    });
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
    exit (0);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
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
