//
//  SVDetailViewCtrl.h
//  SPUIView
//
//  Created by WBapple on 16/2/14.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

/**
 *  详情结果页面
 */

#import <UIKit/UIKit.h>

@interface SVDetailViewCtrl : SVViewController
@property long long testId; // 测试ID
@property NSString *testType; // 测试类型：0=video,1=web,2=speed

@end
