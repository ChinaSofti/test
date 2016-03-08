//
//  SVSystemUtil.h
//  SPUIView
//
//  Created by Rain on 2/10/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <arpa/inet.h>

@interface SVSystemUtil : NSObject

/**
 *  获取当前系统语言
 *
 *  @return 当前系统语言
 */
+ (NSString *)currentSystemLanguage;

@end
