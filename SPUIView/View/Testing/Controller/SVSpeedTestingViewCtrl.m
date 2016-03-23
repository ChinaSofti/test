//
//  SVSpeedTestingViewCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/3/8.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

//主View下的4个子View
#import "SVFooterView.h"
#import "SVHeaderView.h"
#import "SVPointView.h"
#import "SVSpeedView.h"


#import "SVChart.h"
#import "SVCurrentResultViewCtrl.h"
#import "SVSpeedTestingViewCtrl.h"

#define kVideoViewDefaultRect \
    CGRectMake (FITWIDTH (10), FITWIDTH (425), FITWIDTH (150), FITWIDTH (90))

@interface SVSpeedTestingViewCtrl ()
{

    SVHeaderView *_headerView; // 定义headerView
    SVPointView *_speedtestingView; //定义speedtestingView
    SVSpeedView *_speedView; //定义访问网页的View
    SVFooterView *_footerView; // 定义footerView
    SVSpeedTest *_speedTest;
    SVChart *_chart;
    BOOL uploadFirstResult;
    BOOL downloadFirstResult;
}

//定义gy遮挡View
@property (nonatomic, strong) UIView *gyview;

@end

@implementation SVSpeedTestingViewCtrl

double _preSpeed = 0.0;

@synthesize navigationController, tabBarController, currentResultModel;

- (id)initWithResultModel:(SVCurrentResultModel *)resultModel
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    _preSpeed = 0.0;
    currentResultModel = resultModel;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    SVInfo (@"SVSpeedTestingCtrl");

    // 1.自定义navigationItem.titleView
    //设置图片大小
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake (0, 0, 100, 30)];
    //设置图片名称
    imageView.image = [UIImage imageNamed:@"speed_pro"];
    //让图片适应
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    //把图片添加到navigationItem.titleView
    self.navigationItem.titleView = imageView;
    //电池显示不了,设置样式让电池显示
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

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

    //为了保持平衡添加一个leftBtn
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, 44, 44)];
    UIBarButtonItem *backButton1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.rightBarButtonItem = backButton1;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    // 2.设置整个Viewcontroller
    //设置背景颜色
    self.view.backgroundColor =
    [UIColor colorWithRed:250 / 255.0 green:250 / 255.0 blue:250 / 255.0 alpha:1.0];
    //打印排序结果
    //    SVInfo (@"%@", _selectedA);
    //添加方法
    [self creatHeaderView];
    [self creatSpeedTestingView];
    [self creatFooterView];
    [self creatSpeedView];
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
        [currentResultModel.navigationController popToRootViewControllerAnimated:NO];
    }
    SVInfo (@"继续测试");
}

/**
 *  初始化当前页面和全局变量
 */
- (void)initContext
{
    NSString *title5 = I18N (@"Loading...");
    [_footerView.ServerLocation setText:title5];
    [_footerView.Carrier setText:title5];
    [_headerView.Delay setText:@"0"];
    [_headerView.Downloadspeed setText:@"0"];
    [_headerView.Uploadspeed setText:@"0"];
    [_speedtestingView updateUvMOS3:0];

    for (UIView *view in [_headerView.uvMosBarView subviews])
    {
        [view removeFromSuperview];
    }
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
    _gyview = [[UIView alloc] initWithFrame:CGRectMake (0, kScreenH - 50, kScreenW, 50)];
    //设置透明度
    _gyview.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.0];
    //添加
    [window addSubview:_gyview];
    [self initContext];
    // 进入页面时，开始测试
    _speedTest = [[SVSpeedTest alloc] initWithView:self.currentResultModel.testId
                                     showSpeedView:nil
                                      testDelegate:self];

    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      BOOL isOK = [_speedTest initTestContext];
      if (isOK)
      {
          [_speedTest startTest];
      }
      else
      {
          dispatch_async (dispatch_get_main_queue (), ^{
            [self goToCurrentResultViewCtrl];
          });
      }
    });
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    for (UIView *subView in _speedView.subviews)
    {
        [subView removeFromSuperview];
    }

    uploadFirstResult = false;
    downloadFirstResult = false;

    dispatch_async (dispatch_get_main_queue (), ^{

      // 当用户离开当前页面时，停止测试
      if (_speedTest)
      {
          [_speedTest stopTest];

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
    [_headerView addSubview:_headerView.Delay];
    [_headerView addSubview:_headerView.Delay1];
    [_headerView addSubview:_headerView.Downloadspeed];
    [_headerView addSubview:_headerView.Downloadspeed1];
    [_headerView addSubview:_headerView.Uploadspeed];
    [_headerView addSubview:_headerView.Uploadspeed1];
    [_headerView addSubview:_headerView.DelayNumLabel];
    [_headerView addSubview:_headerView.DownloadspeedNumLabel];
    [_headerView addSubview:_headerView.UploadspeedNumLabel];
    //把headerView添加到中整个视图上
    [self.view addSubview:_headerView];
}

#pragma mark - 创建测试中speedtestingView

- (void)creatSpeedTestingView
{
    //初始化整个speedtestingView
    _speedtestingView = [[SVPointView alloc] init];
    //添加到View中
    [_speedtestingView addSubview:_speedtestingView.pointView];
    [_speedtestingView addSubview:_speedtestingView.grayView3];
    [_speedtestingView addSubview:_speedtestingView.panelView3];
    [_speedtestingView addSubview:_speedtestingView.middleView];
    [_speedtestingView addSubview:_speedtestingView.label13];
    [_speedtestingView addSubview:_speedtestingView.label23];
    [_speedtestingView addSubview:_speedtestingView.label33];
    [_speedtestingView start3];
    [self.view addSubview:_speedtestingView];
}


#pragma mark - 创建speedView
- (void)creatSpeedView
{
    //初始化
    _speedView = [[SVSpeedView alloc] initWithFrame:kVideoViewDefaultRect];
    [_speedView setBackgroundColor:[UIColor whiteColor]];
    _speedView.layer.borderWidth = 0.5;
    _speedView.layer.borderColor = [[UIColor grayColor] CGColor];
    //    [_webView setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:_speedView];
}

#pragma mark - 创建尾footerView

- (void)creatFooterView
{
    //初始化headerView
    _footerView = [[SVFooterView alloc] init];
    //把所有Label添加到headerView中
    [_footerView addSubview:_footerView.ServerLocation];
    [_footerView addSubview:_footerView.Carrier];
    [_footerView addSubview:_footerView.abcd];
    [_footerView addSubview:_footerView.ServerLocationNumLabel];
    [_footerView addSubview:_footerView.CarrierNumLabel];
    //把headerView添加到中整个视图上
    [self.view addSubview:_footerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 随机数 范围在[from,to）
- (int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random () % (to - from + 1)));
}
/**********************************以下为UI数据层代码**********************************/
- (void)updateTestResultDelegate:(SVSpeedTestContext *)testContext
                      testResult:(SVSpeedTestResult *)testResult
{
    NSString *title21 = I18N (@"Upload");
    NSString *title22 = I18N (@"Download");
    dispatch_async (dispatch_get_main_queue (), ^{

      // 如果测试结束，则初始化测试结果，并跳转到当前结果页面
      if (testContext.testStatus == TEST_FINISHED)
      {
          [self initCurrentResultModel:testResult];
          [self goToCurrentResultViewCtrl];
          return;
      }

      // 服务器归属地和运营商
      if (testResult.isp)
      {
          // 服务器归属地和运营商
          if (testResult.isp)
          {
              if (testResult.isp.isp)
              {
                  _footerView.Carrier.text = testResult.isp.isp;
              }
              if (testResult.isp.city)
              {
                  _footerView.ServerLocation.text = testResult.isp.city;
              }
          }

          // 显示头部指标
          [_headerView.Delay setText:[NSString stringWithFormat:@"%.2f", testResult.delay]];

          double speed = testResult.isUpload ? testResult.uploadSpeed : testResult.downloadSpeed;
          if (!testResult.isSummeryResult && !testResult.isSecResult)
          {
              _footerView.Carrier.text = testResult.isp.isp;
          }
          if (testResult.isp.city)
          {
              _footerView.ServerLocation.text = testResult.isp.city;
          }
      }

      // 显示头部指标
      [_headerView.Delay setText:[NSString stringWithFormat:@"%.2f", testResult.delay]];

      // 如果是汇总结果，直接使用
      if (testResult.isSummeryResult)
      {
          if (testResult.isUpload)
          {
              [_headerView.Uploadspeed setText:[NSString stringWithFormat:@"%.2f", testResult.uploadSpeed]];
          }
          else
          {
              [_headerView.Downloadspeed setText:[NSString stringWithFormat:@"%.2f", testResult.downloadSpeed]];
          }
          return;
      }

          if (testResult.isSecResult)
          {
              if (!uploadFirstResult)
              {
                  if (_chart)
                  {
                      [_chart removeFromSuperview];
                  }

                  _chart = [[SVChart alloc] initWithView:_speedView];
                  uploadFirstResult = true;
                  _speedtestingView.label13.text = title21;
              }
          }
          else
          {
              if (!downloadFirstResult)
              {
                  if (_chart)
                  {
                      [_chart removeFromSuperview];
                  }

                  _chart = [[SVChart alloc] initWithView:_speedView];
                  downloadFirstResult = true;
                  _speedtestingView.label13.text = title22;
              }
          }
      }
    });
}

- (void)initCurrentResultModel:(SVSpeedTestResult *)testResult
{
    currentResultModel.testId = testResult.testId;
    currentResultModel.stDelay = testResult.delay;
    currentResultModel.stDownloadSpeed = testResult.downloadSpeed;
    currentResultModel.stUploadSpeed = testResult.uploadSpeed;
    if (testResult.isp)
    {
        if (testResult.isp.isp)
        {
            currentResultModel.stIsp = testResult.isp.isp;
        }
        if (testResult.isp.city)
        {
            currentResultModel.stLocation = testResult.isp.city;
        }
    }
}

- (void)goToCurrentResultViewCtrl
{
    // push界面
    [currentResultModel pushNextCtrl];
}


@end