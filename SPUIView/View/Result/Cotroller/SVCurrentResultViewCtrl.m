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
#import <SPCommon/SVI18N.h>
#import <SPCommon/SVSystemUtil.h>
#import <SPService/SVTestContextGetter.h>
#define kFirstHederH 40
#define kLastFooterH 140
#define kCellH (kScreenW - 20) * 0.22
#define kMargin 10
#define kCornerRadius 5
#define valueFontSize 18
#define valueLableFontSize 12

@interface SVCurrentResultViewCtrl () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation SVCurrentResultViewCtrl

@synthesize navigationController, currentResultModel;

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
}

//方法:

//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    NSLog (@"indexPath %@", indexPath);
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

    UIButton *_bgdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _bgdBtn.frame = CGRectMake (kMargin, 0, kScreenW - 2 * kMargin, kCellH);
    _bgdBtn.layer.cornerRadius = kCornerRadius * 2;
    _bgdBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bgdBtn.layer.borderWidth = 1;
    [_bgdBtn addTarget:self
                action:@selector (CellDetailClick:)
      forControlEvents:UIControlEventTouchUpInside];

    [cell addSubview:_bgdBtn];

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
    initWithFrame:CGRectMake (kViewR (_imgView) + FITHEIGHT (25), kViewY (_imgView) - 10, 50, imgViewWAndH)];
    if (currentResultModel.uvMOS == -1)
    {
        [uvMosLabelValue setText:@"失败"];
    }
    else
    {
        [uvMosLabelValue setText:[NSString stringWithFormat:@"%.2f", currentResultModel.uvMOS]];
    }

    [uvMosLabelValue setFont:[UIFont boldSystemFontOfSize:valueFontSize]];
    [uvMosLabelValue setTextAlignment:NSTextAlignmentCenter];
    [uvMosLabelValue setTextColor:[UIColor orangeColor]];
    UILabel *uvMosLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (kViewR (_imgView) + FITHEIGHT (25), kViewY (_imgView) + 10, 50, imgViewWAndH)];
    [uvMosLabel setText:@"U-vMOS"];
    [uvMosLabel setFont:[UIFont systemFontOfSize:valueLableFontSize]];
    [uvMosLabel setTextAlignment:NSTextAlignmentCenter];
    [_bgdBtn addSubview:uvMosLabelValue];
    [_bgdBtn addSubview:uvMosLabel];

    // 首次缓冲时间
    UILabel *firstBufferTimeLabelValue = [[UILabel alloc]
    initWithFrame:CGRectMake (kViewR (uvMosLabelValue) + FITHEIGHT (25), kViewY (_imgView) - 10, 80, imgViewWAndH)];
    if (currentResultModel.firstBufferTime == -1)
    {
        [firstBufferTimeLabelValue setText:@"失败"];
    }
    else
    {
        [firstBufferTimeLabelValue
        setText:[NSString stringWithFormat:@"%dms", currentResultModel.firstBufferTime]];
    }
    [firstBufferTimeLabelValue setFont:[UIFont boldSystemFontOfSize:valueFontSize]];
    [firstBufferTimeLabelValue setTextAlignment:NSTextAlignmentCenter];
    [firstBufferTimeLabelValue setTextColor:[UIColor orangeColor]];
    UILabel *firstBufferTimeLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (kViewR (uvMosLabel) + FITHEIGHT (25), kViewY (_imgView) + 10, 80, imgViewWAndH)];
    [firstBufferTimeLabel setText:@"首次缓冲时间"];
    [firstBufferTimeLabel setFont:[UIFont systemFontOfSize:valueLableFontSize]];
    [firstBufferTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [_bgdBtn addSubview:firstBufferTimeLabelValue];
    [_bgdBtn addSubview:firstBufferTimeLabel];

    // 卡顿次数
    UILabel *cuttonTimesLabelValue =
    [[UILabel alloc] initWithFrame:CGRectMake (kViewR (firstBufferTimeLabelValue) + FITHEIGHT (25),
                                               kViewY (_imgView) - 10, 60, imgViewWAndH)];
    if (currentResultModel.cuttonTimes == -1)
    {
        [cuttonTimesLabelValue setText:@"失败"];
    }
    else
    {
        [cuttonTimesLabelValue setText:[NSString stringWithFormat:@"%d", currentResultModel.cuttonTimes]];
    }
    [cuttonTimesLabelValue setFont:[UIFont boldSystemFontOfSize:valueFontSize]];
    [cuttonTimesLabelValue setTextAlignment:NSTextAlignmentCenter];
    [cuttonTimesLabelValue setTextColor:[UIColor orangeColor]];
    UILabel *cuttonTimesLabel =
    [[UILabel alloc] initWithFrame:CGRectMake (kViewR (firstBufferTimeLabel) + FITHEIGHT (25),
                                               kViewY (_imgView) + 10, 60, imgViewWAndH)];
    [cuttonTimesLabel setText:@"卡顿次数"];
    [cuttonTimesLabel setFont:[UIFont systemFontOfSize:valueLableFontSize]];
    [cuttonTimesLabel setTextAlignment:NSTextAlignmentCenter];
    [_bgdBtn addSubview:cuttonTimesLabelValue];
    [_bgdBtn addSubview:cuttonTimesLabel];

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
    return kCellH;
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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, 500)
                                                          style:UITableViewStyleGrouped];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 2.设置背景颜色
    tableView.backgroundColor = [UIColor whiteColor];
    //*4.设置代理
    tableView.delegate = self;
    //*5.设置数据源
    tableView.dataSource = self;
    return tableView;
}

/**
 *cell的点击事件进入详情界面
 **/

- (void)CellDetailClick:(UIButton *)sender
{
    // cell被点击
    NSLog (@"cell-------dianjile");
    //按钮点击后alloc一个界面
    SVDetailViewCtrl *detailViewCtrl = [[SVDetailViewCtrl alloc] init];
    [detailViewCtrl setTestId:currentResultModel.testId];
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
    [_reTestButton setTitle:@"再测一次" forState:UIControlStateNormal];
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
    NSLog (@"back to testting view");
    [navigationController popViewControllerAnimated:NO];
}

/**
 *  回退到测试页面
 */
- (void)backBtnClik
{
    NSLog (@"back to test view");
    [navigationController popToRootViewControllerAnimated:NO];
}

@end
