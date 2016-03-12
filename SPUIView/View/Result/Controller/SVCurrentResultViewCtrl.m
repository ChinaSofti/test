//
//  SVCurrentResultViewCtrl.m
//  SPUIView
//
//  Created by Rain on 2/14/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVCurrentResultViewCtrl.h"
#import "SVDetailViewCtrl.h"
#import "SVTestViewCtrl.h"
#import <SPCommon/SVSystemUtil.h>
#import <SPService/SVTestContextGetter.h>
#define kFirstHederH 40
#define kLastFooterH 140
#define kCellH (kScreenW - 20) * 0.22
#define kMargin 10
#define kCornerRadius 5
#define valueFontSize 18
#define valueLableFontSize 12


@implementation SVCurrentResultViewCtrl
{
    NSMutableArray *_buttons;
    UITableView *_tableView;
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
    return self;
}

- (void)initButtons
{
    NSString *title1 = I18N (@"Fail");
    NSString *title2 = I18N (@"Initial buffer time");
    NSString *title3 = I18N (@"Butter times");
    NSString *title4 = I18N (@"Web Test");
    NSString *title5 = I18N (@"Response Time");
    NSString *title6 = I18N (@"Download");
    // 1.
    UIButton *_bgdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _bgdBtn.frame = CGRectMake (kMargin, 0, kScreenW - 2 * kMargin, kCellH);
    _bgdBtn.layer.cornerRadius = kCornerRadius * 2;
    _bgdBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bgdBtn.layer.borderWidth = 1;
    [_bgdBtn addTarget:self
                action:@selector (CellVideoDetailClick:)
      forControlEvents:UIControlEventTouchUpInside];

    // 2.
    UIButton *_bgdBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _bgdBtn2.frame = CGRectMake (kMargin, 0, kScreenW - 2 * kMargin, kCellH);
    _bgdBtn2.layer.cornerRadius = kCornerRadius * 2;
    _bgdBtn2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bgdBtn2.layer.borderWidth = 1;
    [_bgdBtn2 addTarget:self
                 action:@selector (CellWebDetailClick:)
       forControlEvents:UIControlEventTouchUpInside];

    if (_resultModel.videoTest == YES)
    {
        [_buttons addObject:_bgdBtn];
    }
    if (_resultModel.webTest == YES)
    {
        [_buttons addObject:_bgdBtn2];
    }


    if (_resultModel.videoTest == YES)
    {
        CGFloat imgViewWAndH = kViewH (_bgdBtn) - 3 * kViewX (_bgdBtn);
        UIImageView *_imgView = [[UIImageView alloc]
        initWithFrame:CGRectMake (kMargin * 2, (kCellH - imgViewWAndH) * 0.5, imgViewWAndH, imgViewWAndH)];
        _imgView.image = [UIImage imageNamed:@"ic_video_label"];
        [_bgdBtn addSubview:_imgView];

        UIImageView *_rightImgView =
        [[UIImageView alloc] initWithFrame:CGRectMake (kViewW (_bgdBtn) - imgViewWAndH - kMargin,
                                                       kViewY (_imgView), imgViewWAndH, imgViewWAndH)];
        [_bgdBtn addSubview:_rightImgView];

        // U-vMOS 值
        UILabel *uvMosLabelValue = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (_imgView) + FITHEIGHT (15),
                                  kViewY (_imgView) - FITWIDTH (10), FITWIDTH (50), imgViewWAndH)];
        if (_resultModel.uvMOS == -1)
        {
            [uvMosLabelValue setText:title1];
        }
        else
        {
            [uvMosLabelValue setText:[NSString stringWithFormat:@"%.2f", _resultModel.uvMOS]];
        }

        [uvMosLabelValue setFont:[UIFont boldSystemFontOfSize:valueFontSize]];
        [uvMosLabelValue setTextAlignment:NSTextAlignmentCenter];
        [uvMosLabelValue setTextColor:[UIColor orangeColor]];

        UILabel *uvMosLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (_imgView) + FITHEIGHT (15),
                                  kViewY (_imgView) + FITWIDTH (10), FITWIDTH (50), imgViewWAndH)];
        [uvMosLabel setText:@"U-vMOS"];
        [uvMosLabel setFont:[UIFont systemFontOfSize:valueLableFontSize]];
        [uvMosLabel setTextAlignment:NSTextAlignmentCenter];
        [_bgdBtn addSubview:uvMosLabelValue];
        [_bgdBtn addSubview:uvMosLabel];

        // 首次缓冲时间
        UILabel *firstBufferTimeLabelValue = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (uvMosLabelValue) + FITWIDTH (10),
                                  kViewY (_imgView) - FITWIDTH (10), FITWIDTH (50), imgViewWAndH)];
        if (_resultModel.firstBufferTime == -1)
        {
            [firstBufferTimeLabelValue setText:title1];
        }
        else
        {
            [firstBufferTimeLabelValue setText:[NSString stringWithFormat:@"%d", _resultModel.firstBufferTime]];
        }
        [firstBufferTimeLabelValue setFont:[UIFont boldSystemFontOfSize:valueFontSize]];
        [firstBufferTimeLabelValue setTextAlignment:NSTextAlignmentRight];
        [firstBufferTimeLabelValue setTextColor:[UIColor orangeColor]];

        UILabel *firstBufferTimeLabelValue1 = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (uvMosLabelValue) + FITHEIGHT (57),
                                  kViewY (_imgView) + FITWIDTH (3), FITWIDTH (20), FITWIDTH (20))];
        [firstBufferTimeLabelValue1 setText:@"ms"];
        [firstBufferTimeLabelValue1 setFont:[UIFont systemFontOfSize:10]];
        [firstBufferTimeLabelValue1 setTextAlignment:NSTextAlignmentCenter];
        [firstBufferTimeLabelValue1 setTextColor:[UIColor orangeColor]];

        UILabel *firstBufferTimeLabel =
        [[UILabel alloc] initWithFrame:CGRectMake (kViewR (uvMosLabel), kViewY (_imgView) + FITWIDTH (10),
                                                   FITWIDTH (100), imgViewWAndH)];
        [firstBufferTimeLabel setText:title2];
        [firstBufferTimeLabel setFont:[UIFont systemFontOfSize:valueLableFontSize]];
        [firstBufferTimeLabel setTextAlignment:NSTextAlignmentCenter];

        [_bgdBtn addSubview:firstBufferTimeLabelValue];
        [_bgdBtn addSubview:firstBufferTimeLabelValue1];
        [_bgdBtn addSubview:firstBufferTimeLabel];

        // 卡顿次数
        UILabel *cuttonTimesLabelValue = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (firstBufferTimeLabelValue) + FITHEIGHT (45),
                                  kViewY (_imgView) - FITWIDTH (10), FITWIDTH (60), imgViewWAndH)];
        if (_resultModel.cuttonTimes == -1)
        {
            [cuttonTimesLabelValue setText:title1];
        }
        else
        {
            [cuttonTimesLabelValue setText:[NSString stringWithFormat:@"%d", _resultModel.cuttonTimes]];
        }
        [cuttonTimesLabelValue setFont:[UIFont boldSystemFontOfSize:valueFontSize]];
        [cuttonTimesLabelValue setTextAlignment:NSTextAlignmentCenter];
        [cuttonTimesLabelValue setTextColor:[UIColor orangeColor]];

        UILabel *cuttonTimesLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (firstBufferTimeLabel) - FITHEIGHT (15),
                                  kViewY (_imgView) + FITWIDTH (10), FITWIDTH (100), imgViewWAndH)];
        [cuttonTimesLabel setText:title3];

        [cuttonTimesLabel setFont:[UIFont systemFontOfSize:valueLableFontSize]];
        [cuttonTimesLabel setTextAlignment:NSTextAlignmentCenter];
        [_bgdBtn addSubview:cuttonTimesLabelValue];
        [_bgdBtn addSubview:cuttonTimesLabel];
    }


    if (_resultModel.webTest == YES)
    {
        /*网页测试
        "Web Test"="网页测试";
        "Response Time"="响应时间";
        "Load duration"="完全加载时间";
        "Download"="下载速率";
         */
        CGFloat imgViewWAndH2 = kViewH (_bgdBtn2) - 3 * kViewX (_bgdBtn2);
        UIImageView *_imgView2 = [[UIImageView alloc]
        initWithFrame:CGRectMake (kMargin * 2, (kCellH - imgViewWAndH2) * 0.5, imgViewWAndH2, imgViewWAndH2)];
        _imgView2.image = [UIImage imageNamed:@"ic_web_label"];
        [_bgdBtn2 addSubview:_imgView2];

        UIImageView *_rightImgView2 =
        [[UIImageView alloc] initWithFrame:CGRectMake (kViewW (_bgdBtn2) - imgViewWAndH2 - kMargin,
                                                       kViewY (_imgView2), imgViewWAndH2, imgViewWAndH2)];
        [_bgdBtn2 addSubview:_rightImgView2];

        // 响应时间
        UILabel *ResponseLabelValue =
        [[UILabel alloc] initWithFrame:CGRectMake (kViewR (_imgView2), kViewY (_imgView2) - FITWIDTH (10),
                                                   FITWIDTH (50), imgViewWAndH2)];
        if (!_resultModel.responseTime || _resultModel.responseTime < 0)
        {
            [ResponseLabelValue setText:title1];
        }
        else
        {
            [ResponseLabelValue setText:[NSString stringWithFormat:@"%.2f", _resultModel.responseTime]];
        }

        [ResponseLabelValue setFont:[UIFont boldSystemFontOfSize:valueFontSize]];
        [ResponseLabelValue setTextAlignment:NSTextAlignmentRight];
        [ResponseLabelValue setTextColor:[UIColor orangeColor]];

        UILabel *ResponseLabelValue1 = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (ResponseLabelValue) - FITWIDTH (5),
                                  kViewY (_imgView2) + FITWIDTH (3), FITWIDTH (20), FITWIDTH (20))];
        [ResponseLabelValue1 setText:@"s"];
        [ResponseLabelValue1 setFont:[UIFont systemFontOfSize:10]];
        [ResponseLabelValue1 setTextAlignment:NSTextAlignmentCenter];
        [ResponseLabelValue1 setTextColor:[UIColor orangeColor]];

        UILabel *ResponseLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (_imgView2) + FITHEIGHT (15),
                                  kViewY (_imgView2) + FITWIDTH (10), FITWIDTH (50), imgViewWAndH2)];
        [ResponseLabel setText:title4];
        [ResponseLabel setFont:[UIFont systemFontOfSize:valueLableFontSize]];
        [ResponseLabel setTextAlignment:NSTextAlignmentCenter];
        [_bgdBtn2 addSubview:ResponseLabelValue];
        [_bgdBtn2 addSubview:ResponseLabelValue1];
        [_bgdBtn2 addSubview:ResponseLabel];

        // 完全加载时间
        UILabel *LoadLabelValue = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (ResponseLabelValue) + FITWIDTH (20),
                                  kViewY (_imgView2) - FITWIDTH (10), FITWIDTH (50), imgViewWAndH2)];
        if (!_resultModel.totalTime || _resultModel.totalTime < 0)
        {
            [LoadLabelValue setText:title1];
        }
        else
        {
            [LoadLabelValue setText:[NSString stringWithFormat:@"%.2f", _resultModel.totalTime]];
        }
        [LoadLabelValue setFont:[UIFont boldSystemFontOfSize:valueFontSize]];
        [LoadLabelValue setTextAlignment:NSTextAlignmentRight];
        [LoadLabelValue setTextColor:[UIColor orangeColor]];

        UILabel *LoadLabelValue1 = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (ResponseLabelValue) + FITHEIGHT (67),
                                  kViewY (_imgView2) + FITWIDTH (3), FITWIDTH (20), FITWIDTH (20))];
        [LoadLabelValue1 setText:@"s"];
        [LoadLabelValue1 setFont:[UIFont systemFontOfSize:10]];
        [LoadLabelValue1 setTextAlignment:NSTextAlignmentCenter];
        [LoadLabelValue1 setTextColor:[UIColor orangeColor]];

        UILabel *LoadLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (ResponseLabel), kViewY (_imgView2) + FITWIDTH (10),
                                  FITWIDTH (100), imgViewWAndH2)];
        [LoadLabel setText:title5];
        [LoadLabel setFont:[UIFont systemFontOfSize:valueLableFontSize]];
        [LoadLabel setTextAlignment:NSTextAlignmentCenter];

        [_bgdBtn2 addSubview:LoadLabelValue];
        [_bgdBtn2 addSubview:LoadLabelValue1];
        [_bgdBtn2 addSubview:LoadLabel];

        // 下载速率
        UILabel *DownloadLabelValue = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (LoadLabelValue) + FITHEIGHT (30),
                                  kViewY (_imgView2) - FITWIDTH (10), FITWIDTH (60), imgViewWAndH2)];
        if (!_resultModel.downloadSpeed || _resultModel.downloadSpeed < 0)
        {
            [DownloadLabelValue setText:title1];
        }
        else
        {
            [DownloadLabelValue setText:[NSString stringWithFormat:@"%.2f", _resultModel.downloadSpeed]];
        }
        [DownloadLabelValue setFont:[UIFont boldSystemFontOfSize:valueFontSize]];
        [DownloadLabelValue setTextAlignment:NSTextAlignmentRight];
        [DownloadLabelValue setTextColor:[UIColor orangeColor]];

        UILabel *DownloadLabelValue1 = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (ResponseLabelValue) + FITHEIGHT (162),
                                  kViewY (_imgView2) + FITWIDTH (3), FITWIDTH (20), FITWIDTH (20))];
        [DownloadLabelValue1 setText:@"kbps"];
        [DownloadLabelValue1 setFont:[UIFont systemFontOfSize:10]];
        [DownloadLabelValue1 setTextAlignment:NSTextAlignmentCenter];
        [DownloadLabelValue1 setTextColor:[UIColor orangeColor]];

        UILabel *DownloadLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (kViewR (LoadLabel) - FITHEIGHT (15),
                                  kViewY (_imgView2) + FITWIDTH (10), FITWIDTH (100), imgViewWAndH2)];
        [DownloadLabel setText:title6];

        [DownloadLabel setFont:[UIFont systemFontOfSize:valueLableFontSize]];
        [DownloadLabel setTextAlignment:NSTextAlignmentCenter];
        [_bgdBtn2 addSubview:DownloadLabelValue];
        [_bgdBtn2 addSubview:DownloadLabelValue1];
        [_bgdBtn2 addSubview:DownloadLabel];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initBarButton];

    UIView *uiview = [[UIView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    uiview.backgroundColor = [UIColor whiteColor];
    // 7.把tableView添加到 view
    [uiview addSubview:self.buildTableView];

    // 7.把button添加到 view
    [uiview addSubview:self.buildTestBtn];

    self.view = uiview;
    // 初始化表格数据
    [self initButtons];

    // 表格重绘
    [_tableView reloadData];
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
    return 10;
}
//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellH;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableView *)buildTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, 500)
                                              style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 2.设置背景颜色
    _tableView.backgroundColor = [UIColor whiteColor];
    //*4.设置代理
    _tableView.delegate = self;
    //*5.设置数据源
    _tableView.dataSource = self;
    // 6.设置tableView不可上下拖动
    _tableView.bounces = NO;
    return _tableView;
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
 *开始测试按钮初始化(按钮未被选中时的状态)
 **/

- (UIButton *)buildTestBtn
{
    NSString *title1 = I18N (@"Test Again");
    //按钮高度
    CGFloat testBtnH = 50;
    //按钮类型
    UIButton *_reTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //按钮尺寸
    _reTestButton.frame = CGRectMake (kMargin * 4, kScreenH - 200, kScreenW - kMargin * 8, testBtnH);
    //按钮圆角
    _reTestButton.layer.cornerRadius = kCornerRadius;
    //设置按钮的背景色
    _reTestButton.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    //按钮文字颜色和类型
    [_reTestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置居中
    _reTestButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    //按钮文字和类型
    [_reTestButton setTitle:title1 forState:UIControlStateNormal];
    //按钮点击事件
    [_reTestButton addTarget:self
                      action:@selector (testBtnClick)
            forControlEvents:UIControlEventTouchUpInside];

    return _reTestButton;
}

/**
 *  初始化barbutton
 */
- (void)initBarButton
{
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake (0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
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

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, 45, 23)];
    [button setImage:[UIImage imageNamed:@"homeindicator"] forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *back0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil
                                                                           action:nil];
    back0.width = -15;
    self.navigationItem.leftBarButtonItems = @[back0, backButton];

    [button addTarget:self
               action:@selector (backBtnClik)
     forControlEvents:UIControlEventTouchUpInside];

    //为了保持平衡添加一个leftBtn
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, 44, 44)];
    UIBarButtonItem *backButton1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.rightBarButtonItem = backButton1;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

/**
 *  返回重新测试页面
 */
- (void)testBtnClick
{
    SVInfo (@"back to testting view");
    [[_resultModel navigationController] popViewControllerAnimated:NO];
}

/**
 *  回退到测试页面
 */
- (void)backBtnClik
{
    SVInfo (@"back to test view");
    [[_resultModel navigationController] popToRootViewControllerAnimated:NO];
}

@end
