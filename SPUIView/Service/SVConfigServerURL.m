//
//  SVConfigServerURL.m
//  SpeedPro
//
//  Created by WBapple on 16/5/12.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVConfigServerURL.h"

@implementation SVConfigServerURL
{
    NSString *_configServerUrl;
}
/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    static SVConfigServerURL *configServerURL;
    @synchronized (self)
    {
        if (configServerURL == nil)
        {
            configServerURL = [[super allocWithZone:NULL] init];
            //初始化URL
            if (![configServerURL getConfigServerUrl])
            {
                [configServerURL setConfigServerUrl:@"https://tools-speedpro.huawei.com/"];
            }
            //初始化URL数组
            if (![configServerURL getConfigServerUrlListArray])
            {
                [configServerURL setConfigServerUrlListArray:@[
                    @"https://58.60.106.185:8080/",
                    @"https://tools-speedpro.huawei.com/",
                ]];
            }
        }
    }

    return configServerURL;
}
/**
 *  覆写allocWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [SVConfigServerURL sharedInstance];
}

/**
 *  覆写copyWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [SVConfigServerURL sharedInstance];
}
/**
 *  设置默认的URL
 *
 *  @param URL URL字符串
 */
- (void)setConfigServerUrl:(NSString *)URL
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:URL forKey:@"configServerUrl"];
    [defaults synchronize];
}
/**
 *  获得默认的url
 *
 *  @return url字符串
 */
- (NSString *)getConfigServerUrl
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mystring = [defaults valueForKey:@"configServerUrl"];
    return mystring;
}
/**
 *  设置默认的url列表
 *
 *  @param Array 字符串的数组
 */
- (void)setConfigServerUrlListArray:(NSArray *)Array
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:Array forKey:@"configServerUrlListArray"];
    [defaults synchronize];
}
/**
 *  获取的url列表
 *
 *  @return url列表数组
 */
- (NSArray *)getConfigServerUrlListArray
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *myarray = [defaults valueForKey:@"configServerUrlListArray"];
    return myarray;
}

@end
