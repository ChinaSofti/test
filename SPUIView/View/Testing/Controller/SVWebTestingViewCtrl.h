//
//  SVWebTestingViewCtrl.h
//  SpeedPro
//
//  Created by WBapple on 16/3/8.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

/**
 *  网页测试中界面
 */

#import "SVCurrentResultModel.h"
#import "SVWebTest.h"
#import <UIKit/UIKit.h>

@interface SVWebTestingViewCtrl : UIViewController <SVWebTestDelegate>

@property SVCurrentResultModel *currentResultModel;

- (id)initWithResultModel:(SVCurrentResultModel *)resultModel;

@end
