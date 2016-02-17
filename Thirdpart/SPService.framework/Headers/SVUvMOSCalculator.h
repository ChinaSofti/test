//
//  SVUvMOSCalculater.h
//  SPUIView
//
//  Created by Rain on 2/10/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVVideoTestContext.h"
#import "SVVideoTestResult.h"
#import "SVVideoTestSample.h"
#import <Foundation/Foundation.h>

@interface SVUvMOSCalculator : NSObject

/**
 *  初始化UvMOS值计算器
 *
 *  @param testContext Test Context
 *  @param testResult Test Result
 *
 *  @return UvMOS值计算器
 */
- (id)initWithTestContextAndResult:(SVVideoTestContext *)testContext
                        testResult:(SVVideoTestResult *)testResult;

- (void)registeService;

/**
 *  计算样本的UvMOS
 *
 *  @param testSample SVVideoTestSample
 */
- (void)calculateTestSample:(SVVideoTestSample *)testSample;

- (void)unRegisteService;
@end
