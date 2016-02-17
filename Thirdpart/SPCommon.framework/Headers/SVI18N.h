//
//  CTInternationalControl.h
//  Localizable
//
//  Created by 许彦彬 on 16/1/22.
//  Copyright © 2016年 HuaWei. All rights reserved.
//
#define I18N(key) [SVI18N valueForKey:key]
#define SetUserLanguage [SVI18N setUserlanguage]

#import <Foundation/Foundation.h>

@interface SVI18N : NSObject

typedef enum {
    English, //英语
    Chinese, //汉语
    System //系统
} Language;

//设置当前语言
+ (void)setUserlanguage:(Language)language;

//获取当前语言
+ (NSString *)currentLanguage;

//根据key获取值
+ (NSString *)valueForKey:(NSString *)key;

@end
