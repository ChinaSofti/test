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

// 唯一标示
@property (nonatomic, copy) NSString *ID;

// 测试例ID
@property (nonatomic, copy) NSString *testId;

// 网络类型
@property (nonatomic, copy) NSString *type;

// 测试时间
@property (nonatomic, copy) NSString *testTime;

// U-vMOS
@property (nonatomic, copy) NSString *UvMOS;

// 加载时间
@property (nonatomic, copy) NSString *loadTime;

// 带宽
@property (nonatomic, copy) NSString *bandwidth;

// 是否测试视频
@property (nonatomic, copy) NSString *videoTest;

// 是否测试网页
@property (nonatomic, copy) NSString *webTest;

// 是否测试带宽
@property (nonatomic, copy) NSString *speedTest;

@end
