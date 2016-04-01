//
//  SVDetailResultModel.h
//  SPUIView
//
//  Created by Rain on 2/13/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  测试结果明细。
 *
 *  CREATE TABLE
 *  IF NOT EXISTS SVDetailResultModel(
 *  ID integer PRIMARY KEY AUTOINCREMENT,
 *  testId integer,
 *  testType integer,
 *  resultJson text
 *  );
 */
@interface SVDetailResultModel : NSObject

@property NSString *ID;
@property NSString *testId;
@property NSString *testType;
@property NSString *testResult;
@property NSString *testContext;
@property NSString *probeInfo;

@end
