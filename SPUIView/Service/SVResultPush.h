//
//  SVResultPush.h
//  SpeedPro
//
//  Created by 李灏 on 16/3/13.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVCurrentResultModel.h"
#import <Foundation/Foundation.h>

@interface SVResultPush : NSObject

- (id)initWithTestId:(long long)testId;

- (void)sendResult;

@end
