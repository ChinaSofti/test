//
//  CTInternationalControl.h
//  Localizable
//
//  Created by 许彦彬 on 16/1/22.
//  Copyright © 2016年 HuaWei. All rights reserved.
//
#define I18N(key) [SVI18N valueForKey:key]

#import <Foundation/Foundation.h>

@interface SVI18N : NSObject

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance;

/**
 *  覆写allocWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)allocWithZone:(struct _NSZone *)zone;

/**
 *  覆写copyWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)copyWithZone:(struct _NSZone *)zone;


/**
 *  设置当前语言
 *
 *  @param language 设置当前语言
 */
- (void)setLanguage:(NSString *)language;

/**
 *  查询当前语言
 *
 *  @return 当前语言
 */
- (NSString *)getLanguage;

/**
 *  根据当前系统语言获得的NSBundle
 *
 *  @return NSBundle
 */
- (NSBundle *)getBundle;

/**
 *  设置当前NSBundle
 *
 *  @param bundle NSBundle
 */
- (void)setBundle:(NSBundle *)bundle;

/**
 *  查询当前系统语言
 *
 *  @return 当前系统语言
 */
+ (NSString *)getSystemLanguage;

/**
 *  根据key查询国际化value
 *
 *  @param key key
 *
 *  @return 国际化value
 */
+ (NSString *)valueForKey:(NSString *)key;


@end
