//
//  SVConfigServerURL.h
//  SpeedPro
//
//  Created by WBapple on 16/5/12.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVConfigServerURL : NSObject

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance;
/**
 *  设置默认的URL
 *
 *  @param URL URL字符串
 */
- (void)setConfigServerUrl:(NSString *)URL;
/**
 *  获得默认的url
 *
 *  @return url字符串
 */
- (NSString *)getConfigServerUrl;
/**
 *  设置默认的url列表
 *
 *  @param Array 字符串的数组
 */
- (void)setConfigServerUrlListArray:(NSArray *)Array;
/**
 *  获取的url列表
 *
 *  @return url列表数组
 */
- (NSArray *)getConfigServerUrlListArray;
@end
