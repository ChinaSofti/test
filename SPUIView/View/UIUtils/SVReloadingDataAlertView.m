//
//  SVReloadingDataAlertView.m
//  SpeedPro
//
//  Created by Rain on 5/5/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVInitConfig.h"
#import "SVReloadingDataAlertView.h"
#import "SVTestContextGetter.h"

@implementation SVReloadingDataAlertView
{
    float progressVlaue;
    NSTimer *progressTimer;
    UIProgressView *progress;
    UILabel *loadingProcessLabelValue;
}


- (id)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.3]];
    }

    return self;
}

- (void)showAlertView
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];


    UIView *loadDataView = [[UIView alloc] init];
    [loadDataView setSize:CGSizeMake (kScreenW - 50, FITHEIGHT (400))];
    [loadDataView setCenter:CGPointMake (kScreenW / 2, kScreenH / 2)];
    [loadDataView setBackgroundColor:[UIColor colorWithHexString:@"#FFFAFAFA"]];
    //    [loadDataView setBackgroundColor:[UIColor redColor]];
    [loadDataView.layer setCornerRadius:5];

    CGFloat height = loadDataView.frame.size.height;
    CGFloat width = loadDataView.frame.size.width;

    // --------title
    NSString *prompt = I18N (@"Loading Process");
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:pixelToFontsize (52)],
    };

    CGRect textRect = [prompt boundingRectWithSize:CGSizeMake (width, FITHEIGHT (150))
                                           options:NSStringDrawingTruncatesLastVisibleLine
                                        attributes:attributes
                                           context:nil];

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake (0, 0, width, FITHEIGHT (150))];
    UILabel *title = [[UILabel alloc] init];
    [title setSize:CGSizeMake (textRect.size.width, textRect.size.height)];
    [title setText:prompt];
    [title setFont:[UIFont systemFontOfSize:pixelToFontsize (52)]];
    [title setCenter:CGPointMake (titleView.frame.size.width / 2, titleView.frame.size.height / 2)];
    [titleView addSubview:title];
    // --------title  end--

    // --------Content
    UIView *contentView = [[UIView alloc]
    initWithFrame:CGRectMake (0, titleView.frame.size.height, width, height - FITHEIGHT (250))];

    CGFloat contentViewHeight = contentView.frame.size.height;

    UIActivityIndicatorView *activityView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    CGFloat activityViewHeight = activityView.frame.size.height;
    //    [activityView setSize:CGSizeMake (FITWIDTH (100), FITHEIGHT (100))];
    [activityView setOrigin:CGPointMake (FITWIDTH (300), (contentViewHeight - activityViewHeight) / 2)];


    NSString *prepareLabelMessage = I18N (@"Prepareing");
    NSDictionary *attributes2 = @{
        NSFontAttributeName: [UIFont systemFontOfSize:pixelToFontsize (46)],
    };

    CGRect textRect2 = [prepareLabelMessage boundingRectWithSize:CGSizeMake (width, FITHEIGHT (150))
                                                         options:NSStringDrawingTruncatesLastVisibleLine
                                                      attributes:attributes2
                                                         context:nil];
    UILabel *loadingProcessLabel = [[UILabel alloc] init];
    [loadingProcessLabel setSize:CGSizeMake (textRect2.size.width, textRect2.size.height)];
    [loadingProcessLabel setOrigin:CGPointMake (activityView.rightX + FITWIDTH (30),
                                                (contentViewHeight - textRect2.size.height) / 2)];
    [loadingProcessLabel setText:prepareLabelMessage];
    [loadingProcessLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (46)]];

    CGFloat loadingProcessLabelValueWidth = FITWIDTH (150);
    CGFloat loadingProcessLabelValueHeight = FITHEIGHT (80);
    loadingProcessLabelValue = [[UILabel alloc] init];
    [loadingProcessLabelValue setSize:CGSizeMake (loadingProcessLabelValueWidth, loadingProcessLabelValueHeight)];
    [loadingProcessLabelValue
    setOrigin:CGPointMake (loadingProcessLabel.rightX + FITWIDTH (20),
                           (contentViewHeight - loadingProcessLabelValueHeight) / 2)];
    [loadingProcessLabelValue setText:@"0%"];
    [loadingProcessLabelValue setFont:[UIFont systemFontOfSize:pixelToFontsize (46)]];

    [contentView addSubview:activityView];
    [contentView addSubview:loadingProcessLabel];
    [contentView addSubview:loadingProcessLabelValue];
    [activityView startAnimating];
    //    [contentView addSubview:content];
    // --------Content  end--

    // --------进度条
    UIView *progressView =
    [[UIView alloc] initWithFrame:CGRectMake (0, height - FITHEIGHT (100), width, FITHEIGHT (100))];

    CGFloat progressWidth = progressView.frame.size.width - 80;
    CGFloat progressHeight = FITHEIGHT (20);
    progress = [[UIProgressView alloc] init];
    [progress setSize:CGSizeMake (progressWidth, progressHeight)];
    [progress setCenter:CGPointMake (progressView.frame.size.width / 2, progressView.frame.size.height / 2)];
    [progress setProgressViewStyle:UIProgressViewStyleDefault];
    [progressView addSubview:progress];
    // --------进度条  end--

    [loadDataView addSubview:titleView];
    [loadDataView addSubview:contentView];
    [loadDataView addSubview:progressView];

    [self addSubview:loadDataView];
    [keyWindow addSubview:self];

    [self loadResouceFromServer];

    // 启动计算下载速度的定时器，当前时间100ms后，每隔1s执行一次
    progressVlaue = 0.0;
    progressTimer = [NSTimer timerWithTimeInterval:0.5
                                            target:self
                                          selector:@selector (changeProgress)
                                          userInfo:@"Progress"
                                           repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:progressTimer forMode:NSDefaultRunLoopMode];
}

/**
 *  改变进度条进度
 */
- (void)changeProgress
{
    // 如果网络无法连接，则直接进入
    //    SVRealReachability *realReachability = [SVRealReachability sharedInstance];
    //    SVRealReachabilityStatus currentStatus = realReachability.getNetworkStatus;
    //    if (currentStatus == SV_WWANTypeUnknown || currentStatus == SV_RealStatusNotReachable)
    //    {
    //        progressVlaue = 1;
    //        [progress setProgress:progressVlaue];
    //        return;
    //    }

    if (progressVlaue == 1)
    {
        [progressTimer invalidate];
        progressTimer = nil;
        // 关闭当前页面
        [self hideAlertView];
        return;
    }

    // 根据测试数据是否加载完成来显示进度条的进度
    SVTestContextGetter *contextGetter = [SVTestContextGetter sharedInstance];
    if (![contextGetter isInitCompleted])
    {
        if (progressVlaue < 0.8)
        {
            progressVlaue += 0.05;
            [progress setProgress:progressVlaue];
            int v = progressVlaue * 100;
            [loadingProcessLabelValue setText:[NSString stringWithFormat:@"%d%%", v]];
        }
    }
    else
    {
        progressVlaue = 1;
        int v = progressVlaue * 100;
        [loadingProcessLabelValue setText:[NSString stringWithFormat:@"%d%%", v]];
        [progress setProgress:progressVlaue];
    }
}

/**
 *  重新初始化数据
 */
- (void)loadResouceFromServer
{
    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

      SVTestContextGetter *contextGetter = [SVTestContextGetter sharedInstance];
      [contextGetter reInitCompleted];

      // 初始化配置
      [[SVInitConfig sharedManager] loadResouceFromServer];
    });
}

- (void)hideAlertView
{
    [self removeFromSuperview];
}


@end
