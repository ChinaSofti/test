//
//  SVCurrentResultViewCtrl.m
//  SPUIView
//
//  Created by Rain on 2/14/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "CTWBLabel.h"
#import "SVCurrentResultViewCtrl.h"
#import "SVDBManager.h"
#import "SVDetailViewCtrl.h"
#import "SVLabelTools.h"
#import "SVProbeInfo.h"
#import "SVResultPush.h"
#import "SVTestContextGetter.h"
#import "SVTestViewCtrl.h"
#import "SVTimeUtil.h"
//友盟分享
#import "UMSocial.h"
//微信分享
#import "WXApi.h"
//获取分享排名
#import "SVSpeedTestServers.h"

@interface SVCurrentResultViewCtrl () <UMSocialUIDelegate>
//分享
@property (nonatomic, strong) UIButton *greybtn;
@property (nonatomic, strong) UIButton *sharebtn;
@end

@implementation SVCurrentResultViewCtrl

{
    NSMutableArray *_buttons;
    UITableView *_tableView;
    BOOL isSave;

    // 存放结果中各个label的字典
    NSMutableDictionary *allLabelDic;

    NSString *_failTitle;
    NSString *_firstBufferTimeTitle;
    NSString *_cuttonTimesTitle;
    NSString *_responseTimeTitle;
    NSString *_downloadSpeedTitle;
    NSString *_loadTimeTitle;
    NSString *_delayTitle;
    NSString *_uploadSpeedTitle;

    //随机数
    int randomx;
    int rank;

    //当前页面判断标识符
    BOOL currentCtl;

    //获取地域信息
    SVIPAndISP *ipAndISP;

    //分享到界面判断有无标识符
    BOOL shareTo;

    // 3D Touch手势所在的位置
    NSIndexPath *selectedPath;

    // 弹出视图的初始位置
    CGRect sourceRect;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 设置标题
    [self initTitleView];

    //界面一出现,分享到页面是没有的,为NO
    shareTo = NO;

    // 添加返回按钮
    UIBarButtonItem *backButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"homeindicator"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector (backBtnClik)];
    [backButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = backButton;
    // 为了保持平衡添加一个leftBtn
    // 添加返回按钮
    UIBarButtonItem *rightButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector (shareClicked1:)];
    [rightButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightButton;

    // 初始化当前结果页面的View
    UIView *uiview = [[UIView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    uiview.backgroundColor = [UIColor colorWithHexString:@"FAFAFA"];

    // 把tableView添加到 view
    _tableView = [self createTableViewWithRect:CGRectMake (0, 0, kScreenW, FITHEIGHT (1242))
                                     WithStyle:UITableViewStyleGrouped
                                     WithColor:[UIColor colorWithHexString:@"#FAFAFA"]
                                  WithDelegate:self
                                WithDataSource:self];
    [uiview addSubview:_tableView];

    // 把button添加到 view
    [uiview addSubview:self.buildTestBtn];

    self.view = uiview;

    // 判断3D Touch是否可用，可用则注册
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 &&
        self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
    {
        [self registerForPreviewingWithDelegate:self sourceView:uiview];
    }

    // 初始化表格数据
    [self initButtons];

    // 表格重绘
    [_tableView reloadData];
}

/**
 *开始测试按钮初始化(按钮未被选中时的状态)
 **/
- (UIButton *)buildTestBtn
{
    NSString *testAgain = I18N (@"Test Again");

    // 按钮高度
    CGFloat testBtnH = FITHEIGHT (116);

    // 按钮类型
    UIButton *_reTestButton = [UIButton buttonWithType:UIButtonTypeCustom];

    // 按钮尺寸
    _reTestButton.frame = CGRectMake (FITWIDTH (104), FITHEIGHT (1466), FITWIDTH (872), testBtnH);

    // 按钮圆角
    _reTestButton.layer.cornerRadius = svCornerRadius (12);

    // 设置按钮的背景色
    _reTestButton.backgroundColor = [UIColor colorWithHexString:@"#29A5E5"];

    // 按钮文字颜色和类型
    [_reTestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    // 设置居中
    _reTestButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    // 设置字体大小
    _reTestButton.titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (48)];

    // 按钮文字和类型
    [_reTestButton setTitle:testAgain forState:UIControlStateNormal];

    // 按钮点击事件
    [_reTestButton addTarget:self
                      action:@selector (testBtnClick)
            forControlEvents:UIControlEventTouchUpInside];

    return _reTestButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    SVProbeInfo *probe = [[SVProbeInfo alloc] init];
    [probe setIsTesting:NO];

    //添加同步锁(同时只能有一个发生)
    @synchronized (self)
    {
        //屏幕即将出现标识符设置为yes
        currentCtl = YES;
    }
    // 设置屏幕自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    // 刷新视频
    UILabel *_uVMosLabel = [allLabelDic valueForKey:@"videoLeftValueLabel"];
    UILabel *_uVMosUnitLabel = [allLabelDic valueForKey:@"videoLeftUnitLabel"];
    if (_resultModel.uvMOS == -1)
    {
        [_uVMosLabel setText:_failTitle];
    }
    else
    {
        [_uVMosLabel setText:[NSString stringWithFormat:@"%.2f", _resultModel.uvMOS]];
    }

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:_uVMosLabel
                                  UnitLabel:_uVMosUnitLabel
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];


    UILabel *_firstBufferTimeLabelValue = [allLabelDic valueForKey:@"videoMiddleValueLabel"];
    UILabel *_firstBufferTimeLabelUnit = [allLabelDic valueForKey:@"videoMiddleUnitLabel"];
    if (_resultModel.firstBufferTime == -1)
    {
        [_firstBufferTimeLabelValue setText:_failTitle];
        [_firstBufferTimeLabelUnit setText:@""];
    }
    else
    {
        [_firstBufferTimeLabelValue setText:[NSString stringWithFormat:@"%d", _resultModel.firstBufferTime]];
        [_firstBufferTimeLabelUnit setText:@"ms"];
    }

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:_firstBufferTimeLabelValue
                                  UnitLabel:_firstBufferTimeLabelUnit
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];

    UILabel *_cuttonTimesLabelValue = [allLabelDic valueForKey:@"videoRightValueLabel"];
    UILabel *_cuttonTimesLabelUnit = [allLabelDic valueForKey:@"videoRightUnitLabel"];
    if (_resultModel.cuttonTimes == -1)
    {
        [_cuttonTimesLabelValue setText:_failTitle];
    }
    else
    {
        [_cuttonTimesLabelValue setText:[NSString stringWithFormat:@"%d", _resultModel.cuttonTimes]];
    }

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:_cuttonTimesLabelValue
                                  UnitLabel:_cuttonTimesLabelUnit
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];

    // 刷新网页
    UILabel *_responseLabelValue = [allLabelDic valueForKey:@"webLeftValueLabel"];
    UILabel *_responseLabelUnit = [allLabelDic valueForKey:@"webLeftUnitLabel"];
    if (_resultModel.responseTime < 0)
    {
        [_responseLabelValue setText:_failTitle];
        [_responseLabelUnit setText:@""];
    }
    else
    {
        [_responseLabelValue setText:[NSString stringWithFormat:@"%.2f", _resultModel.responseTime]];
        [_responseLabelUnit setText:@"s"];
    }

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:_responseLabelValue
                                  UnitLabel:_responseLabelUnit
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];

    UILabel *_loadLabelValue = [allLabelDic valueForKey:@"webRightValueLabel"];
    UILabel *_loadLabelUnit = [allLabelDic valueForKey:@"webRightUnitLabel"];
    if (_resultModel.totalTime < 0)
    {
        [_loadLabelValue setText:_failTitle];
        [_loadLabelUnit setText:@""];
    }
    else
    {
        [_loadLabelValue setText:[NSString stringWithFormat:@"%.2f", _resultModel.totalTime]];
        [_loadLabelUnit setText:@"s"];
    }

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:_loadLabelValue
                                  UnitLabel:_loadLabelUnit
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];

    UILabel *_downloadLabelValue = [allLabelDic valueForKey:@"webMiddleValueLabel"];
    UILabel *_downloadLabelUnit = [allLabelDic valueForKey:@"webMiddleUnitLabel"];
    if (_resultModel.downloadSpeed < 0)
    {
        [_downloadLabelValue setText:_failTitle];
        [_downloadLabelUnit setText:@""];
    }
    else
    {
        [_downloadLabelValue setText:[NSString stringWithFormat:@"%.2f", _resultModel.downloadSpeed]];
        [_downloadLabelUnit setText:@"kbps"];
    }

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:_downloadLabelValue
                                  UnitLabel:_downloadLabelUnit
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];

    // 刷新带宽
    UILabel *_dtDelayLabelValue = [allLabelDic valueForKey:@"speedLeftValueLabel"];
    UILabel *_dtDelayLabelUnit = [allLabelDic valueForKey:@"speedLeftUnitLabel"];
    if (_resultModel.stDelay <= 0)
    {
        [_dtDelayLabelValue setText:_failTitle];
        [_dtDelayLabelUnit setText:@""];
    }
    else
    {
        [_dtDelayLabelValue setText:[NSString stringWithFormat:@"%.0f", _resultModel.stDelay]];
        [_dtDelayLabelUnit setText:@"ms"];
    }

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:_dtDelayLabelValue
                                  UnitLabel:_dtDelayLabelUnit
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];

    UILabel *_dtDownloadLabelValue = [allLabelDic valueForKey:@"speedMiddleValueLabel"];
    UILabel *_dtDownloadLabelUnit = [allLabelDic valueForKey:@"speedMiddleUnitLabel"];
    if (_resultModel.stDownloadSpeed <= 0)
    {
        [_dtDownloadLabelValue setText:_failTitle];
        [_dtDownloadLabelUnit setText:@""];
    }
    else
    {
        [_dtDownloadLabelValue setText:[NSString stringWithFormat:@"%.2f", _resultModel.stDownloadSpeed]];
        [_dtDownloadLabelUnit setText:@"Mbps"];
    }

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:_dtDownloadLabelValue
                                  UnitLabel:_dtDownloadLabelUnit
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];

    UILabel *_dtUploadLabelValue = [allLabelDic valueForKey:@"speedRightValueLabel"];
    UILabel *_dtUploadLabelUnit = [allLabelDic valueForKey:@"speedRightUnitLabel"];
    if (_resultModel.stUploadSpeed <= 0)
    {
        [_dtUploadLabelValue setText:_failTitle];
        [_dtUploadLabelUnit setText:@""];
    }
    else
    {
        [_dtUploadLabelValue setText:[NSString stringWithFormat:@"%.2f", _resultModel.stUploadSpeed]];
        [_dtUploadLabelUnit setText:@"Mbps"];
    }

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:_dtUploadLabelValue
                                  UnitLabel:_dtUploadLabelUnit
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];

    // 持久化测试结果
    if (!isSave)
    {
        [self persistData];
        isSave = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    //添加同步锁(同时只有一个发生)
    @synchronized (self)
    {
        //屏幕即将消失标识符设置为no
        currentCtl = NO;
    }
    [super viewWillDisappear:animated];
}
- (void)persistData
{
    SVInfo (@"persistData");
    [self persistTestResultDetail];
    [self persistSVSummaryResultModel];
    // 判断用户是否允许上传结果，如果允许，则将测试结果上传
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    if (probeInfo.isUploadResult)
    {
        dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

          [self cleanOldData];
          SVResultPush *push = [[SVResultPush alloc] initWithTestId:_resultModel.testId];
          [push sendResult:^(NSData *responseData, NSError *error) {
            if (error)
            {
                //
                SVError (@"send result to server fail. not show sharing UI.");
                return;
            }

            NSError *err;
            id jsonStr = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
            if (error)
            {
                SVInfo (@"解析服务器返回数据失败,排名计算失败,"
                        @"不在弹出分享页面");
                return;
            }
            NSString *strTotalCount = [jsonStr valueForKey:@"totalCount"];
            NSString *strCurrentPosition = [jsonStr valueForKey:@"currentPosition"];
            double totalCount = [strTotalCount doubleValue];
            double currentPosition = [strCurrentPosition doubleValue];
            rank = (totalCount - currentPosition) * 100 / totalCount;

            SVInfo (@"totalCoutn:%@,currentPosition:%@,rank:%d", strTotalCount, strCurrentPosition, rank);
            //单写一个线程,结果传回来后显示UI
            dispatch_async (dispatch_get_main_queue (), ^{
              [self createShareUI];
            });
          }];

        });
    }
}

- (void)cleanOldData
{
    SVDBManager *db = [SVDBManager sharedInstance];
    // 判断结果是否超过限制，如果超出限制，则删除多余数据
    int resultNum = [db executeCountQuery:@"SELECT COUNT(*) FROM SVSummaryResultModel;"];
    if (resultNum > 200)
    {
        // 删除最早的数据
        [db executeUpdate:@"DELETE FROM SVSummaryResultModel WHERE id in (SELECT id FROM "
                          @"SVSummaryResultModel ORDER BY testTime asc LIMIT 101);"];
    }
}

- (void)persistTestResultDetail
{
    SVDBManager *db = [SVDBManager sharedInstance];
    // 如果表不存在，则创建表
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS SVDetailResultModel(ID integer PRIMARY KEY "
                      @"AUTOINCREMENT, testId integer, testType integer, testResult  text, "
                      @"testContext text, probeInfo text);"];


    NSArray *array = [_resultModel testObjArray];
    for (NSString *insertSVDetailResultModelSQL in array)
    {
        [db executeUpdate:insertSVDetailResultModelSQL];
    }
}

- (id)initWithResultModel:(SVCurrentResultModel *)resultModel
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    _resultModel = resultModel;
    _buttons = [[NSMutableArray alloc] init];
    isSave = NO;
    return self;
}

/**
 * 初始化结果按钮，点击进入详细结果页面
 */
- (void)initButtons
{
    // 初始化标题
    _failTitle = I18N (@"Fail");
    _firstBufferTimeTitle = I18N (@"Initial Buffer Time");
    _cuttonTimesTitle = I18N (@"Stalling Times");
    _responseTimeTitle = I18N (@"Response Time");
    _downloadSpeedTitle = I18N (@"Download Speed");
    _loadTimeTitle = I18N (@"Load duration");
    _delayTitle = I18N (@"Delay");
    _uploadSpeedTitle = I18N (@"Upload speed");

    // 初始化字典
    allLabelDic = [[NSMutableDictionary alloc] init];

    // 初始化三种测试对应的结果按钮
    if (_resultModel.videoTest == YES)
    {
        // 创建按钮
        UIButton *videoResultBtn = [self creatResultBtn];
        [videoResultBtn addTarget:self
                           action:@selector (CellVideoDetailClick:)
                 forControlEvents:UIControlEventTouchUpInside];

        // 创建左侧图片
        UIImageView *videoImageView = [self createResultImageViewWithName:@"ic_video_label"];

        // 字体颜色
        UIColor *color = [UIColor colorWithHexString:@"#FEB960"];

        // 创建左侧指标的view
        NSString *leftValue = _failTitle;
        NSString *leftUnit = @"";
        if (_resultModel.uvMOS && _resultModel.uvMOS != -1)
        {
            leftValue = [NSString stringWithFormat:@"%.2f", _resultModel.uvMOS];
        }
        UILabel *leftView = [self createResultViewWithName:@"videoLeft"
                                                     WithX:FITWIDTH (268)
                                                 WithTitle:@"U-vMOS"
                                                 WithValue:leftValue
                                            WithValueColor:color
                                                  WithUnit:leftUnit
                                             WithUnitColor:color];

        // 创建中间指标的view
        NSString *middleValue = I18N (@"Fail");
        NSString *middleUnit = @"";
        if (_resultModel.firstBufferTime && _resultModel.firstBufferTime != -1)
        {
            middleValue = [NSString stringWithFormat:@"%d", _resultModel.firstBufferTime];
            middleUnit = @"ms";
        }
        UILabel *middleView = [self createResultViewWithName:@"videoMiddle"
                                                       WithX:leftView.rightX
                                                   WithTitle:_firstBufferTimeTitle
                                                   WithValue:middleValue
                                              WithValueColor:color
                                                    WithUnit:middleUnit
                                               WithUnitColor:color];

        // 创建右侧指标的view
        NSString *rightValue = I18N (@"Fail");
        NSString *rightUnit = @"";
        if (_resultModel.cuttonTimes != -1)
        {
            rightValue = [NSString stringWithFormat:@"%d", _resultModel.cuttonTimes];
            rightUnit = @"";
        }
        UILabel *rightView = [self createResultViewWithName:@"videoRight"
                                                      WithX:middleView.rightX
                                                  WithTitle:_cuttonTimesTitle
                                                  WithValue:rightValue
                                             WithValueColor:color
                                                   WithUnit:rightUnit
                                              WithUnitColor:color];

        [videoResultBtn addSubview:videoImageView];
        [videoResultBtn addSubview:leftView];
        [videoResultBtn addSubview:middleView];
        [videoResultBtn addSubview:rightView];
        [videoResultBtn setTag:0];
        [_buttons addObject:videoResultBtn];
    }
    if (_resultModel.webTest == YES)
    {
        // 创建按钮
        UIButton *webResultBtn = [self creatResultBtn];
        [webResultBtn addTarget:self
                         action:@selector (CellWebDetailClick:)
               forControlEvents:UIControlEventTouchUpInside];

        // 创建左侧图片
        UIImageView *webImageView = [self createResultImageViewWithName:@"ic_web_label"];

        // 字体颜色
        UIColor *color = [UIColor colorWithHexString:@"#38C695"];

        // 创建左侧指标的view
        NSString *leftValue = I18N (@"Fail");
        NSString *leftUnit = @"";
        if (_resultModel.responseTime && _resultModel.responseTime != -1)
        {
            leftValue = [NSString stringWithFormat:@"%.2f", _resultModel.responseTime];
            leftUnit = @"s";
        }
        UILabel *leftView = [self createResultViewWithName:@"webLeft"
                                                     WithX:FITWIDTH (268)
                                                 WithTitle:_responseTimeTitle
                                                 WithValue:leftValue
                                            WithValueColor:color
                                                  WithUnit:leftUnit
                                             WithUnitColor:color];

        // 创建中间指标的view
        NSString *middleValue = I18N (@"Fail");
        NSString *middleUnit = @"";
        if (_resultModel.downloadSpeed && _resultModel.downloadSpeed != -1)
        {
            middleValue = [NSString stringWithFormat:@"%.2f", _resultModel.downloadSpeed];
            middleUnit = @"Kbps";
        }
        UILabel *middleView = [self createResultViewWithName:@"webMiddle"
                                                       WithX:leftView.rightX
                                                   WithTitle:_downloadSpeedTitle
                                                   WithValue:middleValue
                                              WithValueColor:color
                                                    WithUnit:middleUnit
                                               WithUnitColor:color];

        // 创建右侧指标的view
        NSString *rightValue = I18N (@"Fail");
        NSString *rightUnit = @"";
        if (_resultModel.totalTime && _resultModel.totalTime != -1)
        {
            rightValue = [NSString stringWithFormat:@"%.2f", _resultModel.totalTime];
            rightUnit = @"s";
        }
        UILabel *rightView = [self createResultViewWithName:@"webRight"
                                                      WithX:middleView.rightX
                                                  WithTitle:_loadTimeTitle
                                                  WithValue:rightValue
                                             WithValueColor:color
                                                   WithUnit:rightUnit
                                              WithUnitColor:color];

        [webResultBtn addSubview:webImageView];
        [webResultBtn addSubview:leftView];
        [webResultBtn addSubview:middleView];
        [webResultBtn addSubview:rightView];
        [webResultBtn setTag:1];
        [_buttons addObject:webResultBtn];
    }
    if (_resultModel.speedTest == YES)
    {
        // 创建按钮
        UIButton *speedResultBtn = [self creatResultBtn];
        [speedResultBtn addTarget:self
                           action:@selector (CellSpeedDetailClick:)
                 forControlEvents:UIControlEventTouchUpInside];

        // 创建左侧图片
        UIImageView *speedImageView = [self createResultImageViewWithName:@"ic_speed_label"];

        // 字体颜色
        UIColor *color = [UIColor colorWithHexString:@"#FC5F45"];

        // 创建左侧指标的view
        NSString *leftValue = I18N (@"Fail");
        NSString *leftUnit = @"";
        if (_resultModel.stDelay && _resultModel.stDelay != -1)
        {
            leftValue = [NSString stringWithFormat:@"%.0f", _resultModel.stDelay];
            leftUnit = @"ms";
        }
        UILabel *leftView = [self createResultViewWithName:@"speedLeft"
                                                     WithX:FITWIDTH (268)
                                                 WithTitle:_delayTitle
                                                 WithValue:leftValue
                                            WithValueColor:color
                                                  WithUnit:leftUnit
                                             WithUnitColor:color];

        // 创建中间指标的view
        NSString *middleValue = I18N (@"Fail");
        NSString *middleUnit = @"";
        if (_resultModel.stDownloadSpeed && _resultModel.stDownloadSpeed != -1)
        {
            middleValue = [NSString stringWithFormat:@"%.2f", _resultModel.stDownloadSpeed];
            middleUnit = @"Mbps";
        }
        UILabel *middleView = [self createResultViewWithName:@"speedMiddle"
                                                       WithX:leftView.rightX
                                                   WithTitle:_downloadSpeedTitle
                                                   WithValue:middleValue
                                              WithValueColor:color
                                                    WithUnit:middleUnit
                                               WithUnitColor:color];

        // 创建右侧指标的view
        NSString *rightValue = I18N (@"Fail");
        NSString *rightUnit = @"";
        if (_resultModel.stUploadSpeed && _resultModel.stUploadSpeed != -1)
        {
            rightValue = [NSString stringWithFormat:@"%.2f", _resultModel.stUploadSpeed];
            rightUnit = @"Mbps";
        }
        UILabel *rightView = [self createResultViewWithName:@"speedRight"
                                                      WithX:middleView.rightX
                                                  WithTitle:_uploadSpeedTitle
                                                  WithValue:rightValue
                                             WithValueColor:color
                                                   WithUnit:rightUnit
                                              WithUnitColor:color];


        [speedResultBtn addSubview:speedImageView];
        [speedResultBtn addSubview:leftView];
        [speedResultBtn addSubview:middleView];
        [speedResultBtn addSubview:rightView];
        [speedResultBtn setTag:2];
        [_buttons addObject:speedResultBtn];
    }
}

/**
 * 创建结果按钮
 */
- (UIButton *)creatResultBtn
{
    UIButton *_bgdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _bgdBtn.frame = CGRectMake (FITWIDTH (22), 0, FITWIDTH (1036), FITHEIGHT (209));
    _bgdBtn.layer.cornerRadius = svCornerRadius (12);
    _bgdBtn.layer.borderColor = [UIColor colorWithHexString:@"#DDDDDD"].CGColor;
    _bgdBtn.layer.borderWidth = FITHEIGHT (1);
    _bgdBtn.backgroundColor = [UIColor whiteColor];
    return _bgdBtn;
}

/**
 * 创建结果对应的图片
 */
- (UIImageView *)createResultImageViewWithName:(NSString *)imageName
{
    CGFloat imgViewWAndH = FITHEIGHT (93);
    UIImageView *_imgView = [[UIImageView alloc]
    initWithFrame:CGRectMake (FITWIDTH (60), FITHEIGHT (58), imgViewWAndH, imgViewWAndH)];
    _imgView.image = [UIImage imageNamed:imageName];
    return _imgView;
}

/**
 * 创建每条结果行中左中右的UIView,用于放置指标值和指标名称等
 */
- (UILabel *)createResultViewWithName:(NSString *)labelName
                                WithX:(double)x
                            WithTitle:(NSString *)title
                            WithValue:(NSString *)value
                       WithValueColor:(UIColor *)valueColor
                             WithUnit:(NSString *)unit
                        WithUnitColor:(UIColor *)unitColor
{
    // 创建view
    UILabel *resultView = [[UILabel alloc] initWithFrame:CGRectMake (x, 0, FITWIDTH (256), FITHEIGHT (209))];

    // 创建view中的标题label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (30)];
    titleLabel.textColor = [UIColor colorWithHexString:@"#000000"];

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithTitleLabel:titleLabel
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (136)];

    // 创建指标值的label
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:pixelToFontsize (60)];
    valueLabel.textColor = valueColor;

    // 创建单位的label
    UILabel *unitLabel = [[UILabel alloc] init];
    unitLabel.text = unit;
    unitLabel.font = [UIFont systemFontOfSize:pixelToFontsize (33)];
    unitLabel.textColor = unitColor;

    // 使Label根据内容自适应大小
    [SVLabelTools resetLayoutWithValueLabel:valueLabel
                                  UnitLabel:unitLabel
                                  WithWidth:FITWIDTH (256)
                                 WithHeight:FITHEIGHT (209)
                                      WithY:FITHEIGHT (58)];

    // 将Label放入字典
    NSString *keyStr = [NSString stringWithFormat:@"%@TitleLabel", labelName];
    [allLabelDic setValue:titleLabel forKey:keyStr];
    keyStr = [NSString stringWithFormat:@"%@ValueLabel", labelName];
    [allLabelDic setValue:valueLabel forKey:keyStr];
    keyStr = [NSString stringWithFormat:@"%@UnitLabel", labelName];
    [allLabelDic setValue:unitLabel forKey:keyStr];

    // 将Label放入父View
    [resultView addSubview:titleLabel];
    [resultView addSubview:valueLabel];
    [resultView addSubview:unitLabel];

    return resultView;
}

/**
 *  持久化汇总结果
 */
- (void)persistSVSummaryResultModel
{
    // 结果持久化
    SVDBManager *db = [SVDBManager sharedInstance];

    // 如果表不存在，则创建表
    [db
    executeUpdate:@"CREATE TABLE IF NOT EXISTS SVSummaryResultModel(ID integer PRIMARY KEY "
                  @"AUTOINCREMENT, testId integer, type integer, testTime integer, UvMOS "
                  @"real, loadTime integer, bandwidth real, videoTest integer, webTest integer, "
                  @"speedTest integer);"];

    // 获取网络类型
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    int networkType = probeInfo.networkType;

    NSString *insertSVSummaryResultModelSQL =
    [NSString stringWithFormat:@"INSERT INTO "
                               @"SVSummaryResultModel(testId,type,testTime,UvMOS,loadTime,"
                               @"bandwidth,videoTest,webTest,speedTest)VALUES(%lld, %d, %lld, %lf, "
                               @"%lf, %lf, %d, %d, %d);",
                               _resultModel.testId, networkType, _resultModel.testId,
                               _resultModel.uvMOS, _resultModel.totalTime, _resultModel.stDownloadSpeed,
                               _resultModel.videoTest, _resultModel.webTest, _resultModel.speedTest];
    // 插入汇总结果
    [db executeUpdate:insertSVSummaryResultModelSQL];
}

//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _buttons.count;
}
//设置 tableView的 numberOfRowsInSection(设置每个section中有几个cell)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"aCell"];

        //取消cell 被点中的效果
        //        cell.backgroundColor = [UIColor redColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    if (_buttons.count == 0)
    {
        return cell;
    }

    UIButton *button = [_buttons objectAtIndex:indexPath.section];
    [cell addSubview:button];
    return cell;
}

//设置 tableView 的 sectionHeader蓝色 的header的有无
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
//设置tableView的 sectionFooter黑色 的Footer的有无
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return FITHEIGHT (30);
}
//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FITHEIGHT (209);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *进入视频测试结果详情界面
 **/

- (void)CellVideoDetailClick:(UIButton *)sender
{
    [self CellDetailClick:sender testType:@"0"];
}

/**
 *cell的点击事件进入详情界面
 **/

- (void)CellWebDetailClick:(UIButton *)sender
{
    [self CellDetailClick:sender testType:@"1"];
}

/**
 *cell的点击事件进入详情界面
 **/

- (void)CellSpeedDetailClick:(UIButton *)sender
{
    [self CellDetailClick:sender testType:@"2"];
}

/**
 *cell的点击事件进入详情界面
 **/

- (void)CellDetailClick:(UIButton *)sender testType:(NSString *)testType
{
    //按钮点击后alloc一个界面
    SVDetailViewCtrl *detailViewCtrl = [[SVDetailViewCtrl alloc] init];
    [detailViewCtrl setTestId:_resultModel.testId];
    [detailViewCtrl setTestType:testType];

    //隐藏hidesBottomBarWhenPushed
    self.hidesBottomBarWhenPushed = YES;

    // push界面
    [self.navigationController pushViewController:detailViewCtrl animated:YES];

    //返回时显示hidesBottomBarWhenPushed
    self.hidesBottomBarWhenPushed = NO;
}

/**
 *  返回重新测试页面
 */
- (void)testBtnClick
{
    SVInfo (@"back to testting view");

    // 设置屏幕不会休眠
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    // 将已经推送完成的controller重新放入待推送的controller数组
    [_resultModel copyCompleteCtrlToCtrlArray];

    // 每次重新测试需要将testId重置一下
    [_resultModel setTestId:[SVTimeUtil currentMilliSecondStamp]];

    // 将结果保存标志位设置为no
    isSave = NO;

    // 重新测试
    [_resultModel pushNextCtrl];
}

/**
 *  回退到测试页面
 */
- (void)backBtnClik
{
    SVInfo (@"back to test view");
    [[_resultModel navigationController] popToRootViewControllerAnimated:NO];
}

#pragma mark - 分享页面

- (void)createShareUI
{
    randomx = rank;
    SVInfo (@"排名为%d", randomx);
    //判断如果随机数不大于0就退出
    if (randomx < 0)
    {
        SVInfo (@"排名小于0,不弹出分享界面");
        return;
    }

    //创建一个覆盖garybutton
    _greybtn = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    _greybtn.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.0];
    [_greybtn addTarget:self
                 action:@selector (greyBtnBackClick)
       forControlEvents:UIControlEventTouchUpInside];
    //创建背景图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.size = CGSizeMake (kScreenW, kScreenH * 0.8);
    imageView.image = [UIImage imageNamed:@"draw_background"];
    imageView.center = CGPointMake (_greybtn.frame.size.width / 2, _greybtn.frame.size.height / 2);
    //创建人物图片
    UIImageView *imageViewPeople = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageViewPeople.size = CGSizeMake (kScreenW * 0.6, kScreenW * 0.6);
    //根据随机数显示图片
    if (randomx >= 95)
    {
        imageViewPeople.image = [UIImage imageNamed:@"speed_level_frist"];
    }
    if (randomx >= 80 && randomx <= 95)
    {
        imageViewPeople.image = [UIImage imageNamed:@"speed_level_second"];
    }
    if (randomx >= 60 && randomx <= 80)
    {
        imageViewPeople.image = [UIImage imageNamed:@"speed_level_thrid"];
    }
    if (randomx >= 10 && randomx <= 60)
    {
        imageViewPeople.image = [UIImage imageNamed:@"speed_level_forth"];
    }
    if (randomx >= 0 && randomx <= 10)
    {
        imageViewPeople.image = [UIImage imageNamed:@"speed_level_last"];
    }
    imageViewPeople.center = CGPointMake (_greybtn.frame.size.width / 2, _greybtn.frame.size.height / 1.8);
    //创建打败用户描述文字
    CTWBLabel *descriptionLabel1;
    CTWBLabel *descriptionLabel2;
    CTWBLabel *descriptionLabel3;
    //根据语言不同显示不通文字
    SVI18N *language = [SVI18N sharedInstance];
    NSString *myLanguage = [language getLanguage];
    if ([myLanguage isEqualToString:@"zh"])
    {
        descriptionLabel1 = [[CTWBLabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (60), FITHEIGHT (300), FITWIDTH (400), FITHEIGHT (180))];
        descriptionLabel1.text = I18N (@"YOU'VE DEFEATED");
        descriptionLabel1.textAlignment = NSTextAlignmentRight;
        [descriptionLabel1
        setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:pixelToFontsize (90)]];
        //        descriptionLabel1.backgroundColor = [UIColor yellowColor];

        descriptionLabel2 =
        [[CTWBLabel alloc] initWithFrame:CGRectMake (descriptionLabel1.rightX - FITWIDTH (10),
                                                     FITHEIGHT (270), FITWIDTH (200), FITHEIGHT (180))];
        descriptionLabel2.text = [NSString stringWithFormat:@"%d", randomx];
        descriptionLabel2.textAlignment = NSTextAlignmentCenter;
        [descriptionLabel2
        setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:pixelToFontsize (160)]];
        //        descriptionLabel2.backgroundColor = [UIColor redColor];

        descriptionLabel3 =
        [[CTWBLabel alloc] initWithFrame:CGRectMake (descriptionLabel2.rightX - FITWIDTH (10),
                                                     FITHEIGHT (300), FITWIDTH (400), FITHEIGHT (180))];
        descriptionLabel3.text = I18N (@"%OF ALL USERS");
        descriptionLabel3.textAlignment = NSTextAlignmentLeft;
        [descriptionLabel3
        setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:pixelToFontsize (90)]];
        //        descriptionLabel3.backgroundColor = [UIColor yellowColor];
    }
    else
    {
        descriptionLabel1 = [[CTWBLabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (30), FITHEIGHT (300), FITWIDTH (480), FITHEIGHT (180))];
        descriptionLabel1.text = I18N (@"YOU'VE DEFEATED");
        descriptionLabel1.textAlignment = NSTextAlignmentCenter;
        [descriptionLabel1
        setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:pixelToFontsize (50)]];
        //    descriptionLabel1.backgroundColor = [UIColor yellowColor];
        descriptionLabel2 =
        [[CTWBLabel alloc] initWithFrame:CGRectMake (descriptionLabel1.rightX - FITWIDTH (30),
                                                     FITHEIGHT (270), FITWIDTH (150), FITHEIGHT (180))];
        descriptionLabel2.text = [NSString stringWithFormat:@"%d", randomx];
        descriptionLabel2.textAlignment = NSTextAlignmentCenter;
        [descriptionLabel2
        setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:pixelToFontsize (90)]];
        //    descriptionLabel2.backgroundColor = [UIColor redColor];
        descriptionLabel3 =
        [[CTWBLabel alloc] initWithFrame:CGRectMake (descriptionLabel2.rightX - FITWIDTH (30),
                                                     FITHEIGHT (300), FITWIDTH (430), FITHEIGHT (180))];
        descriptionLabel3.text = I18N (@"%OF ALL USERS");
        descriptionLabel3.textAlignment = NSTextAlignmentCenter;
        [descriptionLabel3
        setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:pixelToFontsize (50)]];
        //    descriptionLabel3.backgroundColor = [UIColor yellowColor];
    }

    //添加固定文字
    UILabel *fixLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (0, descriptionLabel1.bottomY - FITHEIGHT (30), kScreenW, FITHEIGHT (90))];
    fixLabel.text = I18N (@"Red Envelope Snatching Level ");
    fixLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    fixLabel.alpha = 0.9;
    [fixLabel setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:pixelToFontsize (50)]];
    fixLabel.textAlignment = NSTextAlignmentCenter;

    //添加图片文字背景
    UIImageView *imageViewBg = [[UIImageView alloc]
    initWithFrame:CGRectMake (0, imageViewPeople.bottomY - FITHEIGHT (140), FITWIDTH (641), FITHEIGHT (140))];
    imageViewBg.image = [UIImage imageNamed:@"sharebackground"];
    imageViewBg.centerX = self.view.centerX;

    //添加图片文字
    UILabel *imageViewBgLabel =
    [[UILabel alloc] initWithFrame:CGRectMake (0, 0, FITWIDTH (641), FITHEIGHT (140))];
    //根据随机数显示文字
    NSString *imageViewBgLabelText;
    if (randomx >= 95)
    {
        imageViewBgLabelText = I18N (@"Mastery");
    }
    if (randomx >= 80 && randomx <= 95)
    {
        imageViewBgLabelText = I18N (@"Expertise");
    }
    if (randomx >= 60 && randomx <= 80)
    {
        imageViewBgLabelText = I18N (@"Proficiency");
    }
    if (randomx >= 10 && randomx <= 60)
    {
        imageViewBgLabelText = I18N (@"Competence");
    }
    if (randomx >= 0 && randomx <= 10)
    {
        imageViewBgLabelText = I18N (@"Novice");
    }
    imageViewBgLabel.text = imageViewBgLabelText;
    imageViewBgLabel.textColor = [UIColor orangeColor];
    [imageViewBgLabel
    setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:pixelToFontsize (90)]];
    imageViewBgLabel.textAlignment = NSTextAlignmentCenter;
    //添加组件
    [imageView addSubview:descriptionLabel1];
    [imageView addSubview:descriptionLabel3];
    [imageView addSubview:descriptionLabel2];
    [imageView addSubview:fixLabel];
    [_greybtn addSubview:imageView];
    [_greybtn addSubview:imageViewPeople];
    [imageViewBg addSubview:imageViewBgLabel];
    [_greybtn addSubview:imageViewBg];


    //创建一个按钮
    _sharebtn = [[UIButton alloc]
    initWithFrame:CGRectMake (kScreenW * 0.03, kScreenH * 0.82, kScreenW * 0.94, kScreenH * 0.08)];
    //设置文字
    NSString *str6 = I18N (@"Share");
    [_sharebtn setTitle:str6 forState:UIControlStateNormal];
    //文字颜色
    [_sharebtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //文字大小
    _sharebtn.titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (70)];
    //按钮背景颜色
    [_sharebtn setBackgroundImage:[CTWBViewTools imageWithColor:[UIColor lightGrayColor]
                                                           size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                         forState:UIControlStateHighlighted];
    [_sharebtn setBackgroundImage:[CTWBViewTools imageWithColor:[UIColor orangeColor]
                                                           size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                         forState:UIControlStateNormal];

    [_sharebtn addTarget:self
                  action:@selector (shareBtnClick)
        forControlEvents:UIControlEventTouchUpInside];
    //添加
    [_greybtn addSubview:_sharebtn];
    @synchronized (self)
    {
        if (currentCtl)
        {
            [self.view addSubview:_greybtn];
            SVInfo (@"在当前结果页面,添加分享页面");
        }
        else
        {
            SVInfo (@"不在当前结果页面,不添加分享页面");
        }
    }
}
//移除分享页面
- (void)greyBtnBackClick
{
    [_greybtn removeFromSuperview];
    SVInfo (@"分享页面消失");
}
//调分享点击事件
- (void)shareBtnClick
{
    [_greybtn removeFromSuperview];
    //当分享到界面不存在时,点击事件生效
    if (shareTo == NO)
    {
        [self shareClicked1:nil];
    }
}

#pragma mark - 分享的点击事件
//有Facebook的情况
- (void)shareClicked1:(UIButton *)button
{

    //分享到界面存在
    shareTo = YES;

    NSString *title8 = I18N (@"Share on");
    NSString *title9 = I18N (@"Cancel");
    NSString *title10 = I18N (@"WeChat");
    NSString *title11 = I18N (@"Moments");
    NSString *title12 = I18N (@"Sina Weibo");
    NSString *title13 = I18N (@"Facebook");

    //获取整个屏幕的window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *_grey = [[UIView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    _grey.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    //创建一个分享到sharetoview
    UIView *sharetoview =
    [[UIView alloc] initWithFrame:CGRectMake (0, kScreenH - FITHEIGHT (580), kScreenW, FITHEIGHT (580))];
    sharetoview.backgroundColor = [UIColor whiteColor];
    //创建一个分享到label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH / 10)];
    label.text = title8;
    label.font = [UIFont systemFontOfSize:pixelToFontsize (54)];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    //创建一个显示取消的label2
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake (0, FITHEIGHT (43), kScreenW, kScreenH / 2)];
    label2.text = title9;
    label2.font = [UIFont systemFontOfSize:pixelToFontsize (54)];
    label2.textColor = [UIColor colorWithRed:0.179 green:0.625 blue:1.000 alpha:1.000];
    label2.textAlignment = NSTextAlignmentCenter;

    //创建4个分享按钮
    float leftMargin = (FITWIDTH (270) - FITHEIGHT (150)) / 2;
    UIButton *button1 = [[UIButton alloc]
    initWithFrame:CGRectMake (leftMargin, kScreenH - FITHEIGHT (405), FITHEIGHT (150), FITHEIGHT (150))];
    [button1 setImage:[UIImage imageNamed:@"share_to_wechat"] forState:UIControlStateNormal];
    [button1 addTarget:self
                action:@selector (Button1Click:)
      forControlEvents:UIControlEventTouchUpInside];
    UIButton *button2 = [[UIButton alloc]
    initWithFrame:CGRectMake (button1.rightX + leftMargin * 2, kScreenH - FITHEIGHT (405),
                              FITHEIGHT (150), FITHEIGHT (150))];
    [button2 setImage:[UIImage imageNamed:@"share_to_wechatmoments"] forState:UIControlStateNormal];
    [button2 addTarget:self
                action:@selector (Button2Click:)
      forControlEvents:UIControlEventTouchUpInside];

    UIButton *button3 = [[UIButton alloc]
    initWithFrame:CGRectMake (button2.rightX + leftMargin * 2, kScreenH - FITHEIGHT (405),
                              FITHEIGHT (150), FITHEIGHT (150))];
    [button3 setImage:[UIImage imageNamed:@"share_to_weibo"] forState:UIControlStateNormal];
    [button3 addTarget:self
                action:@selector (Button3Click:)
      forControlEvents:UIControlEventTouchUpInside];
    UIButton *button4 = [[UIButton alloc]
    initWithFrame:CGRectMake (button3.rightX + leftMargin * 2, kScreenH - FITHEIGHT (405),
                              FITHEIGHT (150), FITHEIGHT (150))];
    [button4 setImage:[UIImage imageNamed:@"share_to_facebook"] forState:UIControlStateNormal];
    [button4 addTarget:self
                action:@selector (Button4Click:)
      forControlEvents:UIControlEventTouchUpInside];
    //添加4个label
    //创建一个显示微信的label3
    UILabel *label3 = [[UILabel alloc]
    initWithFrame:CGRectMake (0, kScreenH / 10 + FITHEIGHT (202), FITWIDTH (270), FITHEIGHT (58))];
    label3.text = title10;
    //    label3.backgroundColor = [UIColor redColor];
    label3.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    label3.textColor = [UIColor lightGrayColor];
    label3.textAlignment = NSTextAlignmentCenter;
    //创建一个显示微信朋友圈的label4
    UILabel *label4 = [[UILabel alloc]
    initWithFrame:CGRectMake (label3.rightX, kScreenH / 10 + FITHEIGHT (202), FITWIDTH (270), FITHEIGHT (58))];
    label4.text = title11;
    label4.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    //    label4.backgroundColor = [UIColor blueColor];
    label4.textColor = [UIColor lightGrayColor];
    label4.textAlignment = NSTextAlignmentCenter;
    //创建一个显示微博的label5
    UILabel *label5 = [[UILabel alloc]
    initWithFrame:CGRectMake (label4.rightX, kScreenH / 10 + FITHEIGHT (202), FITWIDTH (270), FITHEIGHT (58))];
    label5.text = title12;
    //    label5.backgroundColor = [UIColor redColor];
    label5.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    label5.textColor = [UIColor lightGrayColor];
    label5.textAlignment = NSTextAlignmentCenter;
    //创建一个显示facebook的label6
    UILabel *label6 = [[UILabel alloc]
    initWithFrame:CGRectMake (label5.rightX, kScreenH / 10 + FITHEIGHT (202), FITWIDTH (270), FITHEIGHT (58))];
    label6.text = title13;
    //    label6.backgroundColor = [UIColor blueColor];
    label6.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    label6.textColor = [UIColor lightGrayColor];
    label6.textAlignment = NSTextAlignmentCenter;

    //创建取消button
    UIButton *button33 = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    [button33 addTarget:self
                 action:@selector (ButtonRemoveClick:)
       forControlEvents:UIControlEventTouchUpInside];
    //添加
    [sharetoview addSubview:label];
    [sharetoview addSubview:label2];
    [sharetoview addSubview:label3];
    [sharetoview addSubview:label4];
    [sharetoview addSubview:label5];
    [sharetoview addSubview:label6];

    [_grey addSubview:sharetoview];
    [window addSubview:_grey];
    [_grey addSubview:button33];
    [_grey addSubview:button1];
    [_grey addSubview:button2];
    [_grey addSubview:button3];
    [_grey addSubview:button4];
}
//微信群组的分享方法实现
- (void)Button1Click:(UIButton *)btn
{
    SVInfo (@"分享到微信群组");
    [self ShareContent];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession].snsClickHandler (
    self, [UMSocialControllerService defaultControllerService], YES);
    [btn.superview removeFromSuperview];
}
//微信朋友圈的分享方法实现
- (void)Button2Click:(UIButton *)btn
{
    SVInfo (@"分享到微信朋友圈");
    [self ShareContent];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatTimeline].snsClickHandler (
    self, [UMSocialControllerService defaultControllerService], YES);
    [btn.superview removeFromSuperview];
}
//微博方法实现
- (void)Button3Click:(UIButton *)btn
{
    SVInfo (@"分享到微博");
    [self ShareContent];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler (
    self, [UMSocialControllerService defaultControllerService], YES);
    [btn.superview removeFromSuperview];
}
// facebook分享方法实现
- (void)Button4Click:(UIButton *)btn
{
    SVInfo (@"分享到Facebook");
    [self ShareContent];
    //把分享完成提示框放在底部
    [UMSocialConfig setFinishToastIsHidden:NO position:UMSocialiToastPositionBottom];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToFacebook].snsClickHandler (
    self, [UMSocialControllerService defaultControllerService], YES);
    [btn.superview removeFromSuperview];
}

//分享内容
- (void)ShareContent
{
    // 1.0分享的标题
    NSString *titlea = I18N (@"Come to use SpeedPro!I am at the ");
    NSString *titleb1 = I18N (@"Mastery");
    NSString *titleb2 = I18N (@"Expertise");
    NSString *titleb3 = I18N (@"Proficiency");
    NSString *titleb4 = I18N (@"Competence");
    NSString *titleb5 = I18N (@"Novice");
    NSString *titlec = I18N (@" level.");
    NSString *titleA1 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb1, titlec];
    NSString *titleA2 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb2, titlec];
    NSString *titleA3 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb3, titlec];
    NSString *titleA4 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb4, titlec];
    NSString *titleA5 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb5, titlec];
    //创建分享标题对象
    NSString *MessageTitle;
    //根据随机数判断要分享的标题
    if (randomx >= 95)
    {
        MessageTitle = titleA1; //分享标题
    }
    if (randomx >= 80 && randomx <= 95)
    {
        MessageTitle = titleA2; //分享标题
    }
    if (randomx >= 60 && randomx <= 80)
    {
        MessageTitle = titleA3; //分享标题
    }
    if (randomx >= 10 && randomx <= 60)
    {
        MessageTitle = titleA4; //分享标题
    }
    if (randomx >= 0 && randomx <= 10)
    {
        MessageTitle = titleA5; //分享标题
    }
    // 2.0分享的内容
    NSString *titleaq = I18N (@"I have defeated ");
    NSString *titlecq =
    I18N (@"% of all users in the Red Envelope  War.Come on and test how fast you are!");
    NSString *titleAq = [[NSString alloc] initWithFormat:@"%@%d%@", titleaq, randomx, titlecq];
    //创建分享内容对象
    NSString *MessageText;
    MessageText = titleAq; //分享内容
    NSString *str61 = @"logo";
    // 3.0分享的图片
    NSString *image;
    image = str61;
    // 4.0分享的网址和资源
    NSString *Url = I18N (@"myurl");
    // 5.0分享
    [[UMSocialControllerService defaultControllerService] setShareText:MessageText
                                                            shareImage:[UIImage imageNamed:image]
                                                      socialUIDelegate:self];
    //微信好友
    [UMSocialData defaultData].extConfig.wechatSessionData.title = MessageTitle;
    [UMSocialData defaultData].extConfig.wechatSessionData.shareText = MessageText;

    //微信朋友圈
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = MessageTitle;

    // Facebook
    //    [UMSocialData defaultData].extConfig.facebookData.title = MessageTitle;
    //    [UMSocialData defaultData].extConfig.facebookData.url = Url;
    //    [UMSocialData defaultData].extConfig.facebookData.linkDescription =
    //    I18N (@"Click download application");
    [UMSocialData defaultData].extConfig.facebookData.shareText =
    [[NSString alloc] initWithFormat:@"%@%@", MessageTitle, Url];
    //微博
    [UMSocialData defaultData].extConfig.sinaData.shareText = MessageTitle;
}

//分享成功调用此方法
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (response.responseCode == UMSResponseCodeSuccess)
    {
        //把分享完成提示框放在底部
        [UMSocialConfig setFinishToastIsHidden:NO position:UMSocialiToastPositionBottom];
        SVInfo (@"分享成功了");
    }
}

//取消方法实现
- (void)ButtonRemoveClick:(UIButton *)btn
{
    //分享到界面消失
    shareTo = NO;
    [btn.superview removeFromSuperview];
}

/**
 *  peek手势
 */
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location
{

    // 获取用户手势点所在cell的下标。同时判断手势点是否超出tableView响应范围。
    if (![self getShouldShowRectAndIndexPathWithLocation:location])
    {
        return nil;
    }

    // 弹出视图的初始位置，sourceRect是peek触发时的高亮区域。这个区域内的View会高亮显示，其余的会模糊掉
    previewingContext.sourceRect = sourceRect;

    // 获取数据进行传值
    UIButton *currentBtn = _buttons[selectedPath.section];
    SVDetailViewCtrl *childVC = [[SVDetailViewCtrl alloc] init];
    [childVC setTestId:_resultModel.testId];
    [childVC setTestType:[NSString stringWithFormat:@"%ld", (long)currentBtn.tag]];
    return childVC;
}

/**
 *  pop手势
 */
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController *)viewControllerToCommit
{
    UIButton *currentBtn = _buttons[selectedPath.section];
    [self CellDetailClick:currentBtn
                 testType:[NSString stringWithFormat:@"%ld", (long)currentBtn.tag]];
}

/**
 *  获取用户手势点所在cell的下标，同时判断手势点是否超出tableview的范围
 */
- (BOOL)getShouldShowRectAndIndexPathWithLocation:(CGPoint)location
{
    // 坐标点的转化，
    CGPoint tableLocation = [self.view convertPoint:location toView:_tableView];
    selectedPath = [_tableView indexPathForRowAtPoint:tableLocation];

    // 如果selctedPath是nil，则说明越界
    if (!selectedPath)
    {
        return NO;
    }

    // 计算弹出视图的初始位置
    sourceRect = CGRectMake (0, NavBarH + StatusBarH + selectedPath.section * FITHEIGHT (239),
                             kScreenW, FITHEIGHT (209));

    // 如果row越界了，返回NO 不处理peek手势
    return (selectedPath.section >= (_buttons.count)) ? NO : YES;
}


@end
