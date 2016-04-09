//
//  SVResultViewCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#define Button_Tag 10

#import "SVDBManager.h"
#import "SVDetailViewCtrl.h"
#import "SVResultCell.h"
#import "SVResultViewCtrl.h"
#import "SVSummaryResultModel.h"

@interface SVResultViewCtrl () <SVResultCellDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSInteger currentBtn;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *bottomImageView;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIButton *typeButton;

@end

@implementation SVResultViewCtrl
{
    // 记录所有标题的button
    NSMutableArray *titleBtns;

    // navigationBar的原始高度
    double originH;

    SVDBManager *_db;
    int _selectedResultTestId;
    NSMutableDictionary *buttonAndTest;
}

#pragma mark - 懒加载
- (UIImageView *)bottomImageView
{
    if (_bottomImageView == nil)
    {
        _bottomImageView = [[UIImageView alloc] init];
        _bottomImageView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    }
    return _bottomImageView;
}
- (UIImageView *)imageView
{
    if (_imageView == nil)
    {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}
- (NSMutableArray *)dataSource
{
    if (_dataSource == nil)
    {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (UITableView *)tableView
{
    if (_tableView == nil)
    {
        // 创建一个 tableView
        CGFloat tabBarH = self.tabBarController.tabBar.frame.size.height;
        _tableView = [self createTableViewWithRect:CGRectMake (0, 0, kScreenW, kScreenH - tabBarH)
                                         WithStyle:UITableViewStyleGrouped
                                         WithColor:[UIColor colorWithHexString:@"#FAFAFA"]
                                      WithDelegate:self
                                    WithDataSource:self];
    }
    return _tableView;
}

#pragma mark - view方法
- (void)viewDidLoad
{
    // 设置标题
    [self initTitleViewWithTitle:I18N (@"Result List")];

    // 初始化数据库和表
    _db = [SVDBManager sharedInstance];
    [super viewDidLoad];
    SVInfo (@"SVResultView页面");
    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];

    //添加NavigationRightItem
    [self addNavigationRightItem];

    // 将tableView添加到 view上
    [self.view addSubview:self.tableView];

    currentBtn = -1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //默认情况下按照时间的降序排列
    //从数据库中读取数据
    [self readDataFromDB:@"testTime" order:@"desc"];
}

// 在显示view的时候修改navigationBar的高度
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 设置navigationBar的高度
    CGRect rect = self.navigationController.navigationBar.frame;
    originH = rect.size.height;
    [self.navigationController.navigationBar
    setFrame:CGRectMake (rect.origin.x, rect.origin.y, rect.size.width, FITHEIGHT (298))];

    // 设置标题距离底部的距离
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:FITHEIGHT (-154)
                                                                  forBarMetrics:UIBarMetricsDefault];

    // 设置右侧按钮距离底部的距离
    [self.navigationItem.rightBarButtonItem setBackgroundVerticalPositionAdjustment:FITHEIGHT (-154)
                                                                      forBarMetrics:UIBarMetricsDefault];

    //在NavigationBar下面添加一个View
    [self addHeadView];
}

// 在页面节将消失时，还原设置
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // 还原navigationBar的高度
    CGRect rect = self.navigationController.navigationBar.frame;
    [self.navigationController.navigationBar
    setFrame:CGRectMake (rect.origin.x, rect.origin.y, rect.size.width, originH)];

    // 设置标题距离底部的距离
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:-0.0
                                                                  forBarMetrics:UIBarMetricsDefault];

    // 设置右侧按钮距离底部的距离
    [self.navigationItem.rightBarButtonItem setBackgroundVerticalPositionAdjustment:-0.0
                                                                      forBarMetrics:UIBarMetricsDefault];

    // 将所有button移除
    for (UIButton *btn in titleBtns)
    {
        [btn removeFromSuperview];
    }
}


#pragma mark - 创建UI
#pragma mark - 添加NavigationRightItem
- (void)addNavigationRightItem
{
    UIBarButtonItem *rithtItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_clear"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector (removeButtonClicked:)];
    [rithtItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rithtItem;
}
//清除按钮点击事件
- (void)removeButtonClicked:(UIButton *)button
{
    NSString *title1 = I18N (@"Prompt");
    NSString *title2 = I18N (@"Clear all test results");
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
        SVInfo (@"确定删除所有数据");

        //从数据库中删除
        [_db executeUpdate:@"delete from SVSummaryResultModel;"];

        //从数据库中删除
        [_db executeUpdate:@"delete from SVDetailResultModel;"];

        //从UI上删除
        [_dataSource removeAllObjects];
        [_tableView reloadData];
    }
}

- (void)addHeadView
{
    NSString *type = I18N (@"Type");
    NSString *time = I18N (@"Time");
    NSString *uVmos = I18N (@"U-vMOS");
    NSString *loadTime = I18N (@"Load Time");
    NSString *bandwidth = I18N (@"Bandwidth");

    NSArray *titles = @[type, time, uVmos, loadTime, bandwidth];
    NSArray *images = @[
        @"ic_network_type",
        @"ic_start_time",
        @"ic_video_testing",
        @"ic_web_test",
        @"ic_speed_testing"
    ];

    // 初始化数组
    titleBtns = [[NSMutableArray alloc] init];

    // 设置左右边距
    CGFloat BandGap = FITWIDTH (22);

    // 设置按钮宽度
    CGFloat ButtonWidth = (kScreenW - 2 * BandGap) / 5;

    for (int i = 0; i < 5; i++)
    {
        UIButton *currButton = [[UIButton alloc]
        initWithFrame:CGRectMake (BandGap + ButtonWidth * i, FITHEIGHT (144), ButtonWidth, FITHEIGHT (154))];

        // 文字
        [currButton setTitle:titles[i] forState:UIControlStateNormal];
        currButton.titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (30)];

        // 设置文字居中
        currButton.titleLabel.textAlignment = NSTextAlignmentCenter;

        // button普通状态下的字体颜色
        [currButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF" alpha:0.5]
                         forState:UIControlStateNormal];

        // button选中状态下的字体颜色
        [currButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"]
                         forState:UIControlStateSelected];
        currButton.titleEdgeInsets = UIEdgeInsetsMake (FITHEIGHT (72), -FITWIDTH (70), 0, 0);

        // 图片
        // button普通状态下的图片
        UIImage *btnImage = [self imageByApplyingAlpha:0.5 image:[UIImage imageNamed:images[i]]];
        [currButton setImage:btnImage forState:UIControlStateNormal];

        // button选中状态下的图片
        [currButton setImage:[UIImage imageNamed:images[i]] forState:UIControlStateSelected];
        currButton.imageEdgeInsets = UIEdgeInsetsMake (-FITWIDTH (43), FITHEIGHT (59), 0, 0);

        [currButton addTarget:self
                       action:@selector (buttonClick:)
             forControlEvents:UIControlEventTouchUpInside];
        currButton.tag = Button_Tag + i;
        currButton.selected = NO;
        [self.navigationController.navigationBar addSubview:currButton];
        if (i == 0)
        {
            _typeButton = currButton;
        }

        [titleBtns addObject:currButton];
    }
}

//按钮点击事件
- (void)buttonClick:(UIButton *)button
{
    if (!self.button)
    {
        self.button = button;
    }
    if (button != self.button)
    {
        self.button.selected = NO;
        self.button = button;
    }
    self.button.selected = YES;
    // 在被点击的按钮下方 添加细长白条
    switch (button.tag - Button_Tag)
    {
    case 0:
        self.bottomImageView.frame =
        CGRectMake (FITWIDTH (22), FITHEIGHT (292), FITWIDTH (207), FITHEIGHT (6));
        if (self.bottomImageView)
        {
            [self.bottomImageView removeFromSuperview];
        }
        [self.navigationController.navigationBar addSubview:self.bottomImageView];
        break;
    case 1:
        self.bottomImageView.frame =
        CGRectMake (FITWIDTH (229), FITHEIGHT (292), FITWIDTH (207), FITHEIGHT (6));
        if (self.bottomImageView)
        {
            [self.bottomImageView removeFromSuperview];
        }
        [self.navigationController.navigationBar addSubview:self.bottomImageView];
        break;
    case 2:
        self.bottomImageView.frame =
        CGRectMake (FITWIDTH (436), FITHEIGHT (292), FITWIDTH (207), FITHEIGHT (6));
        if (self.bottomImageView)
        {
            [self.bottomImageView removeFromSuperview];
        }
        [self.navigationController.navigationBar addSubview:self.bottomImageView];
        break;
    case 3:
        self.bottomImageView.frame =
        CGRectMake (FITWIDTH (643), FITHEIGHT (292), FITWIDTH (207), FITHEIGHT (6));
        if (self.bottomImageView)
        {
            [self.bottomImageView removeFromSuperview];
        }
        [self.navigationController.navigationBar addSubview:self.bottomImageView];
        break;
    case 4:
        self.bottomImageView.frame =
        CGRectMake (FITWIDTH (850), FITHEIGHT (292), FITWIDTH (207), FITHEIGHT (6));
        if (self.bottomImageView)
        {
            [self.bottomImageView removeFromSuperview];
        }
        [self.navigationController.navigationBar addSubview:self.bottomImageView];
        break;
    default:
        break;
    }

    //按钮被点击后 右侧显示排序箭头
    UIImage *image = [UIImage imageNamed:@"ic_sort"];
    self.imageView.frame = CGRectMake (CGRectGetMaxX (button.titleLabel.frame),
                                       button.titleLabel.frame.origin.y - FITWIDTH (35),
                                       image.size.width, image.size.height);
    static int a = 0;

    NSString *type = @"type";
    NSString *order = @"asc";

    if (a % 2 == 0)
    {
        //显示向上箭头
        UIImage *image = [UIImage imageNamed:@"ic_sort_asc"];
        self.imageView.image = image;
        switch (button.tag - Button_Tag)
        {
        case 0:
            //类型
            SVInfo (@"类型--箭头向上");
            type = @"type";
            order = @"asc";
            break;
        case 1:
            //时间
            SVInfo (@"时间--箭头向上");
            type = @"testTime";
            order = @"asc";
            break;
        case 2:
            // U-vMOS
            SVInfo (@"U-vMOS--箭头向上");
            type = @"UvMOS";
            order = @"asc";
            break;
        case 3:
            //加载时间
            SVInfo (@"加载时间--箭头向上");
            type = @"loadTime";
            order = @"asc";
            break;
        case 4:
            //带宽
            SVInfo (@"带宽--箭头向上");
            type = @"bandwidth";
            order = @"asc";
            break;
        default:
            break;
        }
        currentBtn = button.tag - Button_Tag;
    }
    else
    { //显示向下箭头
        self.imageView.image = [UIImage imageNamed:@"ic_sort"];

        switch (button.tag - Button_Tag)
        {
        case 0:
            //类型
            SVInfo (@"类型--箭头向下");
            type = @"type";
            order = @"desc";
            break;
        case 1:
            //时间
            SVInfo (@"时间--箭头向下");
            type = @"testTime";
            order = @"desc";
            break;
        case 2:
            // U-vMOS
            SVInfo (@"U-vMOS--箭头向下");
            type = @"UvMOS";
            order = @"desc";
            break;
        case 3:
            //加载时间
            SVInfo (@"加载时间--箭头向下");
            type = @"loadTime";
            order = @"desc";
            break;
        case 4:
            //带宽
            SVInfo (@"带宽--箭头向下");
            type = @"bandwidth";
            order = @"desc";
            break;
        default:
            break;
        }
    }
    a++;
    // asc 生序  desc 降序
    [self readDataFromDB:type order:order];
    [self.imageView removeFromSuperview];
    [button addSubview:self.imageView];
}


#pragma mark -  读取数据方法
/**
 *  读取数据方法
 *
 *  @param type  类型
 *  @param order 展示顺序
 */
- (void)readDataFromDB:(NSString *)type order:(NSString *)order
{
    // 添加数据之前 先清空数据源
    _selectedResultTestId = 0;
    [buttonAndTest removeAllObjects];
    [self.dataSource removeAllObjects];

    // 添加数据
    NSString *sql = [NSString
    stringWithFormat:@"select * from SVSummaryResultModel order by %@ %@ limit 100 offset  0;", type, order];
    NSArray *array = [_db executeQuery:[SVSummaryResultModel class] SQL:sql];
    [self.dataSource addObjectsFromArray:array];

    // 刷新列表
    [_tableView reloadData];
}


#pragma mark - tableView代理方法
//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

//设置 tableView的 numberOfRowsInSection(设置每个section中有几个cell)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FITHEIGHT (170);
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
    return FITHEIGHT (30);
}

//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedResultTestId += 1;

    // 创建cell
    SVResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];
    if (cell == nil)
    {
        cell = [[SVResultCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:@"aCell"
                                           WithTag:_selectedResultTestId];

        //取消cell 被点中的效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }

    // 初始化结果数据
    SVSummaryResultModel *summaryResultModel = self.dataSource[indexPath.section];
    if (!buttonAndTest)
    {
        buttonAndTest = [[NSMutableDictionary alloc] init];
    }
    [buttonAndTest setObject:summaryResultModel
                      forKey:[NSString stringWithFormat:@"key_%d", _selectedResultTestId]];

    [cell setResultModel:summaryResultModel];

    //设置cell的背景颜色
    cell.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];

    return cell;
}

#pragma mark - 点击事件
/**
 *section中的cell的点击事件(按钮选中后的状态设置)
 **/

- (void)toolCellClick:(SVResultCell *)cell
{
    // cell被点击
    SVInfo (@"cell-------dianjile");

    // 按钮点击后alloc一个界面
    SVDetailViewCtrl *detailViewCtrl = [[SVDetailViewCtrl alloc] init];
    SVSummaryResultModel *summaryResultModel =
    [buttonAndTest objectForKey:[NSString stringWithFormat:@"key_%zd", cell.bgdBtn.tag]];
    long long testId = [summaryResultModel.testId longLongValue];
    [detailViewCtrl setTestId:testId];
    //移除白条
    [self.bottomImageView removeFromSuperview];
    // 隐藏hidesBottomBarWhenPushed
    self.hidesBottomBarWhenPushed = YES;
    // push界面
    [self.navigationController pushViewController:detailViewCtrl animated:NO];
    // 返回时显示hidesBottomBarWhenPushed
    self.hidesBottomBarWhenPushed = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
