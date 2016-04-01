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
#import "SVPointView.h"
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
    SVWebTest *_webTest;

    // 测试地址的label
    UILabel *_testUrlLabel;

    // 测试地址标题的label
    UILabel *_testUrlTitle;
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
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    SVInfo (@"SVWebTestingCtrl");

    //添加返回按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, 45, 23)];
    [button setImage:[UIImage imageNamed:@"homeindicator"] forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *back0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil
                                                                           action:nil];
    back0.width = -15;
    self.navigationItem.leftBarButtonItems = @[back0, backButton];

    [button addTarget:self
               action:@selector (removeButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside];

    // 为了保持平衡添加一个leftBtn
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, 44, 44)];
    UIBarButtonItem *backButton1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.rightBarButtonItem = backButton1;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    // 2.设置整个Viewcontroller
    // 设置背景颜色
    self.view.backgroundColor =
    [UIColor colorWithRed:250 / 255.0 green:250 / 255.0 blue:250 / 255.0 alpha:1.0];

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
    [_testUrlLabel setText:I18N (@"Loading...")];
    [_headerView.ResponseLabel setText:@"0"];
    [_headerView.LoadLabel setText:@"0"];
    [_headerView.DownloadLabel setText:@"0"];
    [_webtestingView updateValue:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // 显示tabbar 和navigationbar
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;

    //添加覆盖gyview(为了防止用户在测试的过程中点击按钮)
    //获取整个屏幕的window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //创建一个覆盖garyView
    _gyview = [[UIView alloc] initWithFrame:CGRectMake (0, kScreenH - 200, kScreenW, 200)];
    //设置透明度
    _gyview.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.0];
    //添加
    [window addSubview:_gyview];
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
    [super viewWillDisappear:animated];

    dispatch_async (dispatch_get_main_queue (), ^{
      // 当用户离开当前页面时，停止测试
      if (_webTest)
      {
          [_webTest stopTest];

          //移除覆盖gyView
          [_gyview removeFromSuperview];
      }
    });
}

#pragma mark - 创建头headerView

- (void)creatHeaderView
{
    //初始化headerView
    _headerView = [[SVHeaderView alloc] init];
    //把所有Label添加到View中
    [_headerView addSubview:_headerView.ResponseLabel];
    [_headerView addSubview:_headerView.ResponseLabel1];
    [_headerView addSubview:_headerView.DownloadLabel];
    [_headerView addSubview:_headerView.DownloadLabel1];
    [_headerView addSubview:_headerView.LoadLabel];
    [_headerView addSubview:_headerView.LoadLabel1];
    [_headerView addSubview:_headerView.ResponseNumLabel];
    [_headerView addSubview:_headerView.DownloadNumLabel];
    [_headerView addSubview:_headerView.LoadNumLabel];
    //把headerView添加到中整个视图上
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
          withTitleColor:[UIColor colorWithHexString:@"#E5000000"]
               withTitle:@""];

    // 初始化测试地址标题的label
    _testUrlTitle = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (50), _testUrlLabel.bottomY + FITHEIGHT (16),
                                     FITWIDTH (446), FITWIDTH (34))
                withFont:pixelToFontsize (36)
          withTitleColor:[UIColor colorWithHexString:@"#B2000000"]
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

    // 下载速度
    double downloadSpeed = testResult.downloadSpeed;

    dispatch_async (dispatch_get_main_queue (), ^{

      // 测试完成跳转到
      if (testContext.testStatus == TEST_FINISHED)
      {
          [self initCurrentResultModel:testResult];
          [self goToCurrentResultViewCtrl];
          return;
      }

      // 成功的时候显示指标值
      if (totalTime < 10)
      {
          // 显示头部指标
          [_headerView.ResponseLabel setText:[NSString stringWithFormat:@"%.2f", responseTime]];
          [_headerView.DownloadLabel setText:[NSString stringWithFormat:@"%.2f", downloadSpeed]];
          [_headerView.LoadLabel setText:[NSString stringWithFormat:@"%.2f", totalTime]];

          // 仪表盘指标
          [_webtestingView updateValue:totalTime];

          // 测试地址
          [_testUrlLabel setText:testUrl];
          return;
      }

      // 失败的情况显示超时
      // 显示头部指标
      [_headerView.ResponseLabel setText:[NSString stringWithFormat:@"%@", I18N (@"Timeout")]];
      [_headerView.DownloadLabel setText:[NSString stringWithFormat:@"%@", I18N (@"Timeout")]];
      [_headerView.LoadLabel setText:[NSString stringWithFormat:@"%@", I18N (@"Timeout")]];
      [_headerView.ResponseLabel1 setText:@""];
      [_headerView.DownloadLabel1 setText:@""];
      [_headerView.LoadLabel1 setText:@""];

      // 仪表盘指标
      [_webtestingView updateValue:0];
      [_webtestingView.valueLabel setText:[NSString stringWithFormat:@"%@", I18N (@"Timeout")]];
      [_webtestingView.unitLabel setText:@""];

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


@end