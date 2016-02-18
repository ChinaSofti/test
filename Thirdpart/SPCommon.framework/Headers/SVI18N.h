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

typedef enum {
    English, //英语
    Chinese, //汉语
    System //系统
} Language;


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
 *  @param langugae 设置当前语言
 */
- (void)setLanguage:(NSString *)langugae;

/**
 *  查询当前语言
 *
 *  @return 当前语言
 */
- (NSString *)getLanguage;


//根据key获取值
+ (NSString *)valueForKey:(NSString *)key;


@end
