//
//  SVSummaryResultModel.h
//  SPUIView
//
//  Created by XYB on 16/2/1.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  APP结果页面显示的数据表。
 *
 *  CREATE TABLE
 *  IF NOT EXISTS SVSummaryResultModel(
 *  ID integer PRIMARY KEY AUTOINCREMENT,
 *  testId integer,
 *  type integer,
 *  testTime integer,
 *  UvMOS real,
 *  loadTime integer,
 *  bandwidth real
 *  );
 */
@interface SVSummaryResultModel : NSObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *testId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *testTime;
@property (nonatomic, copy) NSString *UvMOS;
@property (nonatomic, copy) NSString *loadTime;
@property (nonatomic, copy) NSString *bandwidth;


@end
