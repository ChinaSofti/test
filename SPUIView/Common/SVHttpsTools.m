//
//  TSHttpsGetter.m
//  TaskService
//
//  Created by Rain on 1/27/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "NSString+AES256.h"
#import "SVHttpsTools.h"
#import "SVLog.h"
#import "SVToast.h"

// 是否需要证书认证
static BOOL isNeedCert = YES;

@implementation SVHttpsTools
{
    // 响应数据
    NSMutableData *_allData;

    NSString *_urlString;

    BOOL finished;

    // 证书数组
    CFArrayRef trustedCerArr;

    // 失败次数
    int failCount;

    // URL请求对象
    NSURLRequest *urlRequest;

    SecIdentityRef identity;

    // 是否是上传结果
    BOOL isUploadResult;

    // 是否是上传结果
    BOOL isUploadLog;

    // 日志文件目录
    NSString *filePath;
}

/**
 *  初始化证书
 *
 */
- (void)initCertWithPath:(NSString *)certPath
{
    // 导入证书
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:certPath];

    // 读取p12证书中的内容
    OSStatus result = [self extractP12Data:(__bridge CFDataRef) (PKCS12Data)];
    if (result != errSecSuccess)
    {
        SVError (@"Read certificate failed!");
        return;
    }

    SecCertificateRef certificate = NULL;
    SecIdentityCopyCertificate (identity, &certificate);
    const void *certs[] = { certificate };
    trustedCerArr = CFArrayCreate (kCFAllocatorDefault, certs, 1, NULL);
}

/**
 *  初始化Client端证书
 *
 */
- (void)initClientCert
{
    // 导入证书
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"key" ofType:@"p12"];
    [self initCertWithPath:thePath];
}

/**
 *  初始化server端证书
 *
 */
- (void)initServerCert
{
    // 导入证书
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"trust" ofType:@"p12"];
    [self initCertWithPath:thePath];
}

// 读取证书内容
- (OSStatus)extractP12Data:(CFDataRef)inP12Data
{

    OSStatus securityError = errSecSuccess;

    NSString *keyStr = [self getKeyStr];
    CFStringRef password = (__bridge CFStringRef) (keyStr);
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };

    CFDictionaryRef options = CFDictionaryCreate (NULL, keys, values, 1, NULL, NULL);

    CFArrayRef items = CFArrayCreate (NULL, 0, 0, NULL);
    securityError = SecPKCS12Import (inP12Data, options, &items);

    if (securityError == 0)
    {
        CFDictionaryRef ident = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (ident, kSecImportItemIdentity);
        identity = (SecIdentityRef)tempIdentity;
    }

    if (options)
    {
        CFRelease (options);
    }

    return securityError;
}

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
    [self initServerCert];

    // 建立连接
    NSURLConnection *conn =
    [[NSURLConnection alloc] initWithRequest:urlRequest delegate:(id)self startImmediately:NO];
    [conn scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [conn start];
    while (!finished)
    {
        // spend 1 second processing events on each loop
        NSDate *oneSecond = [NSDate dateWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:oneSecond];
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
    [self initClientCert];

    // 建立连接
    NSURLConnection *conn =
    [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    [conn start];
}

/**
 *  发送指定的请求
 *
 *  @param request http请求
 *  @param isUpload 是否是上传测试结果
 *
 */
- (void)sendRequest:(NSURLRequest *)request isUploadResult:(BOOL)isUpload
{
    isUploadResult = isUpload;
    [self sendRequest:request];
}

/**
 *  使用指定Request和日志文件目录进行对象初始化
 *
 *  @param request http请求
 *  @param path 上传文件的路径
 */
- (void)sendRequest:(NSURLRequest *)request WithFilePath:(NSString *)path
{
    filePath = path;
    isUploadLog = YES;

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

// 初始化弹出框并显示
- (void)showAlertView
{
    UIAlertView *warningView =
    [[UIAlertView alloc] initWithTitle:@""
                               message:I18N (@"Upload the test result failed, continue?")
                              delegate:self
                     cancelButtonTitle:I18N (@"Cancel")
                     otherButtonTitles:I18N (@"Continue"), nil];
    [warningView setTag:100];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:warningView];
    [warningView show];
}

// 点击按钮时间
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 判断是否是需要处理的alertView
    if (alertView.tag != 100)
    {
        return;
    }

    // 继续按钮的index是1
    if (buttonIndex == 1)
    {
        // 点击继续时，将failCount重置，然后继续发送请求
        failCount = 0;
        [self sendRequest:urlRequest];

        // 让alertView消失
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error)
    {
        // 如果是上传结果时失败，需要重试3次
        if (isUploadResult)
        {
            // 发送失败时继续请求
            if (failCount < 3)
            {
                SVError (@"result push error:%@", error);
                failCount++;
                [self sendRequest:urlRequest];
                return;
            }

            // 请求失败重试3次，然后弹出提示框
            if (failCount >= 3)
            {
                //                dispatch_async (dispatch_get_main_queue (), ^{
                //                  [self showAlertView];
                //                });
                SVInfo (@"result push failed！");
                return;
            }
        }

        // 如果是上传日志时成功，打印日志
        if (isUploadLog)
        {
            if (filePath)
            {
                // 删除文件
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:filePath error:nil];
                SVInfo (@"file has been deleted. file path:%@", filePath);
            }

            dispatch_async (dispatch_get_main_queue (), ^{
              NSString *title3 = I18N (@"Upload Failed");
              [SVToast showWithText:title3];

            });
            SVError (@"Upload log failed, error:%@", error);
            return;
        }
    }

    SVError (@"request URL:%@ fail.  Error:%@", _urlString, error);
    finished = true;
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

    // 如果是上传结果时成功，打印日志
    if (isUploadResult)
    {
        NSString *result = [[NSString alloc] initWithData:_allData encoding:NSUTF8StringEncoding];
        SVInfo (@"result push success %@", result);
    }

    // 如果是上传日志时成功，打印日志
    if (isUploadLog)
    {
        if (filePath)
        {
            // 删除文件
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:filePath error:nil];
            SVInfo (@"file has been deleted. file path:%@", filePath);
        }

        SVInfo (@"%@Upload sucess! ", filePath);
        dispatch_async (dispatch_get_main_queue (), ^{
          NSString *title2 = I18N (@"Upload Success");
          [SVToast showWithText:title2];
        });
    }
    finished = true;
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

    // 注意：这里将之前导入的证书设置成下面验证的Trust Object的anchor certificate
    SecTrustSetAnchorCertificates (trust, trustedCerArr);


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
@end
