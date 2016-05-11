//
//  SVHtmlTools.h
//  SpeedPro
//
//  Created by JinManli on 16/5/11.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVHtmlTools : NSObject

/**
 * 创建WKWebView并且加载内置网页
 */
- (void)createWebViewWithFileName:(NSString *)fileName superView:(UIView *)superView;

@end
