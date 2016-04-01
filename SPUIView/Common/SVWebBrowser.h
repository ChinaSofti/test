//
//  TSWebBrowser.h
//  TaskService
//
//  Created by Rain on 1/31/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    //
    GET,
    //
    POST
} TSRequestType;
//
// NSString *TSRequestTypeValue[] = {
//    //
//    @"GET",
//    //
//    @"POST"
//};


/**
 *  浏览器模拟器，模拟浏览器访问页面。
 *  目前仅支持设置_header 和 获取服务器返回的_returnHeader。 不支持Session,Cookies
 */
@interface SVWebBrowser : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSMutableDictionary *_session;
    NSMutableDictionary *_cookies;
    NSMutableDictionary *_header;
    NSMutableDictionary *_parameters;
    NSMutableDictionary *_returnHeader;
    NSMutableDictionary *_returnCookies;
    NSMutableData *_returnData;
    NSString *_targetURL;
    TSRequestType _requestType;
    // 请求是否结束
    bool finished;
}


/**
 *  添加http请求头
 *
 *  @param key 键
 *  @param value 值
 */
- (void)addHeader:(NSString *)key value:(NSString *)value;

/**
 *  添加Session
 *
 *  @param key   键
 *  @param value 值
 */
- (void)addSession:(NSString *)key value:(NSString *)value;

/**
 *  添加Cookie
 *
 *  @param key   键
 *  @param value 值
 */
- (void)addCookies:(NSString *)key value:(NSString *)value;

/**
 *  添加请求参数
 *
 *  @param key   键
 *  @param value 值
 */
- (void)addParameter:(NSString *)key value:(NSString *)value;


/**
 *  获取服务器返回数据
 *
 *  @return 响应数据
 */
- (NSData *)getResponseData;

/**
 *  从服务器返回的header中查询指定key的值
 *
 *  @param key 键
 *
 *  @return 值
 */
- (NSString *)getReturnHeader:(NSString *)key;

/**
 *  从服务器返回的Cookie中查询指定key的值
 *
 *  @param key 键
 *
 *  @return 值
 */
- (NSString *)getReturnCookie:(NSString *)key;

/**
 *  访问targetURL,并使用指定访问类型进行访问
 *
 *  @param targetURL   目标URL
 *  @param requestType 请求类型：包括get和post
 */
- (void)browser:(NSString *)targetURL requestType:(TSRequestType)requestType;

@end
