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
#import <SPCommon/SVTimeUtil.h>
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

@synthesize testId, testType;

- (void)viewDidLoad
{
    NSString *title1 = I18N (@"Detailed Data");
    [super viewDidLoad];
    //设置背景颜色
    //    self.view.backgroundColor = [UIColor redColor];
    SVInfo (@"SVDetailViewCtrl页面");
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
    // 6.设置tableView不可上下拖动
    _tableView.bounces = NO;

    [self.view addSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_soucreMA removeAllObjects];

    [super viewDidAppear:animated];
    SVDetailViewModel *viewModel = [self defaultDetailViewModel];
    _soucreMA = [NSMutableArray array];
    [self queryResult:viewModel];

    // 定义数组展示图片
    _selectedMA = [[NSMutableArray alloc] init];

    // 把tableView添加到 view
    [_tableView reloadData];
}

- (void)queryResult:(SVDetailViewModel *)viewModel
{
    // 拼写sql
    NSMutableString *sql =
    [NSMutableString stringWithFormat:@"select * from SVDetailResultModel where testId=%ld", testId];
    if (self.testType)
    {
        [sql appendFormat:@" and testType=%d", [self.testType intValue]];
    }

    // 查询结果，如果结果为空则返回
    NSArray *resultArray = [_db executeQuery:[SVDetailResultModel class] SQL:sql];
    if (!resultArray || resultArray.count == 0)
    {
        return;
    }

    // 同一次测试的probeInfo应该还是一样的，所以只记录一次即可
    id probeInfoJson;

    // 遍历详细结果，生成对应的section和cell
    for (SVDetailResultModel *detailResultModel in resultArray)
    {
        // 得到详细结果中各个字段的值
        NSString *_testType = detailResultModel.testType;
        NSString *testResult = detailResultModel.testResult;
        NSString *testContext = detailResultModel.testContext;
        NSString *probeInfo = detailResultModel.probeInfo;

        // 将json字符串转换成字典
        NSError *error;
        id testResultJson = [NSJSONSerialization JSONObjectWithData:[testResult dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:0
                                                              error:&error];
        if (error)
        {
            SVError (@"%@", error);
            return;
        }

        id testContextJson =
        [NSJSONSerialization JSONObjectWithData:[testContext dataUsingEncoding:NSUTF8StringEncoding]
                                        options:0
                                          error:&error];
        if (error)
        {
            SVError (@"%@", error);
            return;
        }

        if (!probeInfoJson)
        {
            probeInfoJson = [NSJSONSerialization JSONObjectWithData:[probeInfo dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:0
                                                              error:&error];
            if (error)
            {
                SVError (@"%@", error);
                return;
            }
        }

        // 根据测试类型生成对应的UIView，0=video,1=web,2=speed
        if ([_testType isEqual:@"0"])
        {
            [self createViedeoResultDetailView:testResultJson contextJson:testContextJson];
        }
        if ([_testType isEqual:@"1"])
        {
            [self createWebResultDetailView:testResultJson contextJson:testContextJson];
        }
        if ([_testType isEqual:@"2"])
        {
            [self createSpeedTestResultDetailView:testResultJson contextJson:testContextJson];
        }
    }

    // 生成采集器信息的header
    [_soucreMA
    addObject:[[SVToolCells alloc] initTitleCellWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"titleCell"
                                                    title:I18N (@"Collector Information")
                                                imageName:@"rt_detail_title_collector_img"]];

    NSString *valueStr;

    // 生成采集器各个指标对应的UIView
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Carriers"),
                   @"value": [self formatValue:[probeInfoJson valueForKey:@"isp"]]
               }]];

    // 宽带套餐
    NSString *bandWidth = [probeInfoJson valueForKey:@"signedBandwidth"];
    if (!bandWidth || [bandWidth isEqualToString:@""])
    {
        valueStr = I18N (@"unknown");
    }
    else
    {
        valueStr = [NSString stringWithFormat:@"%@M", bandWidth];
    }
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Bandwidth package"),
                   @"value": valueStr
               }]];

    // 网络类型
    int networkType = [[probeInfoJson valueForKey:@"networkType"] intValue];
    switch (networkType)
    {
    case 0:
        valueStr = @"WIFI";
        break;
    case 1:
        valueStr = @"MOBILE";
        break;
    default:
        valueStr = I18N (@"unknown");
        break;
    }
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Network type"),
                   @"value": valueStr
               }]];

    //     测试时间
    //    [_soucreMA
    //    addObject:[SVToolModels modelWithDict:@{
    //        @"key": I18N (@"Test time"),
    //        @"value":
    //        [SVTimeUtil formatDateByMilliSecond:(self.testId / 1000) formatStr:@"yyyy-MM-dd
    //        HH:mm:ss"]
    //    }]];

    NSString *timeString =
    [SVTimeUtil formatDateByMilliSecond:(self.testId / 1000) formatStr:@"yyyy-MM-dd HH:mm:ss"];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Test time"),
                   @"value": timeString
               }]];
}

// 生成视频测试展示详细结果需要的UIView
- (void)createViedeoResultDetailView:(id)testResultJson contextJson:(id)testContextJson
{
    // 生成header
    [_soucreMA addObject:[[SVToolCells alloc] initTitleCellWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"titleCell"
                                                               title:I18N (@"Video Test")
                                                           imageName:@"rt_detail_title_video_img"]];

    // 生成各个指标对应的UIView
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"U-vMOS Score"),
                   @"value": [self formatFloatValue:[testResultJson valueForKey:@"UvMOSSession"]]
               }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"      Video View score"),
                   @"value": [self formatFloatValue:[testResultJson valueForKey:@"sViewSession"]]
               }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"      Video quality score"),
                   @"value": [self formatFloatValue:[testResultJson valueForKey:@"sQualitySession"]]
               }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"      Interaction score"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"sInteractionSession"]]
    }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Initial buffer time"),
        @"value": [self formatIntValue:[testResultJson valueForKey:@"firstBufferTime"] unit:@"ms"]
    }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Buffer time"),
        @"value":
        [self formatIntValue:[testResultJson valueForKey:@"videoCuttonTotalTime"] unit:@"ms"]
    }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Butter times"),
                   @"value": [self formatValue:[testResultJson valueForKey:@"videoCuttonTimes"]]
               }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Download speed"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"downloadSpeed"] unit:@"Kbps"]
    }]];

    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Bit rate"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"bitrate"] unit:@"Kbps"]
    }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Frame rate"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"frameRate"] unit:@"Fps"]
    }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Resolution"),
                   @"value": [self formatValue:[testResultJson valueForKey:@"videoResolution"]]
               }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Screen size"),
                   @"value": [self formatIntValue:[testResultJson valueForKey:@"screenSize"]
                                             unit:I18N (@"Inch")]
               }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Video URL"),
                   @"value": [self formatValue:[testContextJson valueForKey:@"videoURL"]]
               }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Video server location"),
        @"value": [self formatValue:[testContextJson valueForKey:@"videoSegemnetLocation"]]
    }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Carrier"),
                   @"value": [self formatValue:[testContextJson valueForKey:@"videoSegemnetISP"]]
               }]];
}

// 生成带宽测试展示详细结果需要的UIView
- (void)createWebResultDetailView:(id)testResultJson contextJson:(id)testContextJson
{
    // 生成header
    [_soucreMA addObject:[[SVToolCells alloc] initTitleCellWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"titleCell"
                                                               title:I18N (@"Web Test")
                                                           imageName:@"rt_detail_title_web_img"]];

    for (NSString *url in [testResultJson allKeys])
    {
        // 将json字符串转换成字典
        NSError *error;
        id currentResultJson = [NSJSONSerialization
        JSONObjectWithData:[[testResultJson objectForKey:url] dataUsingEncoding:NSUTF8StringEncoding]
                   options:0
                     error:&error];
        if (error)
        {
            SVError (@"%@", error);
            continue;
        }

        // 生成testUrl对应的UIView
        [_soucreMA addObject:[[SVToolCells alloc] initUrlCellWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:@"urlCell"
                                                               testUrl:url]];

        // 生成各个指标对应的UIView
        [_soucreMA
        addObject:[SVToolModels modelWithDict:@{
            @"key": I18N (@"Response Time"),
            @"value":
            [self formatFloatValue:[currentResultJson valueForKey:@"responseTime"] unit:@"s"]
        }]];
        [_soucreMA
        addObject:[SVToolModels modelWithDict:@{
            @"key": I18N (@"Load duration"),
            @"value": [self formatFloatValue:[currentResultJson valueForKey:@"totalTime"] unit:@"s"]
        }]];
        [_soucreMA
        addObject:[SVToolModels modelWithDict:@{
            @"key": I18N (@"Download"),
            @"value":
            [self formatFloatValue:[currentResultJson valueForKey:@"downloadSpeed"] unit:@"Kbps"]
        }]];
    }
}

// 初始化testUrl的UIView
- (UIView *)createTestUrlView:(NSString *)testUrl
{
    // 初始化UIView
    UIView *testUrlView = [[UIView alloc] init];

    // 设置title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake (kMargin, -2, kScreenW - kMargin, 40)];
    label.text = testUrl;
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textAlignment = NSTextAlignmentCenter;
    [testUrlView addSubview:label];

    return testUrlView;
}

// 生成网页测试展示详细结果需要的UIView
- (void)createSpeedTestResultDetailView:(id)testResultJson contextJson:(id)testContextJson
{
    // 生成header
    [_soucreMA addObject:[[SVToolCells alloc] initTitleCellWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"titleCell"
                                                               title:I18N (@"Speed Test")
                                                           imageName:@"rt_detail_title_ftp_img"]];

    // 生成各个指标对应的UIView
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Download speed"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"downloadSpeed"] unit:@"Mbps"]
    }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Upload speed"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"uploadSpeed"] unit:@"Mbps"]
    }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Delay"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"delay"] unit:@"ms"]
    }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Server Location"),
                   @"value": [testResultJson valueForKey:@"location"]
               }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Carrier"),
                   @"value": [testResultJson valueForKey:@"isp"]
               }]];
}


// 默认的model
- (SVDetailViewModel *)defaultDetailViewModel
{
    SVDetailViewModel *viewModel = [[SVDetailViewModel alloc] init];
    viewModel.UvMOSSession = @"-1";
    viewModel.firstBufferTime = @"-1";
    viewModel.videoCuttonTimes = @"-1";
    viewModel.bitrate = @"-1";
    return viewModel;
}

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
    id currentObj = _soucreMA[indexPath.section];
    if ([currentObj isKindOfClass:[SVToolCells class]] &&
        [[currentObj reuseIdentifier] isEqualToString:@"titleCell"])
    {
        return 35;
    }
    return kScreenH * 0.07;
}

//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取model中的当前对象
    id currentObj = _soucreMA[indexPath.section];

    // 标题cell
    if ([currentObj isKindOfClass:[SVToolCells class]])
    {
        return currentObj;
    }

    // 指标cell
    static NSString *cellId = @"cell";
    SVToolCells *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell =
        [[SVToolCells alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    if ([currentObj isKindOfClass:[SVToolModels class]])
    {
        [cell cellViewModelByToolModel:currentObj Section:indexPath.section];
    }
    return cell;
}

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
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
//输出浮点型的数值,保留2位小数
- (NSString *)formatFloatValue:(NSString *)value
{
    return [NSString stringWithFormat:@"%.2f", [value floatValue]];
}
//输出整形的数值,无小数
- (NSString *)formatValue:(NSString *)value
{
    if (!value)
    {
        return @" ";
    }
    return [NSString stringWithFormat:@"%@ ", value];
}
//输出整形的数值,无小数+单位
- (NSString *)formatIntValue:(NSString *)value unit:(NSString *)unit
{
    return [NSString stringWithFormat:@"%.0f%@ ", [value floatValue], unit];
}
//输出浮点型的数值,保留2位小数+单位
- (NSString *)formatFloatValue:(NSString *)value unit:(NSString *)unit
{
    return [NSString stringWithFormat:@"%.2f%@ ", [value floatValue], unit];
}


@end
