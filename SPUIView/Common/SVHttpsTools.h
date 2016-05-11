//
//  TSHttpsGetter.h
//  TaskService
//
//  Created by Rain on 1/27/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionHandler) (NSData *responseData, NSError *error);

@interface SVHttpsTools : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    // 服务器响应后进行操作的对象
    CompletionHandler _handler;
}


@property BOOL finished;

/**
 *  使用指定URL字符串进行对象初始化
 *
 *  @param urlString Https协议URL的字符串
 *
 *  @return Https请求对象
 */
- (id)initWithURLNSString:(NSString *)urlString;

/**
 *  使用指定URL字符串进行对象初始化
 *
 *  @param urlString Https协议URL的字符串
 *
 *  @return Https请求对象
 */
- (id)initWithURLNSString:(NSString *)urlString WithCert:(BOOL)isNeed;


/**
 *  使用指定URL进行对象初始化
 *
 *  @param urlString Https协议URL
 *
 *  @return Https请求对象
 */
- (id)initWithURL:(NSURL *)url;

/**
 *  获取服务器返回数据NSData
 *
 *  @return 服务器返回NSData
 */
- (NSData *)getResponseData;

/**
 *  获取服务器返回数据NSString
 *
 *  @return 服务器返回NSString
 */
- (NSString *)getResponseDataString;

/**
 *  使用指定Request进行对象初始化
 *
 *  @param request http请求
 *
 *  @return Https请求对象
 */
- (id)initWithRequest:(NSURLRequest *)request;

/**
 *  发送指定的请求
 *
 *  @param request http请求
 *
 */
- (void)sendRequest:(NSURLRequest *)request;

/**
 *  发送指定的请求
 *
 *  @param request http请求
 *  @param isUpload 是否是上传测试结果
 *
 */
- (void)sendRequest:(NSURLRequest *)request completionHandler:(CompletionHandler)completionHandler;

// 设置是否需要证书
- (void)isNeedCert:(BOOL)isNeed;

/**
 * 根据host获取对应的ip地址
 * @param hostName host地址
 * @return IP地址
 */
+ (NSString *)getIPWithHostName:(const NSString *)hostName;

@end
