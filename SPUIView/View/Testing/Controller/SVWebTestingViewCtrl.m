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
#import "SVWebView.h"

#import "SVCurrentResultViewCtrl.h"
#import "SVWebTestingViewCtrl.h"
#import <SPCommon/SVTimeUtil.h>
#import <SPCommon/UUBar.h>
#import <SPService/SVVideoTest.h>


#define kVideoViewDefaultRect \
    CGRectMake (FITWIDTH (10), FITWIDTH (420), FITWIDTH (150), FITWIDTH (92))

@interface SVWebTestingViewCtrl ()
{

    SVHeaderView *_headerView; // 定义headerView
    SVPointView *_webtestingView; //定义webtestingView
    SVWebView *_webView; //定义视频播放View
    SVFooterView *_footerView; // 定义footerView
    SVVideoTest *_videoTest;

    NSTimer *_timer;
    float realBitrate; // 实际真实码率
    float realuvMOSSession; // 实际真实UvMOS值
    int _resultTimes; // 是否时第一次上报结果
    int _UvMOSbarResultTimes; // UvMOS柱状图 每一秒切换一次
    int _fullScreen; // 是否全屏

    UIView *_showCurrentResultInFullScreenMode;
    UILabel *_UvMosInFullScreenValue;
    UILabel *_bufferTimesInFullScreenValue;
    UILabel *_bitRateInFullScreenValue;
    UILabel *_resolutionInFullScreenValue;
}

//定义gray遮挡View
@property (nonatomic, strong) UIView *grayview;


@end

@implementation SVWebTestingViewCtrl

@synthesize navigationController, tabBarController, currentResultModel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];

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
        [navigationController popToRootViewControllerAnimated:NO];
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
    [_webtestingView updateUvMOS:0];

    for (UIView *view in [_headerView.uvMosBarView subviews])
    {
        [view removeFromSuperview];
    }

    realBitrate = 0.0;
    realuvMOSSession = 0.0;
    _resultTimes = 0;
    _UvMOSbarResultTimes = 0;
    _timer = nil;

    // 初始化结果
    currentResultModel = [[SVCurrentResultModel alloc] init];
    [currentResultModel setTestId:-1];
    [currentResultModel setUvMOS:-1];
    [currentResultModel setFirstBufferTime:-1];
    [currentResultModel setCuttonTimes:-1];
}

- (void)viewWillAppear:(BOOL)animated
{
    // 显示tabbar 和navigationbar
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;

    //添加覆盖grayview(为了防止用户在测试的过程中点击按钮)
    //获取整个屏幕的window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //创建一个覆盖garyView
    _grayview = [[UIView alloc] initWithFrame:CGRectMake (0, kScreenH - 50, kScreenW, 50)];
    //设置透明度
    _grayview.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.0];
    //添加
    [window addSubview:_grayview];
    [self initContext];
    // 进入页面时，开始测试
    long testId = [SVTimeUtil currentMilliSecondStamp];
    _videoTest = [[SVVideoTest alloc] initWithView:testId showVideoView:_webView testDelegate:self];
    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      BOOL isOK = [_videoTest initTestContext];
      if (isOK)
      {
          [_videoTest startTest];
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
    //取消定时器
    if (_timer)
    {
        //取消定时器
        [_timer invalidate];
        _timer = nil;
    }

    dispatch_async (dispatch_get_main_queue (), ^{
      // 当用户离开当前页面时，停止测试
      if (_videoTest)
      {
          [_videoTest stopTest];

          //移除覆盖grayView
          [_grayview removeFromSuperview];
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
    [_webtestingView addSubview:_webtestingView.grayView];
    [_webtestingView addSubview:_webtestingView.panelView2];
    [_webtestingView addSubview:_webtestingView.middleView];
    [_webtestingView addSubview:_webtestingView.label12];
    [_webtestingView addSubview:_webtestingView.label22];
    [_webtestingView addSubview:_webtestingView.label32];
    [_webtestingView start];
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
    [_footerView addSubview:_footerView.urlLabel2];
    [_footerView addSubview:_footerView.urlNumLabel2];
    //把headerView添加到中整个视图上
    [self.view addSubview:_footerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**********************************以下为UI数据层代码**********************************/
- (void)updateTestResultDelegate:(SVVideoTestContext *)testContext
                      testResult:(SVVideoTestResult *)testResult
{

    // UvMOS 综合得分
    NSArray *testSamples = testResult.videoTestSamples;
    SVVideoTestSample *testSample = testSamples[testSamples.count - 1];
    float uvMOSSession = testSample.UvMOSSession;

    //首次缓冲时长
    long firstBufferTime = testResult.firstBufferTime;

    // 卡顿次数
    int cuttonTimes = testResult.videoCuttonTimes;

    // 视频服务器位置
    NSString *location = testContext.videoSegemnetLocation;

    // 视频码率
    float bitrate = testResult.bitrate;

    // 分辨率
    NSString *videoResolution = testResult.videoResolution;
    //    SVInfo (@"uvMOSSession: %f  firstBufferTime:%ld  cuttonTimes:%d  location:%@  bitrate:%f "
    //            @"videoResolution:%@",
    //            uvMOSSession, firstBufferTime, cuttonTimes, location, bitrate, videoResolution);
    dispatch_async (dispatch_get_main_queue (), ^{
      [_footerView.placeLabel setText:location];
      [_footerView.resolutionLabel setText:videoResolution];
      [_footerView.bitLabel setText:[NSString stringWithFormat:@"%.2fkpbs", bitrate]];
      [_headerView.bufferLabel setText:[NSString stringWithFormat:@"%d", cuttonTimes]];
      [_headerView.speedLabel setText:[NSString stringWithFormat:@"%ld", firstBufferTime]];

      [_bufferTimesInFullScreenValue setText:[NSString stringWithFormat:@"%d", cuttonTimes]];
      [_resolutionInFullScreenValue setText:videoResolution];

      UUBar *bar = [[UUBar alloc] initWithFrame:CGRectMake (5, -10, 1, 30)];
      [bar setBarValue:uvMOSSession];
      [_headerView.uvMosBarView addSubview:bar];

      [_webtestingView updateUvMOS:uvMOSSession];

      realBitrate = bitrate;
      realuvMOSSession = uvMOSSession;

      if (testContext.testStatus == TEST_FINISHED)
      {
          //取消定时器
          if (_timer)
          {
              //取消定时器
              [_timer invalidate];
              _timer = nil;
          }


          [self initCurrentResultModel:testResult];
          [self goToCurrentResultViewCtrl];
      }
    });
}

- (void)initCurrentResultModel:(SVVideoTestResult *)testResult
{
    if (!currentResultModel)
    {
        currentResultModel = [[SVCurrentResultModel alloc] init];
    }

    [currentResultModel setTestId:testResult.testId];
    [currentResultModel setUvMOS:testResult.UvMOSSession];
    [currentResultModel setFirstBufferTime:testResult.firstBufferTime];
    [currentResultModel setCuttonTimes:testResult.videoCuttonTimes];
}

- (void)goToCurrentResultViewCtrl
{
    SVCurrentResultViewCtrl *currentResultView = [[SVCurrentResultViewCtrl alloc] init];
    currentResultView.currentResultModel = currentResultModel;
    currentResultView.navigationController = navigationController;
    [navigationController pushViewController:currentResultView animated:YES];
}


@end