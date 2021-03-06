//
//  SVWebTestingViewCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/3/8.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

//主View下的4个子View
#import "SVFooterView.h"
#import "SVHeaderView.h"
#import "SVLabelTools.h"
#import "SVPointView.h"
#import "SVProbeInfo.h"
#import "SVProgressView.h"
#import "SVWebTest.h"
#import "SVWebTestingViewCtrl.h"
#import "SVWebView.h"


#define kVideoViewDefaultRect \
    CGRectMake (FITWIDTH (10), FITWIDTH (420), FITWIDTH (150), FITWIDTH (92))

@interface SVWebTestingViewCtrl ()
{

    SVHeaderView *_headerView; // 定义headerView
    SVPointView *_webtestingView; //定义webtestingView
    SVFooterView *_footerView; // 定义footerView

    // 测试地址的label
    UILabel *_testUrlLabel;

    // 测试地址标题的label
    UILabel *_testUrlTitle;
    //进度条
    SVProgressView *pro;
    float value;

    // 当前页面的主窗口
    UIWindow *window;

    // 上一条测试的url
    NSString *lastUrl;
}

//定义gray遮挡View
@property (nonatomic, strong) UIView *gyview;


@end

@implementation SVWebTestingViewCtrl

@synthesize currentResultModel;

- (id)initWithResultModel:(SVCurrentResultModel *)resultModel
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    currentResultModel = resultModel;

    // 获取整个屏幕的window
    window = [UIApplication sharedApplication].keyWindow;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SVInfo (@"SVWebTestingCtrl");

    // 初始化标题
    [super initTitleView];

    // 初始化返回按钮
    [super initBackButtonWithTarget:self action:@selector (removeButtonClicked:)];

    // 设置背景颜色
    self.view.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];

    // 添加方法
    [self creatHeaderView];
    [self creatWebTestingView];
    [self creatFooterView];
}
//退出测试按钮点击事件
- (void)removeButtonClicked:(UIButton *)button
{
    NSString *title1 = I18N (@"Test stopped");
    NSString *title2 = I18N (@"Are you sure you want to exit the test");
    NSString *title3 = I18N (@"No");
    NSString *title4 = I18N (@"Yes");

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title1
                                                    message:title2
                                                   delegate:self
                                          cancelButtonTitle:title3
                                          otherButtonTitles:title4, nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        SVInfo (@"取消了此次测试");
        [[self.currentResultModel navigationController] popToRootViewControllerAnimated:NO];
    }
    SVInfo (@"继续测试");
}

/**
 *  初始化当前页面和全局变量
 */
- (void)initContext
{
    [_headerView updateLeftValue:@"N/A" WithUnit:@""];
    [_headerView updateMiddleValue:@"N/A" WithUnit:@""];
    [_headerView updateRightValue:@"N/A" WithUnit:@""];

    [_testUrlLabel setText:I18N (@"Loading...")];
    [_webtestingView updateValue:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    SVProbeInfo *probe = [[SVProbeInfo alloc] init];
    [probe setIsTesting:YES];

    // 设置屏幕不会休眠
    //    [UIApplication sharedApplication].idleTimerDisabled = YES;

    // 显示tabbar 和navigationbar
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;

    // 初始化进度条
    pro = [[SVProgressView alloc] initWithheight:NavBarH];
    value = 0.0;
    [self.view addSubview:pro];

    // 添加覆盖gyview(为了防止用户在测试的过程中点击按钮)
    // 将当前view的window设置为主窗口
    [window makeKeyAndVisible];

    // 创建一个覆盖garyView
    _gyview = [[UIView alloc] initWithFrame:CGRectMake (0, kScreenH - 200, kScreenW, 200)];

    // 设置透明度
    _gyview.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.0];

    // 添加
    [window addSubview:_gyview];

    // 初始化页面
    [self initContext];


    // 进入页面时，开始测试
    _webTest = [[SVWebTest alloc] initWithView:self.currentResultModel.testId
                                   showWebView:_footerView.leftView
                                  testDelegate:self];
    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      BOOL isOK = [_webTest initTestContext];
      if (isOK)
      {
          [_webTest startTest];
      }
      else
      {
          [_webTest resetResult];
          dispatch_async (dispatch_get_main_queue (), ^{
            [self goToCurrentResultViewCtrl];
          });
      }
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    // 当用户离开当前页面时，停止测试
    if (_webTest)
    {
        [_webTest stopTest];

        _insertSVDetailResultModelSQL = [_webTest getPersistDataSQL];

        //移除覆盖gyView
        [_gyview removeFromSuperview];
    }

    [super viewWillDisappear:animated];
}

#pragma mark - 创建头headerView

- (void)creatHeaderView
{
    // 初始化默认值
    NSMutableDictionary *defalutValue = [[NSMutableDictionary alloc] init];
    [defalutValue setValue:[UIFont systemFontOfSize:pixelToFontsize (36)] forKey:@"labelFontSize"];
    [defalutValue setValue:[UIColor colorWithHexString:@"#000000"] forKey:@"labelColor"];
    [defalutValue setValue:[UIFont systemFontOfSize:pixelToFontsize (60)] forKey:@"valueFontSize"];
    [defalutValue setValue:[UIColor colorWithHexString:@"#38C695"] forKey:@"valueColor"];
    [defalutValue setValue:[UIFont systemFontOfSize:pixelToFontsize (33)] forKey:@"unitFontSize"];
    [defalutValue setValue:[UIColor colorWithHexString:@"#38C695"] forKey:@"unitColor"];
    [defalutValue setValue:@"N/A" forKey:@"leftDefaultValue"];
    [defalutValue setValue:I18N (@"Response Time") forKey:@"leftTitle"];
    [defalutValue setValue:@"" forKey:@"leftUnit"];
    [defalutValue setValue:@"N/A" forKey:@"middleDefaultValue"];
    [defalutValue setValue:I18N (@"Download Speed") forKey:@"middleTitle"];
    [defalutValue setValue:@"" forKey:@"middleUnit"];
    [defalutValue setValue:@"N/A" forKey:@"rightDefaultValue"];
    [defalutValue setValue:I18N (@"Load duration") forKey:@"rightTitle"];
    [defalutValue setValue:@"" forKey:@"rightUnit"];


    // 初始化headerView
    _headerView = [[SVHeaderView alloc] initWithDic:defalutValue];

    // 把headerView添加到中整个视图上
    [self.view addSubview:_headerView];
}

#pragma mark - 创建测试中webtestingView

- (void)creatWebTestingView
{
    // 初始化默认值
    NSMutableDictionary *defalutValue = [[NSMutableDictionary alloc] init];
    [defalutValue setValue:I18N (@"Load duration") forKey:@"title"];
    [defalutValue setValue:@"0.00" forKey:@"defaultValue"];
    [defalutValue setValue:@"s" forKey:@"unit"];
    [defalutValue setValue:@"web" forKey:@"testType"];

    // 初始化整个testingView
    _webtestingView = [[SVPointView alloc] initWithDic:defalutValue];
    [_webtestingView start];

    [self.view addSubview:_webtestingView];
}

#pragma mark - 创建尾footerView

- (void)creatFooterView
{
    //初始化headerView
    _footerView = [[SVFooterView alloc] init];

    // 初始化测试地址的label
    _testUrlLabel = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (50), FITHEIGHT (106), FITWIDTH (446), FITHEIGHT (50))
                withFont:pixelToFontsize (45)
          withTitleColor:[UIColor colorWithHexString:@"#000000"]
               withTitle:@""];

    // 初始化测试地址标题的label
    _testUrlTitle = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (50), _testUrlLabel.bottomY + FITHEIGHT (16),
                                     FITWIDTH (446), FITWIDTH (34))
                withFont:pixelToFontsize (36)
          withTitleColor:[UIColor colorWithHexString:@"#000000"]
               withTitle:I18N (@"Test Url")];

    // 设置Label对齐
    _testUrlLabel.textAlignment = NSTextAlignmentLeft;
    _testUrlTitle.textAlignment = NSTextAlignmentLeft;

    // 将所有label放入右侧的View
    [_footerView.rightView addSubview:_testUrlLabel];
    [_footerView.rightView addSubview:_testUrlTitle];

    [self.view addSubview:_footerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**********************************以下为UI数据层代码**********************************/
- (void)updateTestResultDelegate:(SVWebTestContext *)testContext
                      testResult:(SVWebTestResult *)testResult
{

    // 响应时间
    double responseTime = testResult.responseTime;

    // 完整下载时间
    double totalTime = testResult.totalTime;

    // 测试地址
    NSString *testUrl = testResult.testUrl;

    // 去掉测试地址中的http头
    NSArray *strArray = [testUrl componentsSeparatedByString:@"/"];
    if ([strArray count] >= 3)
    {
        testUrl = strArray[2];
    }
    else
    {
        testUrl = strArray[0];
    }

    //进度条
    if ((!lastUrl || ![lastUrl isEqualToString:testUrl]) && testResult.finished)
    {
        //柱状图更新
        value += (1.0 / [testContext.urlArray count]);
        [pro setProgress:value];

        // 记录测试过的url
        lastUrl = testUrl;
    }

    // 下载速度
    double downloadSpeed = testResult.downloadSpeed;

    dispatch_async (dispatch_get_main_queue (), ^{

      // 测试完成跳转到
      if (testContext.testStatus == TEST_FINISHED)
      {
          // 如果测试结束，进度条直接走完
          [pro setProgress:1.0];

          [self initCurrentResultModel:testResult];
          [self goToCurrentResultViewCtrl];
          return;
      }

      // 成功的时候显示指标值
      if (totalTime < 10 && totalTime >= 0)
      {
          // 显示头部指标
          [_headerView updateLeftValue:[NSString stringWithFormat:@"%.2f", responseTime]
                              WithUnit:@"s"];
          [_headerView updateMiddleValue:[NSString stringWithFormat:@"%.2f", downloadSpeed]
                                WithUnit:@"Kbps"];
          [_headerView updateRightValue:[NSString stringWithFormat:@"%.2f", totalTime]
                               WithUnit:@"s"];

          // 仪表盘指标
          [_webtestingView updateValue:totalTime];

          // 测试地址
          [_testUrlLabel setText:testUrl];

          // label自动换行
          [SVLabelTools wrapForLabel:_testUrlLabel nextLabel:_testUrlTitle];
          return;
      }

      // 失败的情况显示超时
      // 显示头部指标
      [_headerView updateLeftValue:[NSString stringWithFormat:@"%@", I18N (@"Timeout")]
                          WithUnit:@""];
      [_headerView updateMiddleValue:[NSString stringWithFormat:@"%@", I18N (@"Timeout")]
                            WithUnit:@""];
      [_headerView updateRightValue:[NSString stringWithFormat:@"%@", I18N (@"Timeout")]
                           WithUnit:@""];

      // 仪表盘指标
      [_webtestingView updateValue:0];
      [_webtestingView.valueLabel setText:[NSString stringWithFormat:@"%@", I18N (@"Timeout")]];
      [_webtestingView.unitLabel setText:@""];
      [SVLabelTools resetLayoutWithValueLabel:_webtestingView.valueLabel
                                    UnitLabel:_webtestingView.unitLabel
                                    WithWidth:kScreenW
                                   WithHeight:FITHEIGHT (100)
                                        WithY:FITHEIGHT (604)];

      // 测试地址
      [_testUrlLabel setText:testUrl];
      return;
    });
}

- (void)initCurrentResultModel:(SVWebTestResult *)testResult
{
    [currentResultModel setResponseTime:testResult.responseTime];
    [currentResultModel setTotalTime:testResult.totalTime];
    [currentResultModel setDownloadSpeed:testResult.downloadSpeed];
}

- (void)goToCurrentResultViewCtrl
{
    // push界面
    [currentResultModel pushNextCtrl];
}

/**
 * 停止测试
 */
- (void)stopTest
{
    // 停止测试例
    if (_webTest)
    {
        [_webTest stopTest];
    }

    // 停止进度条的定时器
    if (pro)
    {
        [pro cancelTimer];
    }
}

/**
 * 重置测试结果
 */
- (void)resetResult
{
    [_webTest resetResult];
}

@end