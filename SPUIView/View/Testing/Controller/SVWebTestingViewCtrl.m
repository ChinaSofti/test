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
#import <SPCommon/SVTimeUtil.h>
#import <SPCommon/UUBar.h>


#define kVideoViewDefaultRect \
    CGRectMake (FITWIDTH (10), FITWIDTH (420), FITWIDTH (150), FITWIDTH (92))

@interface SVWebTestingViewCtrl ()
{

    SVHeaderView *_headerView; // 定义headerView
    SVPointView *_webtestingView; //定义webtestingView
    SVWebView *_webView; //定义访问网页的View
    SVFooterView *_footerView; // 定义footerView
    SVWebTest *_webTest;
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
    [self creatWebTestingView];
    [self creatFooterView];
    [self creatWebView];
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
    NSString *title5 = I18N (@"Loading...");
    [_footerView.placeLabel setText:title5];
    [_footerView.resolutionLabel setText:title5];
    [_footerView.bitLabel setText:title5];
    [_headerView.bufferLabel setText:@"0"];
    [_headerView.speedLabel setText:@"0"];
    [_webtestingView updateUvMOS2:0];

    for (UIView *view in [_headerView.uvMosBarView subviews])
    {
        [view removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
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
    _webTest = [[SVWebTest alloc] initWithView:self.currentResultModel.testId
                                   showWebView:_webView
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


- (void)viewWillDisappear:(BOOL)animated
{

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
    //初始化整个webtestingView
    _webtestingView = [[SVPointView alloc] init];
    //添加到View中
    [_webtestingView addSubview:_webtestingView.pointView];
    [_webtestingView addSubview:_webtestingView.grayView2];
    [_webtestingView addSubview:_webtestingView.panelView2];
    [_webtestingView addSubview:_webtestingView.middleView];
    [_webtestingView addSubview:_webtestingView.label12];
    [_webtestingView addSubview:_webtestingView.label22];
    [_webtestingView addSubview:_webtestingView.label32];
    [_webtestingView start2];
    [self.view addSubview:_webtestingView];
}


#pragma mark - 创建WebView
- (void)creatWebView
{
    //初始化
    _webView = [[SVWebView alloc] initWithFrame:kVideoViewDefaultRect];
    [_webView setBackgroundColor:[UIColor blackColor]];
    //    [_webView setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:_webView];
}

#pragma mark - 创建尾footerView

- (void)creatFooterView
{
    //初始化headerView
    _footerView = [[SVFooterView alloc] init];
    //把所有Label添加到headerView中
    [_footerView addSubview:_footerView.urlLabel];
    [_footerView addSubview:_footerView.urlNumLabel];
    //把headerView添加到中整个视图上
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

      if (testContext.testStatus == TEST_FINISHED)
      {
          [self initCurrentResultModel:testResult];
          [self goToCurrentResultViewCtrl];
      }
      else
      {
          // 显示头部指标
          [_headerView.ResponseLabel setText:[NSString stringWithFormat:@"%.2f", responseTime]];
          [_headerView.DownloadLabel setText:[NSString stringWithFormat:@"%.2f", downloadSpeed]];
          [_headerView.LoadLabel setText:[NSString stringWithFormat:@"%.2f", totalTime]];

          // 仪表盘指标
          UUBar *bar = [[UUBar alloc] initWithFrame:CGRectMake (5, -10, 1, 30)];
          [bar setBarValue:totalTime];
          [_headerView.uvMosBarView addSubview:bar];
          [_webtestingView updateUvMOS2:totalTime];
          [_webtestingView.label22 setText:[NSString stringWithFormat:@"%.2f", totalTime]];

          // 测试地址
          [_footerView.urlLabel setText:testUrl];
      }
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