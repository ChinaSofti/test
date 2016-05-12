//
//  TSHttpsGetter.m
//  TaskService
//
//  Created by Rain on 1/27/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "JSONKit.h"
#import "NSString+AES256.h"
#import "SVHttpsTools.h"
#import "SVLog.h"
#import "SVToast.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>

// 是否需要证书认证
static BOOL isNeedCert = YES;

@implementation SVHttpsTools
{
    // 响应数据
    NSMutableData *_allData;

    NSString *_urlString;

    // URL请求对象
    NSURLRequest *urlRequest;

    // 是否是上传结果
    BOOL isUploadResult;

    // 是否是上传结果
    BOOL isUploadLog;

    // 日志文件目录
    NSString *filePath;

    // 连接成功，返回数据
    BOOL isClientCert;
}

@synthesize finished;

/**
 *  使用指定Request进行对象初始化
 *
 *  @param request http请求
 *
 *  @return Https请求对象
 */
- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    urlRequest = request;

    // 初始化证书
    isClientCert = FALSE;

    // 建立连接
    NSURLConnection *conn =
    [[NSURLConnection alloc] initWithRequest:urlRequest delegate:(id)self startImmediately:NO];
    [conn scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [conn start];
    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return self;
}

/**
 *  发送指定的请求
 *
 *  @param request http请求
 *
 */
- (void)sendRequest:(NSURLRequest *)request
{
    urlRequest = request;

    // 初始化证书
    isClientCert = TRUE;

    // 建立连接
    NSURLConnection *conn =
    [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    [conn start];
    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

/**
 *
 */
- (void)sendRequest:(NSURLRequest *)request completionHandler:(CompletionHandler)completionHandler
{
    _handler = completionHandler;
    [self sendRequest:request];
}

/**
 *  使用指定URL字符串进行对象初始化
 *
 *  @param urlString Https协议URL的字符串
 *
 *  @return Https请求对象
 */
- (id)initWithURLNSString:(NSString *)urlString
{
    _urlString = urlString;
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    return [self initWithURL:url];
}

/**
 *  使用指定URL字符串进行对象初始化
 *
 *  @param urlString Https协议URL的字符串
 *
 *  @return Https请求对象
 */
- (id)initWithURLNSString:(NSString *)urlString WithCert:(BOOL)isNeed
{
    isNeedCert = isNeed;
    return [self initWithURLNSString:urlString];
}


/**
 *  使用指定URL进行对象初始化
 *
 *  @param urlString Https协议URL
 *
 *  @return Https请求对象
 */
- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    SVInfo (@"request URL:%@", url);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                              timeoutInterval:10];

    return [self initWithRequest:request];
}

/**
 *  获取服务器返回数据NSData
 *
 *  @return 服务器返回NSData
 */
- (NSData *)getResponseData
{
    return _allData;
}

/**
 *  获取服务器返回数据NSString
 *
 *  @return 服务器返回NSString
 */
- (NSString *)getResponseDataString
{
    if (!_allData)
    {
        return nil;
    }

    NSString *dataString = [[NSString alloc] initWithData:_allData encoding:NSUTF8StringEncoding];
    return dataString;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_handler)
    {
        _handler (nil, error);
    }

    [self performSelectorOnMainThread:@selector (setEnd) withObject:nil waitUntilDone:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data)
    {
        if (!_allData)
        {
            _allData = [[NSMutableData alloc] init];
        }

        [_allData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_allData)
    {
        SVInfo (@"request finished. data length:%zd", _allData.length);
    }
    else
    {
        SVInfo (@"request finished. data length:0");
    }

    if (_handler)
    {
        _handler (_allData, nil);
    }

    [self performSelectorOnMainThread:@selector (setEnd) withObject:nil waitUntilDone:NO];
}

- (void)setEnd
{
    finished = YES;
}

// 服务器回调函数，验证证书
- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (!isNeedCert)
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
        return;
    }

    // 获取trust object
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    SecTrustResultType result;

    [self extractP12Data:trust];
    // SecTrustEvaluate会查找前面SecTrustSetAnchorCertificates设置的证书或者系统默认提供的证书，对trust进行验证
    OSStatus status = SecTrustEvaluate (trust, &result);
    if (status == errSecSuccess && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified))
    {
        // 验证成功，生成NSURLCredential凭证cred，告知challenge的sender使用这个凭证来继续连接
        NSURLCredential *cred = [NSURLCredential credentialForTrust:trust];
        [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
    }
    else
    {
        // 验证失败，取消这次验证流程
        [challenge.sender cancelAuthenticationChallenge:challenge];
        SVError (@"Certificate authentication failure!");
    }
}


// 读取证书内容
- (void)extractP12Data:(SecTrustRef)trust
{
    NSString *certPath = nil;
    if (isClientCert)
    {
        // 导入证书
        certPath = [[NSBundle mainBundle] pathForResource:@"key" ofType:@"p12"];
    }
    else
    {
        // 导入证书
        certPath = [[NSBundle mainBundle] pathForResource:@"trust" ofType:@"p12"];
    }

    if (!certPath)
    {
        return;
    }


    // 导入证书
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:certPath];
    CFDataRef inP12Data = (__bridge CFDataRef) (PKCS12Data);

    OSStatus securityError = errSecSuccess;

    NSString *keyStr = [self getKeyStr];
    CFStringRef password = (__bridge CFStringRef) (keyStr);
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef options = CFDictionaryCreate (NULL, keys, values, 1, NULL, NULL);

    CFArrayRef items = CFArrayCreate (NULL, 0, 0, NULL);
    securityError = SecPKCS12Import (inP12Data, options, &items);
    if (securityError != 0)
    {
        if (options)
        {
            CFRelease (options);
        }

        if (items)
        {
            CFRelease (items);
        }
        SVError (@"SecPKCS12Import certificate failed!");
        return;
    }

    CFDictionaryRef ident = CFArrayGetValueAtIndex (items, 0);
    const void *tempIdentity = NULL;
    tempIdentity = CFDictionaryGetValue (ident, kSecImportItemIdentity);
    SecIdentityRef identity = (SecIdentityRef)tempIdentity;

    if (securityError != errSecSuccess)
    {
        SVError (@"Read certificate failed!");
        return;
    }

    SecCertificateRef certificate = NULL;
    SecIdentityCopyCertificate (identity, &certificate);
    const void *certs[] = { certificate };

    CFArrayRef trustedCerArr = CFArrayCreate (kCFAllocatorDefault, certs, 1, NULL);

    // 注意：这里将之前导入的证书设置成下验证的Trust Object的anchor certificate
    SecTrustSetAnchorCertificates (trust, trustedCerArr);

    if (options)
    {
        CFRelease (options);
    }

    if (items)
    {
        CFRelease (items);
    }

    if (trustedCerArr)
    {
        CFRelease (trustedCerArr);
    }
}


// 获取证书秘钥
- (NSString *)getKeyStr
{
    // 加载配置文件
    NSError *error;
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"properties"];
    NSData *configData = [[NSData alloc] initWithContentsOfFile:configPath
                                                        options:NSDataReadingMappedIfSafe
                                                          error:&error];
    if (error)
    {
        SVError (@"Read config failed! error:%@", error);
        return nil;
    }

    NSMutableDictionary *configDic = [self getDicWithData:configData];

    NSString *paramPath = [[NSBundle mainBundle] pathForResource:@"params" ofType:@"properties"];
    NSData *paramData = [[NSData alloc] initWithContentsOfFile:paramPath
                                                       options:NSDataReadingMappedIfSafe
                                                         error:&error];
    if (error)
    {
        SVError (@"Read param failed! error:%@", error);
        return nil;
    }
    NSMutableDictionary *paramDic = [self getDicWithData:paramData];

    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"properties"];
    NSData *certData =
    [[NSData alloc] initWithContentsOfFile:certPath options:NSDataReadingMappedIfSafe error:&error];
    if (error)
    {
        SVError (@"Read cert failed! error:%@", error);
        return nil;
    }
    NSMutableDictionary *certDic = [self getDicWithData:certData];

    NSString *keyPath = [[NSBundle mainBundle] pathForResource:@"key" ofType:@"properties"];
    NSData *keyData =
    [[NSData alloc] initWithContentsOfFile:keyPath options:NSDataReadingMappedIfSafe error:&error];
    if (error)
    {
        SVError (@"Read key failed! error:%@", error);
        return nil;
    }
    NSMutableDictionary *keyDic = [self getDicWithData:keyData];

    // 获取rootKey
    NSString *rootKey = [NSString
    stringWithFormat:@"%@%@%@%@", [configDic valueForKey:@"param"], [paramDic valueForKey:@"param"],
                     [certDic valueForKey:@"param"], [keyDic valueForKey:@"param"]];

    // 从文件中读取加密的key和密码

    // 解析出加密的key和密码
    NSString *encryKey = [configDic valueForKey:@"Key"];
    NSString *encryPW = [paramDic valueForKey:@"Key"];

    //解密Key
    NSString *key = [encryKey aes256_decrypt:rootKey];
    NSString *pw = [encryPW aes256_decrypt:key];

    return pw;
}

// 将文件内容解析为字典
- (NSMutableDictionary *)getDicWithData:(NSData *)fileData
{
    NSMutableDictionary *configDic = [[NSMutableDictionary alloc] init];
    NSString *contents = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSArray *lineArray = [contents componentsSeparatedByString:@"\n"];
    for (NSString *lineStr in lineArray)
    {
        NSArray *params = [lineStr componentsSeparatedByString:@":"];
        if ([params count] != 2)
        {
            continue;
        }

        [configDic setObject:params[1] forKey:params[0]];
    }
    return configDic;
}

// 设置是否需要证书
- (void)isNeedCert:(BOOL)isNeed
{
    isNeedCert = isNeed;
}

/**
 * 根据host获取对应的ip地址
 * @param hostName host地址
 * @return IP地址
 */
+ (NSString *)getIPWithHostName:(const NSString *)hostName
{
    NSString *strIPAddress = @"0.0.0.0";

    if (!hostName)
    {
        return strIPAddress;
    }

    const char *hostN = [hostName UTF8String];
    struct hostent *phot;

    if (!hostN)
    {
        return strIPAddress;
    }

    phot = gethostbyname (hostN);

    if (!phot || !phot->h_addr_list)
    {
        return strIPAddress;
    }

    struct in_addr ip_addr;

    memcpy (&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = { 0 };
    inet_ntop (AF_INET, &ip_addr, ip, sizeof (ip));

    strIPAddress = [NSString stringWithUTF8String:ip];

    return strIPAddress;
}
@end
