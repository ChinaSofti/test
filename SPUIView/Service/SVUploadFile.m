//
//  SVUploadFile.m
//  SpeedPro
//
//  Created by WBapple on 16/2/26.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVHttpsTools.h"
#import "SVProbeInfo.h"
#import "SVToast.h"
#import "SVUploadFile.h"

@implementation SVUploadFile
{
    NSString *_filePath;
}

//设置头
static NSString *useragent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_1 like Mac OS X) "
                             @"AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Mobile/9B206 "
                             @"Safari/601.3.9";

// 拼接字符串
static NSString *boundaryStr = @"--"; // 分隔字符串
static NSString *randomIDStr; // 本次上传标示字符串
static NSString *uploadID; // 上传(php)脚本中，接收文件字段
NSString *urlString = @"https://tools-speedpro.huawei.com/prolog/upload?mobileid=%@";

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        randomIDStr = @"speedprohaha";
        uploadID = @"uploadFile";
    }
    return self;
}

- (void)setShowToast:(BOOL)isShowToast
{
    _isShowToast = isShowToast;
}

#pragma mark - 私有方法
- (NSString *)topStringWithMimeType:(NSString *)mimeType uploadFile:(NSString *)uploadFile
{
    NSMutableString *strM = [NSMutableString string];
    [strM appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\n", uploadID, uploadFile];
    [strM appendFormat:@"Content-Type: %@\n\n", mimeType];
    return [strM copy];
}

- (NSString *)bottomString
{
    NSMutableString *strM = [NSMutableString string];
    [strM appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [strM appendString:@"Content-Disposition: form-data; name=\"submit\"\n\n"];
    [strM appendString:@"Submit\n"];
    [strM appendFormat:@"%@%@--\n", boundaryStr, randomIDStr];
    return [strM copy];
}

#pragma mark - 上传文件

- (void)uploadFile:(NSString *)filePath
{
    // UUID
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSString *uuid = [probeInfo getUUID];
    NSString *url_str = [NSString stringWithFormat:urlString, uuid];

    SVInfo (@"upload log file[%@] to Server[%@]", filePath, url_str);
    [self uploadFileWithURL:[NSURL URLWithString:url_str] filePath:filePath];
}

- (void)uploadFileWithURL:(NSURL *)url filePath:(NSString *)filePath
{
    NSString *title1 = I18N (@"Uploading");
    [self showToastForUser:title1];

    _filePath = filePath;
    NSData *data = [NSData dataWithContentsOfFile:_filePath];
    [self uploadFileWithURL:url data:data];
}


#pragma mark - 上传文件
- (void)uploadFileWithURL:(NSURL *)url data:(NSData *)data
{
    // 1> 数据体
    NSString *topStr = [self topStringWithMimeType:@"image/png" uploadFile:@"头像1.png"];
    NSString *bottomStr = [self bottomString];
    NSMutableData *dataM = [NSMutableData data];
    [dataM appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:data];
    [dataM appendData:[bottomStr dataUsingEncoding:NSUTF8StringEncoding]];

    // 1. Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    // dataM出了作用域就会被释放,因此不用copy
    request.HTTPBody = dataM;

    // 2> 设置Request的头属性
    request.HTTPMethod = @"POST";

    // 3> 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%ld", (long)dataM.length];
    [request setValue:strLength forHTTPHeaderField:@"Content-Length"];

    // 4> 设置Content-Type
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", randomIDStr];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];

    // 5> 设置User-Agent(请求头)
    [request setValue:useragent forHTTPHeaderField:@"User-Agent"];

    [self sendResultToServer:request];
}

- (void)sendResultToServer:(NSURLRequest *)request
{
    // 连接服务器发送结果
    SVHttpsTools *httpsTools = [[SVHttpsTools alloc] init];
    [httpsTools sendRequest:request
          completionHandler:^(NSData *responseData, NSError *error) {
            // 上报结果失败
            if (error)
            {
                SVError (@"retry send result to server. result push error:%@ ", error);
                NSString *title2 = I18N (@"Upload Failed");
                [self showToastForUser:title2];
                return;
            }

            NSString *mesg =
            [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            SVInfo (@"upload log file success. response data from server:%@", mesg);

            NSString *title2 = I18N (@"Upload Success");
            [self showToastForUser:title2];
          }];
}

/**
 * 弹出提示信息，告知用户
 */
- (void)showToastForUser:(NSString *)mesg
{
    if (!_isShowToast)
    {
        return;
    }

    // 弹出提示信息，告知用户上传日志成功
    dispatch_async (dispatch_get_main_queue (), ^{
      [SVToast showWithText:mesg];
    });
}

@end