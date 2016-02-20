//
//  SVDetailViewCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/2/14.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVDetailViewCtrl.h"
#import "SVDetailViewModel.h"
#import "SVResultViewCtrl.h"
#import "SVToolCells.h"
#import <SPCommon/SVDBManager.h>
#import <SPCommon/SVI18N.h>
#import <SPCommon/SVLog.h>
#import <SPService/SVDetailResultModel.h>
#define kMargin 10
#define kFirstHederH 40
#define kLastFooterH 140

@interface SVDetailViewCtrl () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *soucreMA;
@property (nonatomic, retain) NSMutableArray *selectedMA;
@end

@implementation SVDetailViewCtrl
{
    SVDBManager *_db;
}

@synthesize testId;

- (void)viewDidLoad
{
    NSString *title1 = I18N (@"Detailed Data");
    [super viewDidLoad];
    //设置背景颜色
    //    self.view.backgroundColor = [UIColor redColor];
    NSLog (@"SVDetailViewCtrl页面");
    _db = [SVDBManager sharedInstance];
    // 1.自定义navigationItem.title
    self.navigationItem.title = title1;
    //电池显示不了,设置样式让电池显示
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

    // 2.设置整个Viewcontroller
    //设置背景颜色
    self.view.backgroundColor =
    [UIColor colorWithRed:250 / 255.0 green:250 / 255.0 blue:250 / 255.0 alpha:1.0];

    // 3.自定义UIBarButtonItem(图片调整到最左边)
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, 45, 23)];
    [button setImage:[UIImage imageNamed:@"homeindicator"] forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *back0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil
                                                                           action:nil];
    back0.width = -15;
    self.navigationItem.leftBarButtonItems = @[back0, backButton];
    // 4.设置点击事件
    [button addTarget:self
               action:@selector (backBtnClik)
     forControlEvents:UIControlEventTouchUpInside];

    //为了保持平衡添加一个leftBtn
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake (300, 0, 23, 23)];
    [button1 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    UIBarButtonItem *backButton1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.rightBarButtonItem = backButton1;

    // 5.编辑界面
    //一.创建一个 tableView
    // 1.style:Grouped化合的,分组的

    _tableView =
    [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    // 2.设置背景颜色
    _tableView.backgroundColor =
    [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1];
    // 3.设置 table 的行高
    _tableView.rowHeight = 50;
    //*4.设置代理
    _tableView.delegate = self;
    //*5.设置数据源
    _tableView.dataSource = self;
    //设置tableView的section的分割线隐藏
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_soucreMA removeAllObjects];

    [super viewDidAppear:animated];
    SVDetailViewModel *viewModel = [self defaultDetailViewModel];
    [self queryResult:viewModel];
    //三.添加
    // 6.定义数组展示图片
    _selectedMA = [NSMutableArray array];


    NSString *title1 = I18N (@"U-vMOS Score");
    NSString *title2 = I18N (@"      Video View score");
    NSString *title3 = I18N (@"      Video quality score");
    NSString *title4 = I18N (@"      Interaction score");
    NSString *title5 = I18N (@"Initial buffer time");
    NSString *title6 = I18N (@"Buffer time");
    NSString *title7 = I18N (@"Butter times");
    NSString *title8 = I18N (@"Download speed");
    NSString *title9 = I18N (@"Bit rate");
    NSString *title10 = I18N (@"Frame rate");
    NSString *title11 = I18N (@"Resolution");
    NSString *title12 = I18N (@"Screen size");
    NSString *title13 = I18N (@"Video URL");
    NSString *title14 = I18N (@"Video server location");
    NSString *title15 = I18N (@"Carrier");
    NSString *title16 = I18N (@"Carriers");
    NSString *title17 = I18N (@"Bandwidth package");
    NSString *title18 = I18N (@"unknown");
    NSString *title19 = I18N (@"Network type");
    NSString *title20 = I18N (@"inch");

    NSArray *sourceA = @[
        @{
            @"title": title1,
            @"title2": [self formatFloatValue:viewModel.UvMOSSession],
        },
        @{
            @"title": title2,
            @"title2": [self formatFloatValue:viewModel.sViewSession],
        },
        @{
            @"title": title3,
            @"title2": [self formatFloatValue:viewModel.sQualitySession],
        },
        @{
            @"title": title4,
            @"title2": [self formatFloatValue:viewModel.sInteractionSession],
        },
        @{
            @"title": title5,
            @"title2": [self formatValue:viewModel.firstBufferTime unit:@"ms"],
        },
        @{
            @"title": title6,
            @"title2": [self formatValue:viewModel.videoCuttonTotalTime unit:@"ms"],
        },
        @{ @"title": title7,
           @"title2": [self formatValue:viewModel.videoCuttonTimes] },
        @{
            @"title": title8,
            @"title2": [self formatValue:viewModel.downloadSpeed unit:@"kbps"],

        },
        @{
            @"title": title9,
            @"title2": [self formatValue:viewModel.bitrate unit:@"kbps"],
        },
        @{
            @"title": title10,
            @"title2": [self formatValue:viewModel.frameRate unit:@"Fps"],
        },
        @{
            @"title": title11,
            @"title2": [self formatValue:viewModel.videoResolution],
        },
        @{
            @"title": title12,
            @"title2": [self formatValue:viewModel.screenSize unit:title20],
        },
        @{
            @"title": title13,
            @"title2": [self formatValue:viewModel.videoSegementURLString],
        },
        @{
            @"title": title14,
            @"title2": [self formatValue:viewModel.videoSegemnetLocation],
        },

        @{
            @"title": title15,
            @"title2": [self formatValue:viewModel.videoSegemnetISP],
        },

        @{
            @"title": title16,
            @"title2": [self formatValue:viewModel.isp],
        },
        @{ @"title": title17,
           @"title2": title18 },
        @{ @"title": title19,
           @"title2": @"WIFI" },
        //        @{ @"title": @"测试时间",
        //           @"title2": @"2016年02月16日 09:15:10" },
        //        @{
        //            @"title": @"信号强度",
        //            @"title2": @"-104"
        //                       @"dBm"
        //        },

    ];
    NSMutableArray *sourceMA = [NSMutableArray array];
    for (int i = 0; i < sourceA.count; i++)
    {
        SVToolModels *toolModel = [SVToolModels modelWithDict:sourceA[i]];
        [sourceMA addObject:toolModel];
    }

    _soucreMA = sourceMA;
    // 7.把tableView添加到 view

    [_tableView reloadData];
}

- (void)queryResult:(SVDetailViewModel *)viewModel
{
    NSString *sql =
    [NSString stringWithFormat:@"select * from SVDetailResultModel where testId=%ld;", testId];
    NSArray *resultArray = [_db executeQuery:[SVDetailResultModel class] SQL:sql];
    if (!resultArray || resultArray.count == 0)
    {
        return;
    }

    SVDetailResultModel *detailResultModel = resultArray[0];
    NSString *testId = detailResultModel.testId;
    //    NSString *testType = detailResultModel.testType;
    NSString *testResult = detailResultModel.testResult;
    NSString *testContext = detailResultModel.testContext;
    NSString *probeInfo = detailResultModel.probeInfo;

    NSError *error;
    id testResultJson = [NSJSONSerialization JSONObjectWithData:[testResult dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:0
                                                          error:&error];
    if (error)
    {
        SVError (@"%@", error);
        return;
    }

    id testContextJson = [NSJSONSerialization JSONObjectWithData:[testContext dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:&error];
    if (error)
    {
        SVError (@"%@", error);
        return;
    }

    id probeInfoJson = [NSJSONSerialization JSONObjectWithData:[probeInfo dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:0
                                                         error:&error];
    if (error)
    {
        SVError (@"%@", error);
        return;
    }

    viewModel.sViewSession = [testResultJson valueForKey:@"sViewSession"];
    viewModel.sQualitySession = [testResultJson valueForKey:@"sQualitySession"];
    viewModel.sInteractionSession = [testResultJson valueForKey:@"sInteractionSession"];
    viewModel.UvMOSSession = [testResultJson valueForKey:@"UvMOSSession"];
    viewModel.firstBufferTime = [testResultJson valueForKey:@"firstBufferTime"];
    viewModel.videoCuttonTimes = [testResultJson valueForKey:@"videoCuttonTimes"];
    viewModel.videoCuttonTotalTime = [testResultJson valueForKey:@"videoCuttonTotalTime"];
    viewModel.downloadSpeed = [testResultJson valueForKey:@"downloadSpeed"];
    viewModel.bitrate = [testResultJson valueForKey:@"bitrate"];
    viewModel.frameRate = [testResultJson valueForKey:@"frameRate"];
    viewModel.videoResolution = [testResultJson valueForKey:@"videoResolution"];
    viewModel.screenSize = [testResultJson valueForKey:@"screenSize"];

    viewModel.videoSegemnetISP = [testContextJson valueForKey:@"videoSegemnetISP"];
    viewModel.videoSegemnetLocation = [testContextJson valueForKey:@"videoSegemnetLocation"];
    viewModel.videoSegementURLString = [testContextJson valueForKey:@"videoSegementURLString"];

    viewModel.isp = [probeInfoJson valueForKey:@"isp"];
    viewModel.location = [probeInfoJson valueForKey:@"location"];
    viewModel.networkType = [probeInfoJson valueForKey:@"networkType"];
    viewModel.singnal = [probeInfoJson valueForKey:@"singnal"];
    //    viewModel.testTime = testId;
}

- (SVDetailViewModel *)defaultDetailViewModel
{
    SVDetailViewModel *viewModel = [[SVDetailViewModel alloc] init];
    viewModel.UvMOSSession = @"-1";
    viewModel.firstBufferTime = @"-1";
    viewModel.videoCuttonTimes = @"-1";
    viewModel.bitrate = @"-1";
    return viewModel;
}

//方法:

//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.soucreMA.count;
}
//设置 tableView的 numberOfRowsInSection(设置每个section中有几个cell)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kScreenH * 0.07;
}
//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellId = @"cell";
    SVToolCells *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell =
        [[SVToolCells alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.delegate = self;
    [cell cellViewModel2:_soucreMA[indexPath.section] section:indexPath.section];
    return cell;
}

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 15)
    {
        return 35;
    }
    else
    {
        return 0.01;
    }
}
//设置 tableView 的 sectionHeader蓝色 的header的有无
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title1 = I18N (@"Video Test");
    NSString *title2 = I18N (@"Collector Information");
    if (section == 0)
    {

        UIView *bgdView = [[UIView alloc] init];
        UIImage *image = [UIImage imageNamed:@"rt_detail_title_video_img"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake (18, 10, 17, 17);
        [bgdView addSubview:imageView];

        UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake (kMargin + 33, -2, kScreenW - kMargin, kFirstHederH)];
        label.text = title1;
        label.font = [UIFont systemFontOfSize:12.0f];
        [bgdView addSubview:label];
        return bgdView;
    }
    if (section == 15)
    {
        UIView *bgdView = [[UIView alloc] init];
        UIImage *image = [UIImage imageNamed:@"rt_detail_title_collector_img"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake (18, 10, 17, 17);
        [bgdView addSubview:imageView];

        UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake (kMargin + 33, -2, kScreenW - kMargin, kFirstHederH)];
        label.text = title2;
        label.font = [UIFont systemFontOfSize:12.0f];
        [bgdView addSubview:label];
        return bgdView;
    }
    return nil;
}
//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0.05;
    }
    else
        return 0.05;
}

//返回到父控制器
- (void)backBtnClik
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)formatFloatValue:(NSString *)value
{
    return [NSString stringWithFormat:@"%.2f", [value floatValue]];
}

- (NSString *)formatValue:(NSString *)value
{
    if (!value)
    {
        return @" ";
    }

    return [NSString stringWithFormat:@"%@ ", value];
}

- (NSString *)formatValue:(NSString *)value unit:(NSString *)unit
{
    if ([value isKindOfClass:NSNumber.class])
    {
        return [NSString stringWithFormat:@"%lld%@ ", !value ? 0l : value.longLongValue, unit];
    }

    return [NSString stringWithFormat:@"%@%@", !value ? @"" : value, unit];
}

@end
