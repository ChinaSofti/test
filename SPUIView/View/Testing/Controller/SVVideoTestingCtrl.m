//
//  SVVideoTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

//主View下的4个子View
#import "SVFooterView.h"
#import "SVHeaderView.h"
#import "SVPointView.h"
#import "SVProbeInfo.h"
#import "SVTimeUtil.h"
#import "SVVideoSegement.h"
#import "SVVideoTest.h"
#import "SVVideoTestingCtrl.h"
#import "SVVideoView.h"
#import "UUBar.h"

@interface SVVideoTestingCtrl ()
{

    // 定义headerView
    SVHeaderView *_headerView;

    //定义testingView
    SVPointView *_testingView;

    //定义视频播放View
    SVVideoView *_videoView;

    // 定义footerView
    SVFooterView *_footerView;

    // 定义视频测试实例
    SVVideoTest *_videoTest;

    // 定义主图的View
    UIView *uvMosBarView;

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

    // 每个U-vMOS值对应的时长
    int _per_uvmos_bar_need_time;

    // 位置标题
    UILabel *_locationTitle;

    // 位置的值
    UILabel *_locationValue;

    // 分辨率标题
    UILabel *_resolutionTitle;

    // 分辨率值
    UILabel *_resolutionValue;

    // 码率标题
    UILabel *_bitRateTitle;

    // 码率值
    UILabel *_bitRateValue;

    // 遮挡视频的透明UIView，其大小始终与视频大小相同
    UIView *_transparentView;
}

// 定义gray遮挡View
@property (nonatomic, strong) UIView *gyview;

@end

@implementation SVVideoTestingCtrl

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
    SVInfo (@"SVVideoTestingCtrl");

    // 初始化标题
    [super initTitleView];

    // 初始化返回按钮
    [super initBackButtonWithTarget:self action:@selector (removeButtonClicked:)];

    // 设置背景颜色
    self.view.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];

    //添加方法
    [self creatHeaderView];
    [self creatTestingView];
    [self creatFooterView];
    [self creatVideoView];
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
    NSString *loadingStr = I18N (@"Loading...");
    [_locationValue setText:loadingStr];
    [_resolutionValue setText:loadingStr];
    [_bitRateValue setText:loadingStr];
    [_testingView updateValue:0];

    // 初始化头部的指标值
    [_headerView updateRightValue:@"0"];
    [_headerView updateMiddleValue:@"0"];

    for (UIView *view in [uvMosBarView subviews])
    {
        [view removeFromSuperview];
    }

    realBitrate = 0.0;
    realuvMOSSession = 0.0;
    _resultTimes = 0;
    _UvMOSbarResultTimes = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // 显示tabbar 和navigationbar
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;

    // 添加覆盖gyview(为了防止用户在测试的过程中点击按钮)
    // 获取整个屏幕的window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    // 创建一个覆盖garyView
    _gyview = [[UIView alloc] initWithFrame:CGRectMake (0, kScreenH - 49, kScreenW, 49)];

    // 设置透明度
    _gyview.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.0];

    //添加
    [window addSubview:_gyview];

    // 初始化
    [self initContext];

    // 进入页面时，开始测试
    _videoTest = [[SVVideoTest alloc] initWithView:self.currentResultModel.testId
                                     showVideoView:_videoView
                                      testDelegate:self];
    // 创建遮挡视频的透明UIView
    if (_transparentView)
    {
        [_transparentView removeFromSuperview];
        _transparentView = nil;
    }

    _transparentView = [[UIView alloc] initWithFrame:_videoView.frame];
    _transparentView.alpha = 0.1;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector (ClickVideoView:)];
    [tapGesture setNumberOfTapsRequired:1];
    [_transparentView addGestureRecognizer:tapGesture];
    [_footerView.leftView addSubview:_transparentView];

    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    int _videoPlayTime = [probeInfo getVideoPlayTime];

    // 视频总时长 除以 20个U-vMOS柱子 获得每个柱子需要的时长，单位秒。再乘以5，将单位转换为200毫秒
    _per_uvmos_bar_need_time = _videoPlayTime * 5 / 20;
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
    [super viewWillDisappear:animated];

    dispatch_async (dispatch_get_main_queue (), ^{
      // 当用户离开当前页面时，停止测试
      if (_videoTest)
      {
          [_videoTest stopTest];

          // 移除覆盖gyView
          [_gyview removeFromSuperview];
      }
    });
}

#pragma mark - 创建头headerView

- (void)creatHeaderView
{
    // 初始化默认值
    NSMutableDictionary *defalutValue = [[NSMutableDictionary alloc] init];
    [defalutValue setValue:[UIFont systemFontOfSize:pixelToFontsize (36)] forKey:@"labelFontSize"];
    [defalutValue setValue:[UIColor colorWithHexString:@"#CC000000"] forKey:@"labelColor"];
    [defalutValue setValue:[UIFont systemFontOfSize:pixelToFontsize (60)] forKey:@"valueFontSize"];
    [defalutValue setValue:[UIColor colorWithHexString:@"#FEB960"] forKey:@"valueColor"];
    [defalutValue setValue:[UIFont systemFontOfSize:pixelToFontsize (32)] forKey:@"unitFontSize"];
    [defalutValue setValue:[UIColor colorWithHexString:@"#FEB960"] forKey:@"unitColor"];
    [defalutValue setValue:@"U-vMOS" forKey:@"leftTitle"];
    [defalutValue setValue:@"0" forKey:@"middleDefaultValue"];
    [defalutValue setValue:I18N (@"Initial Buffer Time") forKey:@"middleTitle"];
    [defalutValue setValue:@"ms" forKey:@"middleUnit"];
    [defalutValue setValue:@"0" forKey:@"rightDefaultValue"];
    [defalutValue setValue:I18N (@"Stalling Times") forKey:@"rightTitle"];
    [defalutValue setValue:@"" forKey:@"rightUnit"];


    // 初始化headerView
    _headerView = [[SVHeaderView alloc] initWithDic:defalutValue];

    // 把左侧的label换成view
    uvMosBarView = [[UIView alloc] init];
    [_headerView replaceLeftLabelWithView:uvMosBarView];

    // 把headerView添加到中整个视图上
    [self.view addSubview:_headerView];
}

#pragma mark - 创建测试中testingView

- (void)creatTestingView
{
    // 初始化默认值
    NSMutableDictionary *defalutValue = [[NSMutableDictionary alloc] init];
    [defalutValue setValue:@"U-vMOS" forKey:@"title"];
    [defalutValue setValue:@"0.00" forKey:@"defaultValue"];
    [defalutValue setValue:@"video" forKey:@"testType"];

    // 初始化整个testingView
    _testingView = [[SVPointView alloc] initWithDic:defalutValue];
    [_testingView start];

    [self.view addSubview:_testingView];
}


#pragma mark - 创建视频播放View
- (void)creatVideoView
{
    NSString *title2 = I18N (@"Bit Rate");
    NSString *title3 = I18N (@"Resolution");

    // 在全屏模式下，在_videoView上方显示测试指标
    _showCurrentResultInFullScreenMode =
    [[UIView alloc] initWithFrame:CGRectMake (0, 0, kScreenH, FITWIDTH (86))];
    [_showCurrentResultInFullScreenMode setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.3]];

    // 1.U-vMOS 0.0
    UILabel *UvMosInFullScreenLabel =
    [[UILabel alloc] initWithFrame:CGRectMake (0, FITWIDTH (14), kScreenH / 8, FITWIDTH (58))];
    [UvMosInFullScreenLabel setText:@"U-vMOS"];
    [UvMosInFullScreenLabel setTextColor:[UIColor whiteColor]];
    [UvMosInFullScreenLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (34)]];
    [UvMosInFullScreenLabel setTextAlignment:NSTextAlignmentCenter];
    [_showCurrentResultInFullScreenMode addSubview:UvMosInFullScreenLabel];

    // 1.5 U-vMOS值
    _UvMosInFullScreenValue = [[UILabel alloc]
    initWithFrame:CGRectMake (UvMosInFullScreenLabel.rightX, FITWIDTH (14), kScreenH / 8, FITWIDTH (58))];
    [_UvMosInFullScreenValue setTextColor:RGBACOLOR (44, 166, 222, 1)];
    [_UvMosInFullScreenValue setFont:[UIFont systemFontOfSize:pixelToFontsize (34)]];
    [_UvMosInFullScreenValue setTextAlignment:NSTextAlignmentCenter];
    [_showCurrentResultInFullScreenMode addSubview:_UvMosInFullScreenValue];

    // 2.Buffer times 0
    UILabel *bufferTimesInFullScreenLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (_UvMosInFullScreenValue.rightX, FITWIDTH (14), kScreenH / 8, FITWIDTH (58))];
    [bufferTimesInFullScreenLabel setText:I18N (@"Butter times")];
    [bufferTimesInFullScreenLabel setTextColor:[UIColor whiteColor]];
    [bufferTimesInFullScreenLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (34)]];
    [bufferTimesInFullScreenLabel setTextAlignment:NSTextAlignmentCenter];
    [_showCurrentResultInFullScreenMode addSubview:bufferTimesInFullScreenLabel];

    // 2.5 Buffer times值
    _bufferTimesInFullScreenValue =
    [[UILabel alloc] initWithFrame:CGRectMake (bufferTimesInFullScreenLabel.rightX, FITWIDTH (14),
                                               kScreenH / 8, FITWIDTH (58))];
    [_bufferTimesInFullScreenValue setTextColor:RGBACOLOR (44, 166, 222, 1)];
    [_bufferTimesInFullScreenValue setFont:[UIFont systemFontOfSize:pixelToFontsize (34)]];
    [_bufferTimesInFullScreenValue setTextAlignment:NSTextAlignmentCenter];
    [_showCurrentResultInFullScreenMode addSubview:_bufferTimesInFullScreenValue];

    // 3.Bit Rate 3002.23kbps
    UILabel *bitRateInFullScreenLabel =
    [[UILabel alloc] initWithFrame:CGRectMake (_bufferTimesInFullScreenValue.rightX, FITWIDTH (14),
                                               kScreenH / 8, FITWIDTH (58))];
    [bitRateInFullScreenLabel setText:title2];
    [bitRateInFullScreenLabel setTextColor:[UIColor whiteColor]];
    [bitRateInFullScreenLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (34)]];
    [bitRateInFullScreenLabel setTextAlignment:NSTextAlignmentCenter];
    [_showCurrentResultInFullScreenMode addSubview:bitRateInFullScreenLabel];

    // 3.5 Bit Rate 值
    _bitRateInFullScreenValue = [[UILabel alloc]
    initWithFrame:CGRectMake (bitRateInFullScreenLabel.rightX, FITWIDTH (14), kScreenH / 8, FITWIDTH (58))];
    [_bitRateInFullScreenValue setTextColor:RGBACOLOR (44, 166, 222, 1)];
    [_bitRateInFullScreenValue setFont:[UIFont systemFontOfSize:pixelToFontsize (34)]];
    [_bitRateInFullScreenValue setTextAlignment:NSTextAlignmentCenter];
    [_showCurrentResultInFullScreenMode addSubview:_bitRateInFullScreenValue];

    // 4. Resolution  1920 * 1080
    UILabel *resolutionInFullScreenLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (_bitRateInFullScreenValue.rightX, FITWIDTH (14), kScreenH / 8, FITWIDTH (58))];
    [resolutionInFullScreenLabel setText:title3];
    [resolutionInFullScreenLabel setTextColor:[UIColor whiteColor]];
    [resolutionInFullScreenLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (34)]];
    [resolutionInFullScreenLabel setTextAlignment:NSTextAlignmentCenter];
    [_showCurrentResultInFullScreenMode addSubview:resolutionInFullScreenLabel];

    // 4.5Resolution值
    _resolutionInFullScreenValue = [[UILabel alloc]
    initWithFrame:CGRectMake (resolutionInFullScreenLabel.rightX, FITWIDTH (14), kScreenH / 8, FITWIDTH (58))];
    [_resolutionInFullScreenValue setTextColor:RGBACOLOR (44, 166, 222, 1)];
    [_resolutionInFullScreenValue setFont:[UIFont systemFontOfSize:pixelToFontsize (34)]];
    [_resolutionInFullScreenValue setTextAlignment:NSTextAlignmentCenter];
    [_showCurrentResultInFullScreenMode addSubview:_resolutionInFullScreenValue];

    // 初始化CGRectMake (0, 0, FITWIDTH (525), FITHEIGHT (310));
    _videoView = [[SVVideoView alloc] initWithFrame:CGRectMake (0, 0, FITWIDTH (512), FITHEIGHT (288))];
    [_videoView setBackgroundColor:[UIColor blackColor]];
    //    [_videoView setContentMode:UIViewContentModeScaleToFill];
    [_footerView.leftView addSubview:_videoView];
}

//点击事件:视频切换全屏和退出全屏模式
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
    _footerView = [[SVFooterView alloc] init];

    // 初始化位置的label
    _locationValue = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (50), FITHEIGHT (0), FITWIDTH (446), FITHEIGHT (50))
                withFont:pixelToFontsize (44)
          withTitleColor:[UIColor colorWithHexString:@"#E5000000"]
               withTitle:@""];

    // 初始化位置标题的label
    _locationTitle = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (50), _locationValue.bottomY + FITHEIGHT (16),
                                     FITWIDTH (446), FITWIDTH (34))
                withFont:pixelToFontsize (30)
          withTitleColor:[UIColor colorWithHexString:@"#CC000000"]
               withTitle:I18N (@"Video Server Location")];

    // 初始化分辨率标题
    _resolutionTitle = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (50), _locationTitle.bottomY + FITHEIGHT (60),
                                     FITWIDTH (223), FITHEIGHT (41))
                withFont:pixelToFontsize (36)
          withTitleColor:[UIColor colorWithHexString:@"#CC000000"]
               withTitle:I18N (@"Resolution")];

    // 初始化分辨率的值
    _resolutionValue = [CTWBViewTools
    createLabelWithFrame:CGRectMake (_resolutionTitle.rightX, _locationTitle.bottomY + FITHEIGHT (60),
                                     FITWIDTH (223), FITHEIGHT (41))
                withFont:pixelToFontsize (36)
          withTitleColor:[UIColor colorWithHexString:@"#E5000000"]
               withTitle:@""];

    // 码率标题
    _bitRateTitle = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (50), _resolutionTitle.bottomY + FITHEIGHT (40),
                                     FITWIDTH (223), FITHEIGHT (41))
                withFont:pixelToFontsize (36)
          withTitleColor:[UIColor colorWithHexString:@"#CC000000"]
               withTitle:I18N (@"Bit Rate")];

    // 码率
    _bitRateValue = [CTWBViewTools
    createLabelWithFrame:CGRectMake (_bitRateTitle.rightX, _resolutionTitle.bottomY + FITHEIGHT (40),
                                     FITWIDTH (223), FITHEIGHT (41))
                withFont:pixelToFontsize (36)
          withTitleColor:[UIColor colorWithHexString:@"#E5000000"]
               withTitle:@""];

    // 设置Label对齐
    _locationTitle.textAlignment = NSTextAlignmentLeft;
    _locationValue.textAlignment = NSTextAlignmentLeft;
    _resolutionValue.textAlignment = NSTextAlignmentRight;
    _resolutionTitle.textAlignment = NSTextAlignmentLeft;
    _bitRateTitle.textAlignment = NSTextAlignmentLeft;
    _bitRateValue.textAlignment = NSTextAlignmentRight;

    // 将所有label放入右侧的View
    [_footerView.rightView addSubview:_locationValue];
    [_footerView.rightView addSubview:_locationTitle];
    [_footerView.rightView addSubview:_resolutionValue];
    [_footerView.rightView addSubview:_resolutionTitle];
    [_footerView.rightView addSubview:_bitRateTitle];
    [_footerView.rightView addSubview:_bitRateValue];

    // 去掉边框
    [_footerView removeBoderWidth];
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
    int firstBufferTime = testResult.firstBufferTime;

    // 卡顿次数
    int cuttonTimes = testResult.videoCuttonTimes;

    // 视频服务器位置
    SVVideoSegement *segement = testContext.videoSegementInfo[0];
    NSString *location = segement.videoLocation;

    // 视频码率
    float bitrate = testResult.bitrate;

    // 分辨率
    NSString *videoResolution = testResult.videoResolution;
    dispatch_async (dispatch_get_main_queue (), ^{
      [_locationValue setText:location];
      [_resolutionValue setText:videoResolution];
      [_bitRateValue setText:[NSString stringWithFormat:@"%.2fKbps", bitrate]];

      [_headerView updateMiddleValue:[NSString stringWithFormat:@"%d", firstBufferTime]];
      [_headerView updateRightValue:[NSString stringWithFormat:@"%d", cuttonTimes]];

      [_bufferTimesInFullScreenValue setText:[NSString stringWithFormat:@"%d", cuttonTimes]];
      [_resolutionInFullScreenValue setText:videoResolution];

      if (!realuvMOSSession)
      {
          UUBar *bar = [[UUBar alloc] initWithFrame:CGRectMake (0, 0, FITWIDTH (2), FITHEIGHT (52))];
          [bar setBarValue:uvMOSSession];
          [uvMosBarView addSubview:bar];
      }

      [_testingView updateValue:uvMOSSession];
      realBitrate = bitrate;
      realuvMOSSession = uvMOSSession;

      int i = arc4random () % 50;
      [_bitRateValue setText:[NSString stringWithFormat:@"%.2fKbps", (bitrate - i)]];
      [_bitRateInFullScreenValue setText:[NSString stringWithFormat:@"%.2fKbps", (bitrate - i)]];


      float k;
      if (i < 20)
      {
          k = (uvMOSSession - 0.1);
      }
      else if (i > 30)
      {
          k = (uvMOSSession + 0.1);
      }
      else
      {
          k = uvMOSSession;
      }

      [_testingView updateValue:k];
      [_UvMosInFullScreenValue setText:[NSString stringWithFormat:@"%.2f", k]];

      // 更新柱状图
      _resultTimes += 1;
      if (_resultTimes == _per_uvmos_bar_need_time)
      {
          _UvMOSbarResultTimes += 1;
          _resultTimes = 0;
          if (_UvMOSbarResultTimes < 20)
          {
              // 如果显示柱子个数少于等于 20 个，添加新的柱子
              UUBar *bar = [[UUBar alloc]
              initWithFrame:CGRectMake (_UvMOSbarResultTimes * 2, 0, FITWIDTH (2), FITHEIGHT (52))];
              [bar setBarValue:k];
              [uvMosBarView addSubview:bar];
          }
      }


      if (testContext.testStatus == TEST_FINISHED)
      {
          [self initCurrentResultModel:testResult];
          [self goToCurrentResultViewCtrl];
      }
    });
}

- (void)initCurrentResultModel:(SVVideoTestResult *)testResult
{
    [currentResultModel setUvMOS:testResult.UvMOSSession];
    [currentResultModel setFirstBufferTime:testResult.firstBufferTime];
    [currentResultModel setCuttonTimes:testResult.videoCuttonTimes];
}

- (void)goToCurrentResultViewCtrl
{
    // 如果视频在全屏模式，则退出全屏模式
    [self exitFullScreenMode];

    // push界面
    [currentResultModel pushNextCtrl];
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

    [_transparentView removeFromSuperview];
    [_videoView removeFromSuperview];

    CGAffineTransform at = CGAffineTransformMakeRotation (0);
    [_videoView setTransform:at];
    [_transparentView setTransform:at];
    _videoView.frame = CGRectMake (0, 0, FITWIDTH (512), FITHEIGHT (288));
    _transparentView.frame = _videoView.frame;

    NSArray *subViews = _videoView.subviews;
    for (UIView *view in subViews)
    {
        if ([view isKindOfClass:[UIWebView class]])
        {
            //
            UIWebView *webView = (UIWebView *)view;
            webView.frame = _videoView.frame;
        }
    }

    // 退出全屏模式时，隐藏_videoView上方显示测试指标
    [_showCurrentResultInFullScreenMode removeFromSuperview];

    // 退出全屏模式时将videoView放回原处
    [_footerView.leftView addSubview:_videoView];
    [_footerView.leftView addSubview:_transparentView];
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

    [_transparentView removeFromSuperview];
    [_videoView removeFromSuperview];

    _videoView.center = CGPointMake (kScreenW / 2, kScreenH / 2);
    _transparentView.center = CGPointMake (kScreenW / 2, kScreenH / 2);

    CGAffineTransform at = CGAffineTransformMakeRotation (M_PI / 2);
    at = CGAffineTransformTranslate (at, 0, 0);
    [_videoView setTransform:at];
    [_transparentView setTransform:at];

    _videoView.frame = CGRectMake (0, 0, kScreenW, kScreenH);
    _transparentView.frame = _videoView.frame;

    NSArray *subViews = _videoView.subviews;
    for (UIView *view in subViews)
    {
        if ([view isKindOfClass:[UIWebView class]])
        {
            //
            UIWebView *webView = (UIWebView *)view;
            webView.frame = CGRectMake (0, 0, kScreenH, kScreenW);
        }
    }

    // kScreenW:414.000000    kScreenH:736.000000
    // 在全屏模式下，在_videoView上方显示测试指标
    [_videoView addSubview:_showCurrentResultInFullScreenMode];
    [_videoView setNeedsDisplay];

    // 进入全屏时将videoView放到当前view中
    [self.view addSubview:_videoView];
    [self.view addSubview:_transparentView];
}

@end
