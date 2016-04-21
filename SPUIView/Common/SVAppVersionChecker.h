//
//  SVAppVersionChecker.h
//  SpeedPro
//
//  Created by Rain on 4/20/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  检查当前AppStore上App当前版本，以及是否存在新的发布。
 *  iTunes可以提供app的版本信息，主要通过appid获取，如
 http://itunes.apple.com/lookup?id=946449501，使用时只需要到iTunes查找自己的appid，修改成自己的appid即可

 使用HTTP模式读取此链接可以获取app信息的json字符串
 */
@interface SVAppVersionChecker : NSObject

/**
 *  检查当前AppStore上App是否存在新的发布。
 *
 *  @return YES: 存在新版本
 *
 */
+ (BOOL)hasNewVersion;


/**
 *  获取当前APP版本号
 *
 *  @return 当前APP版本号
 */
+ (NSString *)currentVersion;


/**
 *  获取AppStore中APP版本号
 *
 *  @return 当前AppStore中APP版本号
 */
+ (NSString *)currentVersionInAppStore;


@end
