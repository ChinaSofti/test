//
//  SVTestViewCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "AlertView.h"
#import "SVCurrentResultModel.h"
#import "SVCurrentResultViewCtrl.h"
#import "SVRealReachability.h"
#import "SVSpeedTestingViewCtrl.h"
#import "SVTestContextGetter.h"
#import "SVTestViewCtrl.h"
#import "SVTimeUtil.h"
#import "SVToolCell.h"
#import "SVVideoTestingCtrl.h"
#import "SVWebTestingViewCtrl.h"

@interface SVTestViewCtrl () <SVToolCellDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *soucreMA;
@property (nonatomic, retain) NSMutableArray *selectedMA;
@property (nonatomic, retain) UIButton *testBtn;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UIView *footerView;
@end


@implementation SVTestViewCtrl

- (void)viewDidLoad
{

    [super viewDidLoad];
    SVInfo (@"SVTestViewController");

    // 初始化标题
    [self initTitleView];

    // 创建一个 tableView，style:Grouped化合的,分组的
    _tableView = [self createTableViewWithRect:[UIScreen mainScreen].bounds
                                     WithStyle:UITableViewStyleGrouped
                                     WithColor:[UIColor colorWithHexString:@"#FAFAFA"]
                                  WithDelegate:self
                                WithDataSource:self];

    // 定义数组展示图片
    _selectedMA = [NSMutableArray array];

    // 国际化
    NSString *videoTest = I18N (@"Video Test");
    NSString *webTest = I18N (@"Web Test");
    NSString *speedTest = I18N (@"Speed Test");

    NSArray *sourceA = @[
        @{
            @"img_normal": @"ic_video_label",
            @"img_selected": @"ic_video_label",
            @"title": videoTest,
            @"rightImg_normal": @"1",
            @"rightImg_selected": @"ic_video_check"
        },
        @{
            @"img_normal": @"ic_web_label",
            @"img_selected": @"ic_web_label",
            @"title": webTest,
            @"rightImg_normal": @"1",
            @"rightImg_selected": @"ic_web_check"
        },
        @{
            @"img_normal": @"ic_speed_label",
            @"img_selected": @"ic_speed_label",
            @"title": speedTest,
            @"rightImg_normal": @"1",
            @"rightImg_selected": @"ic_speed_check"
        }
    ];
    NSMutableArray *sourceMA = [NSMutableArray array];
    for (int i = 0; i < sourceA.count; i++)
    {
        SVToolModel *toolModel = [SVToolModel modelWithDict:sourceA[i]];
        [sourceMA addObject:toolModel];
    }
    _soucreMA = sourceMA;

    // 把tableView添加到 view
    [self.view addSubview:_tableView];

    // ---------暂时取消网络设置按钮，无论是否有网络，均显示开始测试-------
    //    SVRealReachability *realReachability = [SVRealReachability sharedInstance];
    //    [realReachability addDelegate:self];
    // ---------暂时取消网络设置按钮，无论是否有网络，均显示开始测试- end------
}

#pragma mark - tableview的方法

//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return _soucreMA.count;
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
    static NSString *cellId = @"cell";
    SVToolCell *cell =
    [[SVToolCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];

    // 取消cell的点击效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.delegate = self;
    [cell cellViewModel:_soucreMA[indexPath.section] section:indexPath.section];

    // 默认视频勾选，且不能取消勾选。在视频项上添加透明UIVIew遮挡事件
    if (indexPath.section == 0)
    {
        UIView *view =
        [[UIView alloc] initWithFrame:CGRectMake (FITWIDTH (22), 0, FITWIDTH (1036), FITHEIGHT (209))];
        [view setAlpha:0.1];
        [cell addSubview:view];
    }
    return cell;
}

//设置 tableView 的 sectionHeader
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    if (section == 0)
    {
        UIView *bgdView = [[UIView alloc] init];
        UILabel *label = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (22), FITHEIGHT (60), kScreenW - FITWIDTH (44), FITHEIGHT (36))];
        NSString *title4 = I18N (@"Select Test Item");
        label.text = title4;
        label.font = [UIFont systemFontOfSize:pixelToFontsize (36)];
        label.textColor = [UIColor colorWithHexString:@"#CC000000"];
        [bgdView addSubview:label];
        return bgdView;
    }

    return nil;
}

//设置tableView的 sectionFooter
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == _soucreMA.count - 1)
    {

        [self.footerView addSubview:self.testBtn];
        [self.footerView addSubview:self.button];

        // ---------暂时取消网络设置按钮，无论是否有网络，均显示开始测试-------
        [_button removeFromSuperview];
        [self.footerView addSubview:_testBtn];
        // ---------暂时取消网络设置按钮，无论是否有网络，均显示开始测试- end------

        return self.footerView;
    }
    return nil;
}

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return FITHEIGHT (120);
    }
    else
    {
        return FITHEIGHT (33);
    }
}

//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == _soucreMA.count - 1)
    {
        return FITHEIGHT (551);
    }
    else
        return 0.01;
}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FITHEIGHT (209);
}

#pragma mark - 开始测试按钮初始化(按钮未被选中时的状态)
//有网时候的按钮
- (UIButton *)testBtn
{
    if (_testBtn == nil)
    {
        // 按钮高度
        CGFloat testBtnH = FITHEIGHT (116);

        // 按钮类型
        _testBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        // 按钮尺寸
        _testBtn.frame = CGRectMake (FITWIDTH (104), FITHEIGHT (435), FITWIDTH (872), testBtnH);

        // 按钮背景颜色
        _testBtn.backgroundColor =
        [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1.0];
        NSString *title5 = I18N (@"Start Test");
        [_testBtn setTitle:title5 forState:UIControlStateNormal];

        // 按钮点击事件
        [_testBtn addTarget:self
                     action:@selector (testBtnClick1)
           forControlEvents:UIControlEventTouchUpInside];

        // 按钮圆角
        _testBtn.layer.cornerRadius = svCornerRadius (12);

        // 设置居中
        _testBtn.titleLabel.textAlignment = NSTextAlignmentCenter;

        // 按钮文字颜色和类型
        [_testBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

        // 设置字体大小
        [_testBtn.titleLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (48)]];

        // 按钮交互
        // 设置按钮默认情况下不可交互
        _testBtn.userInteractionEnabled = NO;

        // 设置默认情况下按钮不可点击方法2
        // _testBtn.enabled = NO;
    }
    return _testBtn;
}
//没网时候的按钮
- (UIButton *)button
{
    if (_button == nil)
    {
        // 初始化button
        NSString *title7 = I18N (@"Network Settings");
        _button = [[UIButton alloc]
        initWithFrame:CGRectMake (FITWIDTH (104), FITHEIGHT (435), FITWIDTH (872), FITHEIGHT (116))];
        [_button setTitle:title7 forState:UIControlStateNormal];
        _button.backgroundColor =
        [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
        _button.userInteractionEnabled = YES;

        // 设置字体大小
        [_button.titleLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (48)]];

        // 按钮圆角
        _button.layer.cornerRadius = svCornerRadius (12);

        // 设置居中
        _button.titleLabel.textAlignment = NSTextAlignmentCenter;

        // 按钮文字颜色和类型
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        // 按钮点击事件
        [_button addTarget:self
                    action:@selector (goNetworkSetting)
          forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
//初始化footerView
- (UIView *)footerView
{
    if (_footerView == nil)
    {
        _footerView = [[UIView alloc] init];
    }
    return _footerView;
}

/**
 *section中的cell的点击事件(按钮选中后的状态设置)
 **/

- (void)toolCellClick:(SVToolCell *)cell
{
    // 设置按钮的背景色
    self.testBtn.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];

    // 设置按钮可以点击
    // self.testBtn.enabled = YES;
    self.testBtn.userInteractionEnabled = YES;

    // 按钮文字颜色和类型
    [_testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    // 如果_selectedMA.count的值为空,添加对象
    if (!_selectedMA.count)
    {
        [_selectedMA addObject:[[NSNumber alloc] initWithInteger:cell.bgdBtn.tag]];
        return;
    }

    // 遍历他是否存在过,如果存在过移除
    BOOL isInclude = NO;
    for (NSNumber *nsTag in _selectedMA)
    {
        int tag = nsTag.intValue;
        if (tag == cell.bgdBtn.tag)
        {
            [_selectedMA removeObject:nsTag];
            isInclude = YES;
            break;
        }
    }

    // 判断是不是空,如果是空添加(跟第一个if是一样的)
    if (!isInclude)
    {
        [_selectedMA addObject:[[NSNumber alloc] initWithInteger:cell.bgdBtn.tag]];
    }

    // 如果被选中的cell数为0(也是默认情况)
    if (!_selectedMA.count)
    {
        self.testBtn.backgroundColor =
        [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1.0];

        // 设置按钮不可点击
        // self.testBtn.enabled = NO;
        self.testBtn.userInteractionEnabled = NO;

        // 按钮文字颜色和类型
        [_testBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}


// 按钮的点击事件
- (void)testBtnClick1
{
    SVInfo (@"testBtnClick...");
    //获取网络类型
    SVRealReachability *realReachablity = [SVRealReachability sharedInstance];
    SVRealReachabilityStatus status = [realReachablity getNetworkStatus];
    if (status == SV_WWANType2G || status == SV_WWANType3G || status == SV_WWANType4G)
    {
        NSString *title1 = I18N (@"Prompt");
        NSString *title2 = I18N (@"You are using a none-Wi-Fi network.Continuing the test will "
                                 @"cause extra traffic fees.");
        NSString *title3 = I18N (@"Cancel Test");
        NSString *title4 = I18N (@"Continue Test");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title1
                                                        message:title2
                                                       delegate:self
                                              cancelButtonTitle:title3
                                              otherButtonTitles:title4, nil];
        [alert show];
    }
    else
    {
        [self beginTest];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        SVInfo (@"继续测试");
        [self beginTest];
    }
    else
    {
        SVInfo (@"返回");
    }
}
//开始测试方法
- (void)beginTest
{
    [_selectedMA sortUsingComparator:^NSComparisonResult (__strong id obj1, __strong id obj2) {
      return [obj1 intValue] > [obj2 intValue];
    }];
#pragma mark - 在这里对 数组 排序
    UITabBarController *tabBarController = self.tabBarController;
    UINavigationController *navigationController = self.navigationController;

    SVCurrentResultModel *currentResultModel = [[SVCurrentResultModel alloc] init];
    [currentResultModel setTestId:[SVTimeUtil currentMilliSecondStamp]];
    [currentResultModel setNavigationController:navigationController];
    [currentResultModel setTabBarController:tabBarController];
    [currentResultModel setSelectedA:_selectedMA];

    for (id selected in _selectedMA)
    {
        // 定义一个cellIndex,来记录数组中哪一个第一个被选择的
        NSInteger cellIndex = ((NSNumber *)(selected)).integerValue;

        if (cellIndex == 0)
        {
            // 按钮点击后alloc一个界面
            SVVideoTestingCtrl *videotestingCtrl =
            [[SVVideoTestingCtrl alloc] initWithResultModel:currentResultModel];
            [currentResultModel setVideoTest:YES];
            [currentResultModel addCtrl:videotestingCtrl];
        }
        if (cellIndex == 1)
        {
            SVWebTestingViewCtrl *webtestingCtrl =
            [[SVWebTestingViewCtrl alloc] initWithResultModel:currentResultModel];
            [currentResultModel setWebTest:YES];
            [currentResultModel addCtrl:webtestingCtrl];
        }
        if (cellIndex == 2)
        {
            SVSpeedTestingViewCtrl *speedtestingCtrl =
            [[SVSpeedTestingViewCtrl alloc] initWithResultModel:currentResultModel];
            [currentResultModel setSpeedTest:YES];
            [currentResultModel addCtrl:speedtestingCtrl];
        }
    }

    SVCurrentResultViewCtrl *currentResultView =
    [[SVCurrentResultViewCtrl alloc] initWithResultModel:currentResultModel];
    [currentResultModel addCtrl:currentResultView];

    [currentResultModel pushNextCtrl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  监听网络状态变更
 *
 *  @param status 网络状态
 */
- (void)networkStatusChange:(SVRealReachabilityStatus)status
{
    //    SVInfo (@"%ld", (long)status);
    // 网络不可用，修改按钮属性
    if (status == SV_RealStatusNotReachable)
    {
        [_testBtn removeFromSuperview];
        [self.footerView addSubview:_button];
        SVInfo (@"network is not available");
    }
    else
    {
        [_button removeFromSuperview];
        [self.footerView addSubview:_testBtn];
        SVInfo (@"network is available");
    }
}

//进入设置网络界面
- (void)goNetworkSetting
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
}

@end
