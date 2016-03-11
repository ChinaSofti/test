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
    NSMutableArray *_ctrlArray;
}


@synthesize selectedA, navigationController, tabBarController, testId, videoTest, uvMOS,
firstBufferTime, cuttonTimes, webTest, responseTime, totalTime, downloadSpeed;

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    _ctrlArray = [[NSMutableArray alloc] init];
    return self;
}

- (void)pushNextCtrl
{
    // push界面
    if (_ctrlArray)
    {
        id nextCtrl = _ctrlArray[0];
        if (nextCtrl)
        {
            [_ctrlArray removeObjectAtIndex:0];
            [self.navigationController pushViewController:nextCtrl animated:YES];
        }
    }
}

- (void)addCtrl:(UIViewController *)ctrl
{
    [_ctrlArray addObject:ctrl];
}

@end
