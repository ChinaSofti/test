//
//  SVVideoTestingCtrl.h
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//


/**
 *  视频测试中界面
 */

#import "SVCurrentResultModel.h"
#import "SVVideoTest.h"

@interface SVVideoTestingCtrl : SVViewController <SVVideoTestDelegate>

@property (nonatomic, retain) SVCurrentResultModel *currentResultModel;


- (id)initWithResultModel:(SVCurrentResultModel *)resultModel;

@end
