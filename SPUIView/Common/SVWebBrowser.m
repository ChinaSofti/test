//
//  TSWebBrowser.m
//  TaskService
//
//  Created by Rain on 1/31/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVLog.h"
#import "SVWebBrowser.h"

/**
 *  浏览器模拟器，模拟浏览器访问页面
 */
@implementation SVWebBrowser

static NSString *useragent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_1 like Mac OS X) "
                             @"AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Mobile/9B206 "
                             @"Safari/601.3.9";


/**
 *  添加http请求头
 *
 *  @param key 键
 *  @param value 值
 */
- (void)addHeader:(NSString *)key value:(NSString *)value
{
    if (!_header)
    {
        _header = [[NSMutableDictionary alloc] init];
    }

    [_header setObject:value forKey:key];
}

/**
 *  添加Session
 *
 *  @param key   键
 *  @param value 值
 */
- (void)addSession:(NSString *)key value:(NSString *)value
{
    if (!_session)
    {
        _session = [[NSMutableDictionary alloc] init];
    }

    [_session setObject:value forKey:key];
}

/**
 *  添加Cookie
 *
 *  @param key   键
 *  @param value 值
 */
- (void)addCookies:(NSString *)key value:(NSString *)value
{
    if (!_cookies)
    {
        _cookies = [[NSMutableDictionary alloc] init];
    }

    [_cookies setObject:value forKey:key];
}

/**
 *  添加请求参数
 *
 *  @param key   键
 *  @param value 值
 */
- (void)addParameter:(NSString *)key value:(NSString *)value
{
    if (!_parameters)
    {
        _parameters = [[NSMutableDictionary alloc] init];
    }

    [_parameters setObject:value forKey:key];
}


/**
 *  获取服务器返回数据
 *
 *  @return 响应数据
 */
- (NSData *)getResponseData
{
    return _returnData;
}

/**
 *  从服务器返回的header中查询指定key的值
 *
 *  @param key 键
 *
 *  @return 值
 */
- (NSString *)getReturnHeader:(NSString *)key
{
    if (!_returnHeader)
    {
        return nil;
    }

    return [_returnHeader objectForKey:key];
}

/**
 *  从服务器返回的Cookie中查询指定key的值
 *
 *  @param key 键
 *
 *  @return 值
 */
- (NSString *)getReturnCookie:(NSString *)key
{
    if (!_returnCookies)
    {
        return nil;
    }

    return [_returnCookies objectForKey:key];
}

/**
 *  访问targetURL,并使用指定访问类型进行访问
 *
 *  @param targetURL   目标URL
 *  @param requestType 请求类型：包括get和post
 */
- (void)browser:(NSString *)targetURL requestType:(TSRequestType)requestType
{
    _targetURL = targetURL;
    _requestType = requestType;
    //    TSInfo (@"request URL:%@ requestType:%@", _targetURL, TSRequestTypeValue[_requestType]);
    SVInfo (@"request URL:%@", _targetURL);

    NSURL *url = [[NSURL alloc] initWithString:_targetURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:10];

    NSURLConnection *conn =
    [[NSURLConnection alloc] initWithRequest:request delegate:(id)self startImmediately:NO];
    [conn scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [conn start];
    // NSURLConnection connectionWithRequest:request delegate:self];
    while (!finished)
    {
        // spend 1 second processing events on each loop
        NSDate *oneSecond = [NSDate dateWithTimeIntervalSinceNow:1];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:oneSecond];
    }
}

#pragma mark request delegage
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection
                      willSendRequest:(NSURLRequest *)request
                     redirectResponse:(nullable NSURLResponse *)response
{
    // 创建一个 NSMutableURLRequest 添加 header
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    // 设置请求类型
    //    [mutableRequest setHTTPMethod:(TSRequestTypeValue[_requestType])];
    if (_header)
    {
        [mutableRequest addValue:useragent forHTTPHeaderField:@"User-Agent"];

        [_header enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
          // 拷贝用户新设置的属性到NSURLRequest中
          [mutableRequest addValue:obj forHTTPHeaderField:key];
        }];
    }


    // 设置Cookie
    if (_cookies)
    {
        NSMutableString *cookiesStr = [[NSMutableString alloc] init];
        [_cookies enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
          //
          [cookiesStr appendFormat:@"%@=%@;", key, obj];
        }];

        [mutableRequest addValue:cookiesStr forHTTPHeaderField:@"Cookie"];
    }
    request = [mutableRequest copy];
    return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (!_returnHeader)
    {
        // init
        _returnHeader = [[NSMutableDictionary alloc] init];
    }

    if (!_returnCookies)
    {
        // init
        _returnCookies = [[NSMutableDictionary alloc] init];
    }

    // 注意这里将NSURLResponse对象转换成NSHTTPURLResponse对象才能去
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode != 200)
    {
        SVWarn (@"reponse status code:%zd", statusCode);
    }

    if ([response respondsToSelector:@selector (allHeaderFields)])
    {
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {

          //          SVInfo (@"%@  =  %@", key, obj);
          [_returnHeader setObject:obj forKey:key];

          if ([@"Set-Cookie" isEqualToString:key])
          {
              // 例如：
              // Set-Cookie:ykss=aa21ae5604c6a4561bdab054; path=/; domain=.youku.com, u=__LOGOUT__;
              NSString *cookieString = (NSString *)obj;
              NSArray *cookiesArray = [cookieString componentsSeparatedByString:@";"];
              for (NSString *cookie in cookiesArray)
              {
                  // ykss=aa21ae5604c6a4561bdab054
                  if ([cookie containsString:@"="])
                  {
                      NSArray *cookieArray = [cookie componentsSeparatedByString:@"="];
                      [_returnCookies setObject:cookieArray[1] forKey:cookieArray[0]];
                  }
              }
          }
        }];
    }
}

+ (void)parseCookie:(id)cookieString
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_returnData)
    {
        _returnData = [[NSMutableData alloc] init];
    }

    [_returnData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    SVError (@"request URL:%@  Error:%@", _targetURL, error);
    finished = true;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    finished = true;
}


- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
         forAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection *)connection
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}


@end
