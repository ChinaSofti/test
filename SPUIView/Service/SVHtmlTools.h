//
//  SVHtmlTools.h
//  SpeedPro
//
//  Created by JinManli on 16/5/11.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface SVHtmlTools : NSObject

/**
 * 加载内置网页
 */
- (void)loadHtmlWithFileName:(NSString *)fileName webView:(WKWebView *)webView;

@end
