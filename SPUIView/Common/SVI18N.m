//
//  CTInternationalControl.m
//  Localizable
//
//  Created by 许彦彬 on 16/1/22.
//  Copyright © 2016年 HuaWei. All rights reserved.
//

#import "SVI18N.h"

#define ENGLISH @"en"
#define CHINESE @"zh-Hans"
#define SYSTEM @"system"

@implementation SVI18N

static NSBundle *i18nBundle;

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    static SVI18N *i18n;
    @synchronized (self)
    {
        if (i18n == nil)
        {
            i18n = [[super allocWithZone:NULL] init];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *language = [defaults valueForKey:@"language"];
            if (!language)
            {
                language = [SVI18N getSystemLanguage];
            }

            //获取文件路径
            NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
            //生成bundle
            i18nBundle = [NSBundle bundleWithPath:path];
        }
    }

    return i18n;
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
    return [SVI18N sharedInstance];
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
    return [SVI18N sharedInstance];
}


/**
 *  设置当前语言
 *
 *  @param langugae 设置当前语言
 */
- (void)setLanguage:(NSString *)language
{
    NSString *userLanguage;
    if ([language containsString:@"en"])
    {
        userLanguage = @"en";
    }
    else if ([language containsString:@"zh"])
    {
        userLanguage = @"zh";
    }
    else
    {
        userLanguage = @"en";
    }


    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userLanguage forKey:@"language"];
    [defaults synchronize];

    //获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    //生成bundle
    i18nBundle = [NSBundle bundleWithPath:path];
}

/**
 *  查询当前语言
 *
 *  @return 当前语言
 */
- (NSString *)getLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *language = [defaults valueForKey:@"language"];
    return language;
}

/**
 *  根据当前系统语言获得的NSBundle
 *
 *  @return NSBundle
 */
- (NSBundle *)getBundle
{
    return i18nBundle;
}

/**
 *  设置当前NSBundle
 *
 *  @param bundle NSBundle
 */
- (void)setBundle:(NSBundle *)bundle
{
    i18nBundle = bundle;
}

/**
 *  查询当前系统语言
 *
 *  @return 当前系统语言
 */
+ (NSString *)getSystemLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *language = [[languages objectAtIndex:0] lowercaseString];

    if ([language containsString:@"en"])
    {
        return @"en";
    }
    else if ([language containsString:@"zh"])
    {
        return @"zh";
    }
    else
    {
        return @"en";
    }
}

/**
 *  根据key查询国际化value
 *
 *  @param key key
 *
 *  @return 国际化value
 */
+ (NSString *)valueForKey:(NSString *)key
{
    SVI18N *i18n = [SVI18N sharedInstance];
    NSBundle *bundle = [i18n getBundle];
    NSString *value = [bundle localizedStringForKey:key value:nil table:@"i18n"];
    if (value && value.length > 0)
    {
        return value;
    }
    else
    {
        return key;
    }
}

@end
