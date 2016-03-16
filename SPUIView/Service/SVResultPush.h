//
//  SVResultPush.h
//  SpeedPro
//
//  Created by 李灏 on 16/3/13.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVCurrentResultModel.h"
//#import "SVWarningView.h"
#import <Foundation/Foundation.h>

@interface SVResultPush : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>

- (id)initWithURLNSString:(NSString *)urlString testId:(NSNumber *)testId;

- (NSNumber *)string2num:(NSString *)str;

@end
