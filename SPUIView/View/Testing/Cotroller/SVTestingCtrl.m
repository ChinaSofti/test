//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVCurrentResultViewCtrl.h"
#import "SVPointView.h"
#import "SVTestingCtrl.h"
#import <SPCommon/SVI18N.h>
#import <SPCommon/SVTimeUtil.h>
#import <SPCommon/UUBar.h>
#import <SPService/SVVideoTest.h>


#define kVideoViewDefaultRect \
    CGRectMake (FITWIDTH (10), FITWIDTH (420), FITWIDTH (150), FITWIDTH (92))

@interface SVTestingCtrl ()
{
    // 定义headerView
    SVPointView *_headerView;

    //定义testingView
    SVPointView *_testingView;

    //定义视频播放View
    SVPointView *_videoView;

    // 定义footerView
    SVPointView *_footerView;

    SVVideoTest *_videoTest;

    NSTimer *_timer;

    // 实际真实码率
    float realBitrate;

    // 实际真实UvMOS值
    float realuvMOSSession;

    // 是否时第一次上报结果
    int _resultTimes;

    // UvMOS柱状图 每一秒切换一次
    int _UvMOSbarResultTimes;

    // 是否全屏
    int _fullScreen;

    UIView *_showCurrentResultInFullScreenMode;

    UILabel *_UvMosInFullScreenValue;
    UILabel *_bufferTimesInFullScreenValue;
    UILabel *_bitRateInFullScreenValue;
    UILabel *_resolutionInFullScreenValue;
}

//定义gray遮挡View
@property (nonatomic, strong) UIView *grayview;

@end

@implementation SVTestingCtrl

@synthesize navigationController, tabBarController, currentResultModel;

- (void)viewDidLoad
{

    [super viewDidLoad];
    NSLog (@"SVTestingCtrl");

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
    //    NSLog (@"%@", _selectedA);


    //添加方法
    [self creatHeaderView];
    [self creatTestingView];
    [self creatFooterView];
    [self creatVideoView];
}

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
        NSLog (@"取消了此次测试");
        [navigationController popToRootViewControllerAnimated:NO];
    }
    NSLog (@"继续测试");
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
    [_testingView updateUvMOS:0];

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
    _videoTest =
    [[SVVideoTest alloc] initWithView:testId showVideoView:_videoView testDelegate:self];
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
    _headerView = [[SVPointView alloc] init];

    //把所有Label添加到View中
    [self.view addSubview:_headerView.uvMosBarView];
    [self.view addSubview:_headerView.speedLabel];
    [self.view addSubview:_headerView.speedLabel1];
    [self.view addSubview:_headerView.bufferLabel];
    [self.view addSubview:_headerView.uvMosNumLabel];
    [self.view addSubview:_headerView.speedNumLabel];
    [self.view addSubview:_headerView.bufferNumLabel];
    //把headerView添加到中整个视图上
    [self.view addSubview:_headerView];
}

#pragma mark - 创建测试中仪表盘testingView

- (void)creatTestingView
{
    //初始化整个testingView
    _testingView = [[SVPointView alloc] init];
    //添加到View中
    [self.view addSubview:_testingView.pointView];
    [_testingView start];
    [self.view addSubview:_testingView.grayView];
    [self.view addSubview:_testingView.panelView];
    [self.view addSubview:_testingView.middleView];
    [self.view addSubview:_testingView.label1];
    [self.view addSubview:_testingView.label2];
}


#pragma mark - 创建视频播放View
- (void)creatVideoView
{
    CGSize size = self.view.bounds.size;
    // 在全屏模式下，在_videoView上方显示测试指标
    _showCurrentResultInFullScreenMode = [[UIView alloc] initWithFrame:CGRectMake (0, 0, size.height, 30)];
    _showCurrentResultInFullScreenMode.alpha = 0.5;
    [_showCurrentResultInFullScreenMode setBackgroundColor:[UIColor blackColor]];

    // U-vMOS 0.0
    UILabel *UvMosInFullScreenLabel =
    [[UILabel alloc] initWithFrame:CGRectMake (20, 5, FITWIDTH (45), FITHEIGHT (20))];
    [UvMosInFullScreenLabel setText:@"U-vMOS"];
    [UvMosInFullScreenLabel setTextColor:[UIColor whiteColor]];
    [UvMosInFullScreenLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [_showCurrentResultInFullScreenMode addSubview:UvMosInFullScreenLabel];
    _UvMosInFullScreenValue = [[UILabel alloc]
    initWithFrame:CGRectMake (UvMosInFullScreenLabel.rightX + 2, 5, FITWIDTH (35), FITHEIGHT (20))];
    //    [_UvMosInFullScreenValue setText:@"2.2"];
    [_UvMosInFullScreenValue setTextColor:[UIColor greenColor]];
    [_UvMosInFullScreenValue setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [_showCurrentResultInFullScreenMode addSubview:_UvMosInFullScreenValue];

    // Buffer times 0
    UILabel *bufferTimesInFullScreenLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (_UvMosInFullScreenValue.rightX + 20, 5, FITWIDTH (62), FITHEIGHT (20))];
    [bufferTimesInFullScreenLabel setText:@"Buffer times"];
    [bufferTimesInFullScreenLabel setTextColor:[UIColor whiteColor]];
    [bufferTimesInFullScreenLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [_showCurrentResultInFullScreenMode addSubview:bufferTimesInFullScreenLabel];
    _bufferTimesInFullScreenValue = [[UILabel alloc]
    initWithFrame:CGRectMake (bufferTimesInFullScreenLabel.rightX + 2, 5, FITWIDTH (20), FITHEIGHT (20))];
    //    [_bufferTimesInFullScreenValue setText:@"2"];
    [_bufferTimesInFullScreenValue setTextColor:[UIColor greenColor]];
    [_bufferTimesInFullScreenValue setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [_showCurrentResultInFullScreenMode addSubview:_bufferTimesInFullScreenValue];

    // Bit rate 3002.23kbps
    UILabel *bitRateInFullScreenLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (_bufferTimesInFullScreenValue.rightX + 20, 5, FITWIDTH (37), FITHEIGHT (20))];
    [bitRateInFullScreenLabel setText:@"Bit rate"];
    [bitRateInFullScreenLabel setTextColor:[UIColor whiteColor]];
    [bitRateInFullScreenLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [_showCurrentResultInFullScreenMode addSubview:bitRateInFullScreenLabel];
    _bitRateInFullScreenValue = [[UILabel alloc]
    initWithFrame:CGRectMake (bitRateInFullScreenLabel.rightX + 2, 5, FITWIDTH (80), FITHEIGHT (20))];
    //    [_bitRateInFullScreenValue setText:@"3002.23kbps"];
    [_bitRateInFullScreenValue setTextColor:[UIColor greenColor]];
    [_bitRateInFullScreenValue setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [_showCurrentResultInFullScreenMode addSubview:_bitRateInFullScreenValue];

    // Resolution  1920 * 1080
    UILabel *resolutionInFullScreenLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (_bitRateInFullScreenValue.rightX + 20, 5, FITWIDTH (53), FITHEIGHT (20))];
    [resolutionInFullScreenLabel setText:@"Resolution"];
    [resolutionInFullScreenLabel setTextColor:[UIColor whiteColor]];
    [resolutionInFullScreenLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [_showCurrentResultInFullScreenMode addSubview:resolutionInFullScreenLabel];
    _resolutionInFullScreenValue = [[UILabel alloc]
    initWithFrame:CGRectMake (resolutionInFullScreenLabel.rightX + 2, 5, FITWIDTH (80), FITHEIGHT (20))];
    //    [_resolutionInFullScreenValue setText:@"1920 * 1080"];
    [_resolutionInFullScreenValue setTextColor:[UIColor greenColor]];
    [_resolutionInFullScreenValue setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [_showCurrentResultInFullScreenMode addSubview:_resolutionInFullScreenValue];

    //初始化
    _videoView = [[SVPointView alloc] initWithFrame:kVideoViewDefaultRect];
    [_videoView setBackgroundColor:[UIColor blackColor]];
    [_videoView setContentMode:UIViewContentModeScaleToFill];
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector (ClickVideoView:)];
    [tapGesture setNumberOfTapsRequired:1];
    [_videoView addGestureRecognizer:tapGesture];
    [self.view addSubview:_videoView];
}

/**
 *  点击视频切换全屏和退出全屏模式
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)ClickVideoView:(UITapGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.1
                     animations:^{
                       if (_fullScreen)
                       {
                           [self exitFullScreenMode];
                           _fullScreen = 0;
                       }
                       else
                       {
                           [self enterFullScreenMode];
                           _fullScreen = 1;
                       }
                     }];
}

#pragma mark - 创建尾footerView

- (void)creatFooterView
{
    //初始化headerView
    _footerView = [[SVPointView alloc] init];

    //把所有Label添加到headerView中
    [self.view addSubview:_footerView.placeLabel];
    [_footerView addSubview:_footerView.resolutionLabel];
    [_footerView addSubview:_footerView.bitLabel];
    [_footerView addSubview:_footerView.placeNumLabel];
    [_footerView addSubview:_footerView.resolutionNumLabel];
    [_footerView addSubview:_footerView.bitNumLabel];
    //把headerView添加到中整个视图上
    [self.view addSubview:_footerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    NSLog (@"uvMOSSession: %f  firstBufferTime:%ld  cuttonTimes:%d  location:%@  bitrate:%f  "
           @"videoResolution:%@",
           uvMOSSession, firstBufferTime, cuttonTimes, location, bitrate, videoResolution);
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

      [_testingView updateUvMOS:uvMOSSession];

      realBitrate = bitrate;
      realuvMOSSession = uvMOSSession;

      if (!_resultTimes || _resultTimes == 0)
      {
          _resultTimes = 1;
          //每一秒中改变一下界面显示的值
          _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                    target:self
                                                  selector:@selector (changeValueUseFakeData)
                                                  userInfo:nil
                                                   repeats:YES];
      }


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

/**
 *  每一秒钟使用假的数据改变界面显示，使仪表盘能够动起来。真实值每5秒推送一次
 */
- (void)changeValueUseFakeData
{
    if (realBitrate > 0)
    {
        int firstFakeBitrate = (arc4random () % 100 + realBitrate - 100);
        if (firstFakeBitrate < 0)
        {
            firstFakeBitrate = 0;
        }
        int lastFakeBitrate = arc4random () % 100;
        float fakeBitrate = [[NSString stringWithFormat:@"%d.%d", firstFakeBitrate, lastFakeBitrate] floatValue];
        //    NSLog (@"fake bitrate:%f", fakeBitrate);
        [_footerView.bitLabel setText:[NSString stringWithFormat:@"%.2fkpbs", fakeBitrate]];

        [_bitRateInFullScreenValue setText:[NSString stringWithFormat:@"%.2fkpbs", fakeBitrate]];
    }

    if (realuvMOSSession > 0)
    {
        int firstFakeUvMOSSession = (int)realuvMOSSession;
        if (firstFakeUvMOSSession < 0)
        {
            firstFakeUvMOSSession = 0;
        }
        int lastFakeUvMOSSession = arc4random () % 50;
        float fakeUvMOSSession =
        [[NSString stringWithFormat:@"%d.%d", firstFakeUvMOSSession, lastFakeUvMOSSession] floatValue];
        //    NSLog (@"fake UvMOS:%f", fakeUvMOSSession);
        [_testingView updateUvMOS:fakeUvMOSSession];
        [_UvMosInFullScreenValue setText:[NSString stringWithFormat:@"%.2f", fakeUvMOSSession]];
        _resultTimes += 1;
        if (_resultTimes % 10 == 0)
        {
            _UvMOSbarResultTimes += 1;
            if (_UvMOSbarResultTimes < 20)
            {
                // 如果显示柱子个数少于等于 20 个，添加新的柱子
                UUBar *bar =
                [[UUBar alloc] initWithFrame:CGRectMake (5 + _UvMOSbarResultTimes * 3, -10, 1, 30)];
                [bar setBarValue:fakeUvMOSSession];
                [_headerView.uvMosBarView addSubview:bar];
            }
        }
    }
}

- (void)goToCurrentResultViewCtrl
{
    // 如果视频在全屏模式，则退出全屏模式
    [self exitFullScreenMode];

    SVCurrentResultViewCtrl *currentResultView = [[SVCurrentResultViewCtrl alloc] init];
    currentResultView.currentResultModel = currentResultModel;
    currentResultView.navigationController = navigationController;
    [navigationController pushViewController:currentResultView animated:YES];
}

/**
 *  退出全屏模式
 */
- (void)exitFullScreenMode
{
    // 显示状态栏
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    CGAffineTransform at = CGAffineTransformMakeRotation (0);
    [_videoView setTransform:at];
    _videoView.frame = kVideoViewDefaultRect;

    // 退出全屏模式时，隐藏_videoView上方显示测试指标
    [_showCurrentResultInFullScreenMode removeFromSuperview];
}


/**
 *  进入全屏模式
 */
- (void)enterFullScreenMode
{
    // 隐藏状态栏
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    CGSize videoViewSize = _videoView.frame.size;
    _videoView.origin =
    CGPointMake ((kScreenW - videoViewSize.width) / 2, (kScreenH - videoViewSize.height) / 2);

    CGAffineTransform at = CGAffineTransformMakeRotation (M_PI / 2);
    at = CGAffineTransformTranslate (at, 0, 0);
    [_videoView setTransform:at];
    _videoView.frame = CGRectMake (0, 0, kScreenW, kScreenH);


    // 在全屏模式下，在_videoView上方显示测试指标
    [_videoView addSubview:_showCurrentResultInFullScreenMode];
    [_videoView setNeedsDisplay];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
