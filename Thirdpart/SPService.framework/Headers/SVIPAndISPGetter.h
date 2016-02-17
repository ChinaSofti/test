//
//  TSIPAndISPGetter.h
//  TaskService
//
//  Created by Rain on 1/27/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVIPAndISP.h"
#import <Foundation/Foundation.h>

@interface SVIPAndISPGetter : NSObject

/**
 *  获取本机IP，归属地，运营商等信息
 *
 *  @return TSIPAndISP 本机IP，归属地，运营商等信息
 */
+ (SVIPAndISP *)getIPAndISP;

/**
 *  根据IP查询归属地和运营商等信息。目前只支持两种语言的返回结果，英文和中文。缺省采用系统语言进行查询，并返回结果
 *
 *  @param ip IP地址
 *
 *  @return IP归属地
 */
+ (SVIPAndISP *)queryIPDetail:(NSString *)ip;

@end
