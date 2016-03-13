//
//  SVCurrentResultModel.m
//  SPUIView
//
//  Created by Rain on 2/14/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVCurrentResultModel.h"

@implementation SVCurrentResultModel
{
    // 需要测试的controller数组
    NSMutableArray *_ctrlArray;

    // 已经完成的controller数组
    NSMutableArray *_completeCtrlArray;
}


@synthesize selectedA, navigationController, tabBarController, testId, videoTest, uvMOS,
firstBufferTime, cuttonTimes, webTest, responseTime, totalTime, downloadSpeed;

// 初始化
- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    // 初始化controller数组
    _ctrlArray = [[NSMutableArray alloc] init];
    _completeCtrlArray = [[NSMutableArray alloc] init];

    // 将指标值都设置为-1
    self.uvMOS = -1.0f;
    self.firstBufferTime = -1.0f;
    self.cuttonTimes = -1;
    self.responseTime = -1.0f;
    self.totalTime = -1.0f;
    self.downloadSpeed = -1.0f;
    self.stDelay = -1.0f;
    self.stDownloadSpeed = -1.0f;
    self.stUploadSpeed = -1.0f;

    return self;
}

/**
 *  推送到controller界面
 */
- (void)pushNextCtrl
{
    // push界面
    if (_ctrlArray && _ctrlArray.count > 0)
    {
        // 从数组中取出controller
        id nextCtrl = _ctrlArray[0];
        if (nextCtrl)
        {
            // 将controller从需要推送的数组中移除
            [_ctrlArray removeObjectAtIndex:0];

            // 将已经推送的controller放入数组
            [_completeCtrlArray addObject:nextCtrl];

            // 返回根界面
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self.navigationController pushViewController:nextCtrl animated:NO];
        }
    }
}

// 向需要推送的controller数组中添加数据
- (void)addCtrl:(UIViewController *)ctrl
{
    [_ctrlArray addObject:ctrl];
}

// 将已经推送完成的controller重新放入待推送的controller数组，并将已经推送完成的controller数组清空
- (void)copyCompleteCtrlToCtrlArray
{
    if (!_completeCtrlArray)
    {
        return;
    }
    [_ctrlArray addObjectsFromArray:_completeCtrlArray];
    [_completeCtrlArray removeAllObjects];
}

@end
