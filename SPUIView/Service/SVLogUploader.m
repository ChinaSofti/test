//
//  SVLogUploader.m
//  SpeedPro
//
//  Created by Rain on 2/22/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVLogUploader.h"

//#define UPLOAD_SERVER_URL @"https:// 58.60.106.188:12210/speedpro/uploading"

@implementation SVLogUploader

// 拼接字符串
static NSString *boundaryStr = @"--"; // 分隔字符串
static NSString *randomIDStr; // 本次上传标示字符串
static NSString *uploadID; // 上传(php)脚本中，接收文件字段

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        randomIDStr = @"ios_speedpr_log";
        uploadID = @"uploadFile";
    }
    return self;
}

/**
 *  上传日志文件
 */
- (void)upload
{
    SVLog *log = [SVLog sharedInstance];
    NSString *logFilePath = [log compressLogFiles];
    if (!logFilePath)
    {
        SVError (@"file of upload not exists.");
        return;
    }

    // 1> 数据体
    NSData *data = [NSData dataWithContentsOfFile:logFilePath];
    //    NSLog (@"%@", logFilePath.lastPathComponent);
    NSString *topStr =
    [self topStringWithMimeType:@"application/zip" uploadFile:logFilePath.lastPathComponent];
    NSString *bottomStr = [self bottomString];

    NSMutableData *dataM = [NSMutableData data];
    [dataM appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:data];
    [dataM appendData:[bottomStr dataUsingEncoding:NSUTF8StringEncoding]];

    // 1. Request
    NSURL *url = [NSURL URLWithString:@"https:// 58.60.106.188:12210/speedpro/uploading"];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:2.0f];

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

    // 3> 连接服务器发送请求
    [NSURLConnection
    sendAsynchronousRequest:request
                      queue:[[NSOperationQueue alloc] init]
          completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

            if (connectionError)
            {
                SVError (@"%@", connectionError);
                return;
            }

            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SVInfo (@"%@", result);
          }];
}

#pragma mark - 私有方法
- (NSString *)topStringWithMimeType:(NSString *)mimeType uploadFile:(NSString *)uploadFile
{
    NSMutableString *strM = [NSMutableString string];

    [strM appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\n", uploadID, uploadFile];
    [strM appendFormat:@"Content-Type: %@\n\n", mimeType];

    SVInfo (@"%@", strM);
    return [strM copy];
}

- (NSString *)bottomString
{
    NSMutableString *strM = [NSMutableString string];

    [strM appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [strM appendString:@"Content-Disposition: form-data; name=\"submit\"\n\n"];
    [strM appendString:@"Submit\n"];
    [strM appendFormat:@"%@%@--\n", boundaryStr, randomIDStr];

    SVInfo (@"%@", strM);
    return [strM copy];
}


@end
