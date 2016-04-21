//
//  SVAppVersionChecker.m
//  SpeedPro
//
//  Created by Rain on 4/20/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVAppVersionChecker.h"
#import "SVHttpGetter.h"
#import "SVLog.h"

@implementation SVAppVersionChecker


/**
 *  检查当前AppStore上App是否存在新的发布。
 *
 *  @return YES: 存在新版本
 *
 */
+ (BOOL)hasNewVersion
{

    NSString *appStoreVersion = [SVAppVersionChecker currentVersionInAppStore];
    NSString *currentVersion = [SVAppVersionChecker currentVersion];

    NSArray *curVerArr = [currentVersion componentsSeparatedByString:@"."];
    NSArray *appstoreVerArr = [appStoreVersion componentsSeparatedByString:@"."];
    BOOL needUpdate = NO;
    //比较版本号大小
    int maxv = (int)MAX (curVerArr.count, appstoreVerArr.count);
    int cver = 0;
    int aver = 0;
    for (int i = 0; i < maxv; i++)
    {
        if (appstoreVerArr.count > i)
        {
            aver = [NSString stringWithFormat:@"%@", appstoreVerArr[i]].intValue;
        }
        else
        {
            aver = 0;
        }
        if (curVerArr.count > i)
        {
            cver = [NSString stringWithFormat:@"%@", curVerArr[i]].intValue;
        }
        else
        {
            cver = 0;
        }

        if (aver > cver)
        {
            needUpdate = YES;
            break;
        }
    }

    return needUpdate;
}


/**
 *  获取当前APP版本号
 *
 *  @return 当前APP版本号
 */
+ (NSString *)currentVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    //    CFBundleShortVersionString  1.1
    NSString *mainVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    //    CFBundleVersion  build 版本号
    NSString *buildVersion = [infoDic objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@.%@", mainVersion, buildVersion];
}


/**
 *  获取AppStore中APP版本号
 *
 *  @return 当前AppStore中APP版本号
 */
+ (NSString *)currentVersionInAppStore
{
    NSString *version = @"1.0.1";
    NSString *url =
    [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=%@", @"1094185054"];
    NSData *data = [SVHttpGetter requestDataWithoutParameter:url];
    NSError *error;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error)
    {
        SVError (@"get app version fail from appstore. use default version:1.0.1");
        return version;
    }


    NSArray *results = [jsonObj valueForKey:@"results"];
    if (!results || results.count <= 0)
    {
        SVError (@"get app version fail from appstore. use default version:1.0.1");
        return version;
    }

    NSDictionary *resultDic = results[0];
    version = [resultDic valueForKey:@"version"];
    return version;
}

@end
