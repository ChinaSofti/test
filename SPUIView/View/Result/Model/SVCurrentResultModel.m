//
//  SVCurrentResultModel.m
//  SPUIView
//
//  Created by Rain on 2/14/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVCurrentResultModel.h"
#import "SVCurrentResultViewCtrl.h"
#import "SVSpeedTestingViewCtrl.h"
#import "SVTimeUtil.h"
#import "SVWebTestingViewCtrl.h"

@implementation SVCurrentResultModel
{
    // 需要测试的controller数组
    NSMutableArray *_ctrlArray;

    // 已经完成的controller数组
    NSMutableArray *_completeCtrlArray;

    // 当前控制器
    id currentCtrl;

    // 是否停止测试
    BOOL isStoped;
}


@synthesize selectedA, navigationController, tabBarController, testId, videoTest, uvMOS,
firstBufferTime, cuttonTimes, webTest, responseTime, totalTime, downloadSpeed, speedTest, stDelay,
stDownloadSpeed, stUploadSpeed, stIsp, stLocation;

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
    isStoped = NO;

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

    // 获取通知中心单例对象
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    // 添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [center addObserver:self
               selector:@selector (alertMessage:)
                   name:@"networkStatusChange"
                 object:nil];

    return self;
}

/**
 * 当网络中断时弹出提示信息
 */
- (void)alertMessage:(id)sender
{
    // 如果已经到了当前测试结果界面则不需要弹出提示信息
    if ([currentCtrl isKindOfClass:[SVCurrentResultViewCtrl class]])
    {
        return;
    }

    // 如果当前界面没有显示则直接返回
    if (![currentCtrl isVisible])
    {
        return;
    }

    // 设置状态
    isStoped = YES;

    // 停止测视
    [currentCtrl stopTest];

    // 弹出提示框
    dispatch_async (dispatch_get_main_queue (), ^{
      NSString *title1 = I18N (@"Prompt");
      NSString *title2 = I18N (@"Test Fail. Check Network");
      NSString *title3 = I18N (@"Cancel Test");
      NSString *title4 = I18N (@"Continue Test");
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:title1
                                                                     message:title2
                                                              preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *continueAction =
      [UIAlertAction actionWithTitle:title3
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                               SVInfo (@"取消了此次测试");
                               [self clearAllCtrl];
                               [[self navigationController] popToRootViewControllerAnimated:NO];
                             }];

      UIAlertAction *stopTestAction = [UIAlertAction actionWithTitle:title4
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                               // push界面
                                                               SVInfo (@"继续测试");
                                                               isStoped = NO;
                                                               [self pushNextCtrl];
                                                             }];

      [alert addAction:continueAction];
      [alert addAction:stopTestAction];
      [currentCtrl presentViewController:alert animated:YES completion:nil];
    });
}


/**
 *  推送到controller界面
 */
- (void)pushNextCtrl
{
    // 如果测试已经停止则直接返回
    if (isStoped)
    {
        return;
    }

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

            // 记录当前测试界面
            currentCtrl = nextCtrl;

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

    [self setTestId:[SVTimeUtil currentMilliSecondStamp]];
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

    for (UIViewController *control in _completeCtrlArray)
    {
        if ([control isKindOfClass:[SVVideoTestingCtrl class]])
        {
            // 按钮点击后alloc一个界面
            SVVideoTestingCtrl *videotestingCtrl = [[SVVideoTestingCtrl alloc] initWithResultModel:self];
            [self setVideoTest:YES];
            [self addCtrl:videotestingCtrl];
            continue;
        }

        if ([control isKindOfClass:[SVWebTestingViewCtrl class]])
        {
            SVWebTestingViewCtrl *webtestingCtrl = [[SVWebTestingViewCtrl alloc] initWithResultModel:self];
            [self setWebTest:YES];
            [self addCtrl:webtestingCtrl];
            continue;
        }

        if ([control isKindOfClass:[SVSpeedTestingViewCtrl class]])
        {
            SVSpeedTestingViewCtrl *speedtestingCtrl =
            [[SVSpeedTestingViewCtrl alloc] initWithResultModel:self];
            [self setSpeedTest:YES];
            [self addCtrl:speedtestingCtrl];
            continue;
        }
    }

    SVCurrentResultViewCtrl *currentResultView = [[SVCurrentResultViewCtrl alloc] initWithResultModel:self];
    [self addCtrl:currentResultView];

    [_completeCtrlArray removeAllObjects];
}

/**
 *  获取所有测试对象
 *
 *  @return 所有测试对象
 */
- (NSArray *)testObjArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (UIViewController *control in _completeCtrlArray)
    {
        if ([control isKindOfClass:[SVVideoTestingCtrl class]])
        {
            SVVideoTestingCtrl *ctrl = (SVVideoTestingCtrl *)control;
            NSString *sql = ctrl.insertSVDetailResultModelSQL;
            if (sql)
            {
                [array addObject:sql];
            }
            continue;
        }

        if ([control isKindOfClass:[SVWebTestingViewCtrl class]])
        {
            SVWebTestingViewCtrl *ctrl = (SVWebTestingViewCtrl *)control;
            NSString *sql = ctrl.insertSVDetailResultModelSQL;
            if (sql)
            {
                [array addObject:sql];
            }

            continue;
        }

        if ([control isKindOfClass:[SVSpeedTestingViewCtrl class]])
        {
            SVSpeedTestingViewCtrl *ctrl = (SVSpeedTestingViewCtrl *)control;
            NSString *sql = ctrl.insertSVDetailResultModelSQL;
            if (sql)
            {
                [array addObject:sql];
            }
            continue;
        }
    }
    return array;
}

/**
 * 清理所有的控制器
 */
- (void)clearAllCtrl
{
    [_ctrlArray removeAllObjects];
    [_completeCtrlArray removeAllObjects];
}

// 一般在监听器销毁之前取消注册
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
