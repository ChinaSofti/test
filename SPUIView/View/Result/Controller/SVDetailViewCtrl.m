//
//  SVDetailViewCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/2/14.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVDBManager.h"
#import "SVDetailResultModel.h"
#import "SVDetailViewCtrl.h"
#import "SVDetailViewModel.h"
#import "SVResultViewCtrl.h"
#import "SVTimeUtil.h"
#import "SVToolCells.h"

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
    [super viewDidLoad];
    SVInfo (@"SVDetailViewCtrl页面");

    // 设置标题
    [self initTitleViewWithTitle:I18N (@"Detailed Data")];

    _db = [SVDBManager sharedInstance];

    // 设置整个Viewcontroller
    // 设置背景颜色
    self.view.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];

    // 创建返回按钮
    [self initBackButtonWithTarget:self action:@selector (backBtnClik)];


    // 创建一个 tableView
    _tableView = [self createTableViewWithRect:[UIScreen mainScreen].bounds
                                     WithStyle:UITableViewStyleGrouped
                                     WithColor:[UIColor colorWithHexString:@"#FAFAFA"]
                                  WithDelegate:self
                                WithDataSource:self];

    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [_soucreMA removeAllObjects];

    [super viewDidAppear:animated];

    _soucreMA = [NSMutableArray array];
    [self queryResult];

    // 定义数组展示图片
    _selectedMA = [[NSMutableArray alloc] init];

    // 把tableView添加到 view
    [_tableView reloadData];
}

- (void)queryResult
{
    // 拼写sql
    NSMutableString *sql =
    [NSMutableString stringWithFormat:@"select * from SVDetailResultModel where testId=%lld", testId];
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
        valueStr = I18N (@"Unknown");
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
    NSString *networkType = [probeInfoJson valueForKey:@"networkType"];
    if ([networkType isEqualToString:@"1"])
    {
        networkType = I18N (@"WIFI");
    }
    else
    {
        networkType = I18N (@"Mobile network");
    }
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Network type"),
                   @"value": networkType
               }]];

    // 测试时间
    NSString *timeString =
    [SVTimeUtil formatDateByMilliSecond:self.testId formatStr:I18N (@"yyyy-MM-dd HH:mm:ss")];
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
    // Uvmos
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"U-vMOS Score"),
                   @"value": [self formatOneDecimal:[testResultJson valueForKey:@"UvMOSSession"]]
               }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"      sView Score"),
                   @"value": [self formatOneDecimal:[testResultJson valueForKey:@"sViewSession"]]
               }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"      sQuality Score"),
                   @"value": [self formatOneDecimal:[testResultJson valueForKey:@"sQualitySession"]]
               }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"      sInteraction Score"),
        @"value": [self formatOneDecimal:[testResultJson valueForKey:@"sInteractionSession"]]
    }]];

    // 首次缓冲时间
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Initial Buffer Time"),
        @"value": [self formatIntValue:[testResultJson valueForKey:@"firstBufferTime"] unit:@"ms"]
    }]];

    // 卡顿时长
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Stalling Time"),
        @"value":
        [self formatIntValue:[testResultJson valueForKey:@"videoCuttonTotalTime"] unit:@"ms"]
    }]];

    // 卡顿次数
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Stalling Times"),
                   @"value": [self formatValue:[testResultJson valueForKey:@"videoCuttonTimes"]]
               }]];

    // 下载速度
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Max Download Speed"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"downloadSpeed"] unit:@"Kbps"]
    }]];

    // 码率
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Bit Rate"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"bitrate"] unit:@"Kbps"]
    }]];

    // 帧数
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Frame Rate"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"frameRate"] unit:@"Fps"]
    }]];

    // 分辨率
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Resolution"),
                   @"value": [self formatValue:[testResultJson valueForKey:@"videoResolution"]]
               }]];

    // 视频大小
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Screen size"),
                   @"value": [self formatIntValue:[testResultJson valueForKey:@"screenSize"]
                                             unit:I18N (@"inch")]
               }]];

    // 视频播放时长
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Video Test Duration"),
                   @"value": [self formatIntValue:[testResultJson valueForKey:@"playDuration"]
                                             unit:I18N (@"s")]
               }]];

    // 视频地址
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Video URL"),
                   @"value": [self formatValue:[testContextJson valueForKey:@"videoURL"]]
               }]];

#pragma mark - 遍历得到所有视频分片信息，目前只显示第一条分片信息
    int index = 1;
    for (NSString *key in [testContextJson allKeys])
    {
        if ([key isEqualToString:@"videoPlayDuration"] || [key isEqualToString:@"videoURL"])
        {
            continue;
        }

        // 将json字符串转换成字典
        NSData *segementData = [[testContextJson objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        id segementJson =
        [NSJSONSerialization JSONObjectWithData:segementData options:0 error:&error];
        if (error)
        {
            SVError (@"%@", error);
            continue;
        }

        // 生成testUrl对应的UIView
        [_soucreMA addObject:[[SVToolCells alloc]
                             initSubTitleCellWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"CND Cell"
                                              subTitle:[NSString stringWithFormat:@"CDN%d%@", index, I18N (@"Information")]
                                             WithColor:[UIColor colorWithHexString:@"#FFFEB960"]]];

        // 视频分片IP
        [_soucreMA addObject:[SVToolModels modelWithDict:@{
                       @"key": I18N (@"IP Address"),
                       @"value": [self formatValue:[segementJson valueForKey:@"videoSegementIP"]]
                   }]];

        // 视频分片位置
        [_soucreMA
        addObject:[SVToolModels modelWithDict:@{
            @"key": I18N (@"City"),
            @"value": [self formatValue:[segementJson valueForKey:@"videoSegemnetLocation"]]
        }]];

        // 视频分片所属运营商
        [_soucreMA addObject:[SVToolModels modelWithDict:@{
                       @"key": I18N (@"Carrier"),
                       @"value": [self formatValue:[segementJson valueForKey:@"videoSegemnetISP"]]
                   }]];

        index++;
    }
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
        [_soucreMA addObject:[[SVToolCells alloc]
                             initSubTitleCellWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"urlCell"
                                              subTitle:url
                                             WithColor:[UIColor colorWithHexString:@"#FF38C695"]]];

        // 判断加载时间是否超过10S，如果超过则显示超时
        NSString *loadTime = [currentResultJson valueForKey:@"totalTime"];
        NSString *responseTimeValue = I18N (@"Timeout");
        NSString *loadTimeVlaue = I18N (@"Timeout");
        NSString *downloadSpeedVlaue = I18N (@"Timeout");
        if ([loadTime doubleValue] < 10)
        {
            responseTimeValue =
            [self formatFloatValue:[currentResultJson valueForKey:@"responseTime"] unit:@"s"];
            loadTimeVlaue =
            [self formatFloatValue:[currentResultJson valueForKey:@"totalTime"] unit:@"s"];
            downloadSpeedVlaue =
            [self formatFloatValue:[currentResultJson valueForKey:@"downloadSpeed"] unit:@"Kbps"];
        }
        // 生成各个指标对应的UIView
        [_soucreMA addObject:[SVToolModels modelWithDict:@{
                       @"key": I18N (@"Response Time"),
                       @"value": responseTimeValue
                   }]];
        [_soucreMA addObject:[SVToolModels modelWithDict:@{
                       @"key": I18N (@"Load duration"),
                       @"value": loadTimeVlaue
                   }]];
        [_soucreMA addObject:[SVToolModels modelWithDict:@{
                       @"key": I18N (@"Download Speed"),
                       @"value": downloadSpeedVlaue
                   }]];
    }
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
        @"key": I18N (@"Download Speed"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"downloadSpeed"] unit:@"Mbps"]
    }]];
    [_soucreMA
    addObject:[SVToolModels modelWithDict:@{
        @"key": I18N (@"Upload speed"),
        @"value": [self formatFloatValue:[testResultJson valueForKey:@"uploadSpeed"] unit:@"Mbps"]
    }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Delay"),
                   @"value": [self formatIntValue:[testResultJson valueForKey:@"delay"] unit:@"ms"]
               }]];


    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Server Location"),
                   @"value": [self stringFilter:[testResultJson valueForKey:@"location"]]
               }]];
    [_soucreMA addObject:[SVToolModels modelWithDict:@{
                   @"key": I18N (@"Carrier"),
                   @"value": [self stringFilter:[testResultJson valueForKey:@"isp"]]
               }]];
}

- (NSString *)stringFilter:(NSString *)str
{
    if (!str)
    {
        return @"";
    }
    return str;
}

// 设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.soucreMA.count;
}

// 设置 tableView的 numberOfRowsInSection(设置每个section中有几个cell)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// 设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id currentObj = _soucreMA[indexPath.section];
    if ([currentObj isKindOfClass:[SVToolCells class]] &&
        [[currentObj reuseIdentifier] isEqualToString:@"titleCell"])
    {
        return FITHEIGHT (120);
    }
    return FITHEIGHT (132);
}

// 设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
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

//设置 tableView 的 sectionHeader
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

//设置tableView的 sectionFooter
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // 设置为0会有问题，改为一个很小的值
    return 0.01;
}

//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

// 返回到父控制器
- (void)backBtnClik
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 输出浮点型的数值,保留2位小数
- (NSString *)formatFloatValue:(NSString *)value
{
    return [NSString stringWithFormat:@"%.2f", [value floatValue]];
}

// 输出浮点型的数值,保留1位小数
- (NSString *)formatOneDecimal:(NSString *)value
{
    return [NSString stringWithFormat:@"%.2f", [value floatValue]];
}

// 输出整形的数值,无小数
- (NSString *)formatValue:(NSString *)value
{
    if (!value)
    {
        return @" ";
    }
    return [NSString stringWithFormat:@"%@ ", value];
}

// 输出整形的数值,无小数+单位
- (NSString *)formatIntValue:(NSString *)value unit:(NSString *)unit
{
    return [NSString stringWithFormat:@"%.0f%@ ", [value floatValue], unit];
}

// 输出浮点型的数值,保留2位小数+单位
- (NSString *)formatFloatValue:(NSString *)value unit:(NSString *)unit
{
    return [NSString stringWithFormat:@"%.2f%@ ", [value floatValue], unit];
}


@end
