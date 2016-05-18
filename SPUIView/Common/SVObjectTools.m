//
//  SVObjectTools.m
//  SpeedPro
//
//  Created by JinManli on 16/5/18.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVObjectTools.h"
#import <objc/runtime.h>

@implementation SVObjectTools

/**
 * 通过对象返回一个NSDictionary，键是属性名称，值是属性值。
 *
 * @param obj 需要转换的对象
 */
+ (NSDictionary *)getDictionary:(id)obj
{
    // 初始化字典
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    // 对象个数
    unsigned int propsCount;

    // 获取对象所有的属性
    objc_property_t *props = class_copyPropertyList ([obj class], &propsCount);

    // 遍历属性放入字典
    for (int i = 0; i < propsCount; i++)

    {
        objc_property_t prop = props[i];

        // 属性名
        NSString *propName = [NSString stringWithUTF8String:property_getName (prop)];

        // 属性值
        id value = [obj valueForKey:propName];

        if (value == nil)
        {
            value = @"";
        }
        else
        {
            value = [self getObjectInternal:value];
        }

        [dic setObject:value forKey:propName];
    }

    return dic;
}


/**
 * 将getDictionary方法返回的NSDictionary转化成JSON
 *
 * @param obj 需要转换的对象
 * @param options NSJSONWritingOptions
 * @return JSON字符串
 */
+ (NSString *)getJSON:(id)obj options:(NSJSONWritingOptions)options
{
    NSError *error = nil;
    NSData *data =
    [NSJSONSerialization dataWithJSONObject:[self getDictionary:obj] options:options error:&error];
    if (error)
    {
        SVError (@"Format object to json failed! error:%@", error);
        return @"";
    }

    NSString *resultJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return resultJson;
}

/**
 * 获取内部的对象
 */
+ (id)getObjectInternal:(id)obj
{
    // 如果为空对象则返回空字符串
    if ([obj isKindOfClass:[NSNull class]])
    {
        return @"";
    }

    // 如果属性值是字符串，数字和空，则直接返回
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]])
    {
        return obj;
    }

    // 如果属性值是数组
    if ([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for (int i = 0; i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }

    // 如果属性值是字典
    if ([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for (NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }

    return [self getDictionary:obj];
}

@end
