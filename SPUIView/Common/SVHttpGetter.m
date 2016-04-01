//
//  TSHttpGetter.m
//  TaskService
//
//  Created by Rain on 1/27/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVHttpGetter.h"
#import "SVLog.h"

@implementation SVHttpGetter

/**
 *  请求指定URL，并获取服务器响应数据
 *
 *  @param urlString 请求URL
 *
 *  @return 服务器返回数据
 */
+ (NSString *)requestWithoutParameter:(NSString *)urlString
{
    NSData *data = [SVHttpGetter requestDataWithoutParameter:urlString];
    if (!data)
    {
        return nil;
    }

    NSString *responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return responseData;
}

/**
 *  请求指定URL，并获取服务器响应数据
 *
 *  @param urlString 请求URL
 *
 *  @return 服务器返回数据
 */
+ (NSData *)requestDataWithoutParameter:(NSString *)urlString
{
    SVInfo (@"request URL:%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                              timeoutInterval:10];
    //    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSData *data =
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error)
    {
        SVError (@"request URL:%@ fail. %@", urlString, error);
        return nil;
    }

    SVDebug (@"request URL:%@  response data length:%zd", urlString, data.length);
    return data;
}

@end
