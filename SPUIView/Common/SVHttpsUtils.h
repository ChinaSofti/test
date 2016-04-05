//
//  SVHttpsUtils.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/4/5.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVHttpsUtils : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>

- (id)initWithRequest:(NSURLRequest *)request;

- (void)sendHttpsRequest;

@end
