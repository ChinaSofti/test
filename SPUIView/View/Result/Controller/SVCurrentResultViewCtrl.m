//
//  SVCurrentResultViewCtrl.m
//  SPUIView
//
//  Created by Rain on 2/14/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 设置标题
    [self initTitleView];

    // 设置返回按钮
    [self initBackButtonWithTarget:self action:@selector (backBtnClik)];

    // 初始化当前结果页面的View
    UIView *uiview = [[UIView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    uiview.backgroundColor = [UIColor colorWithHexString:@"FAFAFA"];

    // 把tableView添加到 view
    [uiview addSubview:[self createTableViewWithRect:CGRectMake (0, 0, kScreenW, FITHEIGHT (1242))
                                           WithStyle:UITableViewStyleGrouped
                                           WithColor:[UIColor colorWithHexString:@"#FAFAFA"]
                                        WithDelegate:self
                                      WithDataSource:self]];

    // 把button添加到 view
    [uiview addSubview:self.buildTestBtn];

    self.view = uiview;

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

    //屏幕即将出现标识符设置为yes
    currentCtl = YES;
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
    [super viewWillDisappear:animated];
    //屏幕即将消失标识符设置为no
    currentCtl = NO;
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
          NSData *result = [push sendResult];
          NSError *error;
          id jsonStr = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
          NSLog (@"%@", jsonStr);
          NSString *results = [jsonStr valueForKey:@"totalCount"];
          NSString *result1 = [jsonStr valueForKey:@"currentPosition"];
          double aaaa = [results doubleValue];
          double bbbb = [result1 doubleValue];
          rank = (aaaa - bbbb) * 100 / aaaa;

          dispatch_async (dispatch_get_main_queue (), ^{
            //结果传回来后显示UI
            //做判断,如果不是当前结果界面就不弹出
            [self createShareUI];


          });
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
        UIColor *color = [UIColor colorWithHexString:@"#FFFEB960"];

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
        UIColor *color = [UIColor colorWithHexString:@"#FF38C695"];

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
        UIColor *color = [UIColor colorWithHexString:@"#FFFC5F45"];

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
    titleLabel.textColor = [UIColor colorWithHexString:@"#B2000000"];

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
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS SVSummaryResultModel(ID integer PRIMARY KEY "
                      @"AUTOINCREMENT, testId integer, type integer, testTime integer, UvMOS "
                      @"real, loadTime integer, bandwidth real);"];

    // 获取网络类型
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSString *networkType = probeInfo.networkType;

    NSString *insertSVSummaryResultModelSQL =
    [NSString stringWithFormat:@"INSERT INTO "
                               @"SVSummaryResultModel(testId,type,testTime,UvMOS,loadTime,"
                               @"bandwidth)VALUES(%lld, %d, %lld, %lf, %lf, %lf);",
                               _resultModel.testId, networkType.intValue, _resultModel.testId,
                               _resultModel.uvMOS, _resultModel.totalTime, _resultModel.stDownloadSpeed];
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
    SVInfo (@"indexPath -----------------------------%@", indexPath);
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
    // cell被点击
    SVInfo (@"cell-------dianjile");

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

    //判断如果不是当前结果页面就退出
    if (currentCtl == NO)
    {
        return;
    }
    randomx = rank;
    NSLog (@"排名为%d", randomx);
    //获取整个屏幕的window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //创建一个覆盖garybutton
    _greybtn = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    _greybtn.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.0];
    [_greybtn addTarget:self
                 action:@selector (greyBtnBackClick)
       forControlEvents:UIControlEventTouchUpInside];
    //创建一个图片
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageview.size = CGSizeMake (kScreenW, kScreenH * 0.8);
    NSString *str11 = I18N (@"speed_level_frist_english");
    NSString *str21 = I18N (@"speed_level_second_english");
    NSString *str31 = I18N (@"speed_level_thrid_english");
    NSString *str41 = I18N (@"speed_level_forth_english");
    NSString *str51 = I18N (@"speed_level_last_english");
    //根据随机数显示
    if (randomx >= 95)
    {
        imageview.image = [UIImage imageNamed:str11];
    }
    if (randomx >= 80 && randomx <= 95)
    {
        imageview.image = [UIImage imageNamed:str21];
    }
    if (randomx >= 60 && randomx <= 80)
    {
        imageview.image = [UIImage imageNamed:str31];
    }
    if (randomx >= 10 && randomx <= 60)
    {
        imageview.image = [UIImage imageNamed:str41];
    }
    if (randomx >= 0 && randomx <= 10)
    {
        imageview.image = [UIImage imageNamed:str51];
    }

    imageview.center = CGPointMake (_greybtn.frame.size.width / 2, _greybtn.frame.size.height / 2);
    //创建一个label
    UILabel *label = [[UILabel alloc] init];
    //字符串拼接
    NSString *str1 = I18N (@"I have defeated");
    NSString *str2 = @"%";
    NSString *str3 = I18N (@"of all users");
    //根据随机数显示
    NSString *str4 = [[NSString alloc] initWithFormat:@"%@%d%@%@", str1, randomx, str2, str3];
    //显示
    label.text = str4;
    label.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    label.textColor = [UIColor blueColor];
    //    label.backgroundColor = [UIColor redColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.size = CGSizeMake (FITWIDTH (589), FITHEIGHT (58));
    label.centerX = imageview.centerX;
    label.centerY = imageview.centerY / 1.9;
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
    [imageview addSubview:label];
    [_greybtn addSubview:imageview];
    [_greybtn addSubview:_sharebtn];
    [window addSubview:_greybtn];
}
//移除分享页面
- (void)greyBtnBackClick
{
    [_greybtn removeFromSuperview];
}
//调分享点击事件
- (void)shareBtnClick
{
    [_greybtn removeFromSuperview];
    //对国家做判断(如果在国内用shareClicked1,如果在国外用shareClicked2)
    [self shareClicked1:nil];
}
#pragma mark - 分享的点击事件
//有Facebook的情况
- (void)shareClicked1:(UIButton *)button
{
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
    UIButton *button1 = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (80), kScreenH - FITHEIGHT (405), FITHEIGHT (150), FITHEIGHT (150))];
    [button1 setImage:[UIImage imageNamed:@"share_to_wechat"] forState:UIControlStateNormal];
    [button1 addTarget:self
                action:@selector (Button1Click:)
      forControlEvents:UIControlEventTouchUpInside];
    UIButton *button2 = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (80) + (kScreenW - FITWIDTH (58)) / 4,
                              kScreenH - FITHEIGHT (405), FITHEIGHT (150), FITHEIGHT (150))];
    [button2 setImage:[UIImage imageNamed:@"share_to_wechatmoments"] forState:UIControlStateNormal];
    [button2 addTarget:self
                action:@selector (Button2Click:)
      forControlEvents:UIControlEventTouchUpInside];

    UIButton *button3 = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (80) + (kScreenW - FITWIDTH (58)) / 2,
                              kScreenH - FITHEIGHT (405), FITHEIGHT (150), FITHEIGHT (150))];
    [button3 setImage:[UIImage imageNamed:@"share_to_weibo"] forState:UIControlStateNormal];
    [button3 addTarget:self
                action:@selector (Button3Click:)
      forControlEvents:UIControlEventTouchUpInside];
    UIButton *button4 = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (80) + 3 * (kScreenW - FITWIDTH (58)) / 4,
                              kScreenH - FITHEIGHT (405), FITHEIGHT (150), FITHEIGHT (150))];
    [button4 setImage:[UIImage imageNamed:@"share_to_email"] forState:UIControlStateNormal];
    [button4 addTarget:self
                action:@selector (Button4Click:)
      forControlEvents:UIControlEventTouchUpInside];
    //添加4个label
    //创建一个显示微信的label3
    UILabel *label3 = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (58), kScreenH / 10 + FITHEIGHT (202), FITWIDTH (200), FITHEIGHT (58))];
    label3.text = title10;
    //    label3.backgroundColor = [UIColor redColor];
    label3.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    label3.textColor = [UIColor lightGrayColor];
    label3.textAlignment = NSTextAlignmentCenter;
    //创建一个显示微信朋友圈的label4
    UILabel *label4 = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (58) + (kScreenW - FITWIDTH (58)) / 4,
                              kScreenH / 10 + FITHEIGHT (202), FITWIDTH (230), FITHEIGHT (58))];
    label4.text = title11;
    label4.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    //    label4.backgroundColor = [UIColor blueColor];
    label4.textColor = [UIColor lightGrayColor];
    label4.textAlignment = NSTextAlignmentCenter;
    //创建一个显示微博的label5
    UILabel *label5 = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (58) + (kScreenW - FITWIDTH (58)) / 2,
                              kScreenH / 10 + FITHEIGHT (202), FITWIDTH (230), FITHEIGHT (58))];
    label5.text = title12;
    //    label5.backgroundColor = [UIColor redColor];
    label5.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    label5.textColor = [UIColor lightGrayColor];
    label5.textAlignment = NSTextAlignmentCenter;
    //创建一个显示facebook的label6
    UILabel *label6 = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (58) + 3 * (kScreenW - FITWIDTH (58)) / 4,
                              kScreenH / 10 + FITHEIGHT (202), FITWIDTH (200), FITHEIGHT (58))];
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
//没有Facebook的情况
- (void)shareClicked2:(UIButton *)button
{
    NSString *title8 = I18N (@"Share on");
    NSString *title9 = I18N (@"Cancel");
    NSString *title10 = I18N (@"WeChat");
    NSString *title11 = I18N (@"Moments");
    NSString *title12 = I18N (@"Sina Weibo");

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

    //创建3个分享按钮
    UIButton *button1 = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (120), kScreenH - FITHEIGHT (405), FITHEIGHT (150), FITHEIGHT (150))];
    [button1 setImage:[UIImage imageNamed:@"share_to_wechat"] forState:UIControlStateNormal];
    [button1 addTarget:self
                action:@selector (Button1Click:)
      forControlEvents:UIControlEventTouchUpInside];
    UIButton *button2 = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (120) + (kScreenW - FITWIDTH (58)) / 3,
                              kScreenH - FITHEIGHT (405), FITHEIGHT (150), FITHEIGHT (150))];
    [button2 setImage:[UIImage imageNamed:@"share_to_wechatmoments"] forState:UIControlStateNormal];
    [button2 addTarget:self
                action:@selector (Button2Click:)
      forControlEvents:UIControlEventTouchUpInside];

    UIButton *button3 = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (120) + 2 * (kScreenW - FITWIDTH (58)) / 3,
                              kScreenH - FITHEIGHT (405), FITHEIGHT (150), FITHEIGHT (150))];
    [button3 setImage:[UIImage imageNamed:@"share_to_weibo"] forState:UIControlStateNormal];
    [button3 addTarget:self
                action:@selector (Button3Click:)
      forControlEvents:UIControlEventTouchUpInside];

    //添加3个label
    //创建一个显示微信的label3
    UILabel *label3 =
    [[UILabel alloc] initWithFrame:CGRectMake (FITWIDTH (100), kScreenH / 10 + FITHEIGHT (202),
                                               FITWIDTH (200), FITHEIGHT (58))];
    label3.text = title10;
    //    label3.backgroundColor = [UIColor redColor];
    label3.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    label3.textColor = [UIColor lightGrayColor];
    label3.textAlignment = NSTextAlignmentCenter;
    //创建一个显示微信朋友圈的label4
    UILabel *label4 = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (100) + (kScreenW - FITWIDTH (58)) / 3,
                              kScreenH / 10 + FITHEIGHT (202), FITWIDTH (230), FITHEIGHT (58))];
    label4.text = title11;
    label4.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    //    label4.backgroundColor = [UIColor blueColor];
    label4.textColor = [UIColor lightGrayColor];
    label4.textAlignment = NSTextAlignmentCenter;
    //创建一个显示微博的label5
    UILabel *label5 = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (100) + 2 * (kScreenW - FITWIDTH (58)) / 3,
                              kScreenH / 10 + FITHEIGHT (202), FITWIDTH (230), FITHEIGHT (58))];
    label5.text = title12;
    //    label5.backgroundColor = [UIColor redColor];
    label5.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    label5.textColor = [UIColor lightGrayColor];
    label5.textAlignment = NSTextAlignmentCenter;
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

    [_grey addSubview:sharetoview];
    [window addSubview:_grey];
    [_grey addSubview:button33];
    [_grey addSubview:button1];
    [_grey addSubview:button2];
    [_grey addSubview:button3];
}
//微信群组的分享方法实现
- (void)Button1Click:(UIButton *)btn
{
    SVInfo (@"分享到微信群组");
    [self ShareContent];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession].snsClickHandler (
    self, [UMSocialControllerService defaultControllerService], YES);
    [self ButtonRemoveClick:nil];
}
//微信朋友圈的分享方法实现
- (void)Button2Click:(UIButton *)btn
{
    SVInfo (@"分享到微信朋友圈");
    [self ShareContent];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatTimeline].snsClickHandler (
    self, [UMSocialControllerService defaultControllerService], YES);
    [self ButtonRemoveClick:nil];
}
//微博方法实现
- (void)Button3Click:(UIButton *)btn
{
    SVInfo (@"分享到微博");
    [self ShareContent];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler (
    self, [UMSocialControllerService defaultControllerService], YES);
    [self ButtonRemoveClick:nil];
}
// facebook分享方法实现
- (void)Button4Click:(UIButton *)btn
{
    SVInfo (@"分享到Facebook");
    [self ShareContent];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToFacebook].snsClickHandler (
    self, [UMSocialControllerService defaultControllerService], YES);
    [self ButtonRemoveClick:nil];
}

//分享内容
- (void)ShareContent
{
    //分享的文本
    NSString *titlea = I18N (@"I am at the ");
    NSString *titleb1 = I18N (@"Mastery");
    NSString *titleb2 = I18N (@"Expertise");
    NSString *titleb3 = I18N (@"Proficiency");
    NSString *titleb4 = I18N (@"Competence");
    NSString *titleb5 = I18N (@"Novice");
    NSString *titlec = I18N (@" level.What is yours?");
    NSString *titleA1 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb1, titlec];
    NSString *titleA2 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb2, titlec];
    NSString *titleA3 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb3, titlec];
    NSString *titleA4 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb4, titlec];
    NSString *titleA5 = [[NSString alloc] initWithFormat:@"%@%@%@", titlea, titleb5, titlec];
    //创建分享内容对象
    NSString *urlMessage;
    //根据随机数判断要分享的标题
    if (randomx >= 95)
    {
        urlMessage = titleA1; //分享标题
    }
    if (randomx >= 80 && randomx <= 95)
    {
        urlMessage = titleA2; //分享标题
    }
    if (randomx >= 60 && randomx <= 80)
    {
        urlMessage = titleA3; //分享标题
    }
    if (randomx >= 10 && randomx <= 60)
    {
        urlMessage = titleA4; //分享标题
    }
    if (randomx >= 0 && randomx <= 10)
    {
        urlMessage = titleA5; //分享标题
    }
    //根据随机数显示压缩图片
    NSString *str11 = I18N (@"share_image_frist_english");
    NSString *str21 = I18N (@"share_image_second_english");
    NSString *str31 = I18N (@"share_image_thrid_english");
    NSString *str41 = I18N (@"share_image_forth_english");
    NSString *str51 = I18N (@"share_image_last_english");
    //创建分享的图片
    NSString *image;
    //分享图片,使用SDK的setThumbImage方法可压缩图片大小
    if (randomx >= 95)
    {
        image = str11;
    }
    if (randomx >= 80 && randomx <= 95)
    {
        image = str21;
    }
    if (randomx >= 60 && randomx <= 80)
    {
        image = str31;
    }
    if (randomx >= 10 && randomx <= 60)
    {
        image = str41;
    }
    if (randomx >= 0 && randomx <= 10)
    {
        image = str51;
    }

    //分享
    [[UMSocialControllerService defaultControllerService] setShareText:urlMessage
                                                            shareImage:[UIImage imageNamed:image]
                                                      socialUIDelegate:self];
}
//取消方法实现
- (void)ButtonRemoveClick:(UIButton *)btn
{
    [btn.superview removeFromSuperview];
}

@end
