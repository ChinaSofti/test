//
//  SVHtmlTools.m
//  SpeedPro
//
//  Created by JinManli on 16/5/11.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVHtmlTools.h"

@implementation SVHtmlTools

/**
 * 加载内置网页
 */
- (void)loadHtmlWithFileName:(NSString *)fileName webView:(WKWebView *)webView
{
    //调用逻辑
    NSString *htmlPath = [NSString stringWithFormat:@"file://%@", [self getHtmlPathWithFileName:fileName]];
    SVInfo (@"load FAQ html from resource directory. URL:%@", htmlPath);
    NSURL *fileURL = [NSURL URLWithString:htmlPath];

    if (fileURL)
    {
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
        {
            // iOS9. One year later things are OK.
            [webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        }
        else
        {
            // iOS8. Things can be workaround-ed
            //   Brave people can do just this
            //   fileURL = try! pathForBuggyWKWebView8(fileURL)
            //   webView.loadRequest(NSURLRequest(URL: fileURL))
            NSURL *url = [self fileURLForBuggyWKWebView8:fileURL];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
        }
    }
}

//将文件copy到tmp目录
- (NSURL *)fileURLForBuggyWKWebView8:(NSURL *)fileURL
{
    NSError *error = nil;
    if (!fileURL.fileURL || ![fileURL checkResourceIsReachableAndReturnError:&error])
    {
        return nil;
    }
    // Create "/temp/www" directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory ()] URLByAppendingPathComponent:@"www"];
    [fileManager createDirectoryAtURL:temDirURL
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];

    NSURL *dstURL = [temDirURL URLByAppendingPathComponent:fileURL.lastPathComponent];
    // Now copy given file to the temp directory
    [fileManager removeItemAtURL:dstURL error:&error];
    [fileManager copyItemAtURL:fileURL toURL:dstURL error:&error];
    // Files in "/temp/www" load flawlesly :)
    return dstURL;
}

- (NSString *)getHtmlPathWithFileName:(NSString *)fileName
{
    // 资源目录
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirArray = [fileManager subpathsAtPath:resourcePath];
    SVI18N *i18n = [SVI18N sharedInstance];
    NSString *language = [i18n getLanguage];

    NSString *playerHtmlPath;
    for (NSString *path in dirArray)
    {
        if ([path containsString:@"html"])
        {
            NSLog (@"%@", path);
        }
        if ([language containsString:@"en"] &&
            [path containsString:[NSString stringWithFormat:@"%@_en.html", fileName]])
        {
            playerHtmlPath = [resourcePath stringByAppendingPathComponent:path];
            break;
        }
        else if ([language containsString:@"zh"] &&
                 [path containsString:[NSString stringWithFormat:@"%@_cn.html", fileName]])
        {
            playerHtmlPath = [resourcePath stringByAppendingPathComponent:path];
            break;
        }
    }

    return playerHtmlPath;
}

@end
