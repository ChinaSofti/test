//
//  TSHttpGetter.h
//  TaskService
//
//  Created by Rain on 1/27/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVHttpGetter : NSObject

/**
 *  请求指定URL，并获取服务器响应数据
 *
 *  @param urlString 请求URL
 *
 *  @return 服务器返回数据
 */
+ (id)requestWithoutParameter:(NSString *)urlString;


/**
 *  请求指定URL，并获取服务器响应数据
 *
 *  @param urlString 请求URL
 *
 *  @return 服务器返回数据
 */
+ (NSData *)requestDataWithoutParameter:(NSString *)urlString;

@end
