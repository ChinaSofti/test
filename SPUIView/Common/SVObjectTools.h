//
//  SVObjectTools.h
//  SpeedPro
//
//  Created by JinManli on 16/5/18.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVObjectTools : NSObject

/**
 * 通过对象返回一个NSDictionary，键是属性名称，值是属性值。
 *
 * @param obj 需要转换的对象
 */
+ (NSDictionary *)getDictionary:(id)obj;


/**
 * 将getDictionary方法返回的NSDictionary转化成JSON
 *
 * @param obj 需要转换的对象
 * @param options NSJSONWritingOptions
 * @return JSON字符串
 */
+ (NSString *)getJSON:(id)obj options:(NSJSONWritingOptions)options;

@end
