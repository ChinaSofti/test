//
//  SVResultPush.h
//  SpeedPro
//
//  Created by 李灏 on 16/3/13.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVCurrentResultModel.h"
#import <Foundation/Foundation.h>

typedef void (^CompletionHandler) (NSData *responseData, NSError *error);

@interface SVResultPush : NSObject
{
    CompletionHandler _handler;
}

- (id)initWithTestId:(long long)testId;

- (void)sendResult:(CompletionHandler)handler;

@end
