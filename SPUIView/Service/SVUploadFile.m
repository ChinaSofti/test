//
//  SVUploadFile.m
//  SpeedPro
//
//  Created by WBapple on 16/2/26.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVHttpsTools.h"
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
- (void)uploadFileWithURL:(NSURL *)url filePath:(NSString *)filePath
{
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

    // 6> 连接服务器发送请求
    SVHttpsTools *httpsTools = [[SVHttpsTools alloc] init];
    [httpsTools sendRequest:request WithFilePath:_filePath];
}

@end