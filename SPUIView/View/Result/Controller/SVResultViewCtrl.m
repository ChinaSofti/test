//
//  SVResultViewCtrl2.m
//  SpeedPro
//
//  Created by Rain on 5/3/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVDBManager.h"
#import "SVDetailViewCtrl.h"
#import "SVResultViewCtrl.h"
#import "SVSummaryResultModel.h"

// 升序
#define ASC @"asc"
// 降序
#define DESC @"desc"

@implementation SVResultViewCtrl
{
    SVDBManager *_db;

    // 表头
    UIView *_tableHeaderView;

    // 表格
    UITableView *_tableView;

    // 表格数据源
    NSMutableArray *_dataSource;

    // 按钮被选中后，按钮下方出现的白色条形
    UIImageView *_bottomImageView;

    // 筛选类型
    NSString *_type;

    // 排序方式
    NSString *_order;

    // 升序降序图标
    UIImageView *_orderImageView;

    // 上一次选择的按钮
    UIButton *_selectedButton;
}


#pragma mark - view方法
- (void)viewDidLoad
{
    [super viewDidLoad];

    SVInfo (@"初始化SVResultView页面");
    _type = @"testTime";
    _order = @"desc";

    // 初始化 NavigationBar
    [self initNavigationBar];

    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];

    // 初始化数据库和表
    _db = [SVDBManager sharedInstance];

    _tableHeaderView = [self newTableHeaderView];
    [self.view addSubview:_tableHeaderView];
    _tableView = [self newTableView];
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //默认情况下按照时间的降序排列
    //从数据库中读取数据
    [self readDataFromDB:_type order:_order];
}

- (UITableView *)newTableView
{
    // 创建一个 tableView
    CGFloat tabBarH = self.tabBarController.tabBar.frame.size.height;
    UITableView *tableView = [super
    createTableViewWithRect:CGRectMake (0, NavBarH + StatusBarH + FITHEIGHT (150), kScreenW, kScreenH - tabBarH)
                  WithStyle:UITableViewStyleGrouped
                  WithColor:[UIColor colorWithHexString:@"#FAFAFA"]
               WithDelegate:self
             WithDataSource:self];
    // #FAFAFA
    _dataSource = [[NSMutableArray alloc] init];

    return tableView;
}

- (UIView *)newTableHeaderView
{
    // 表头的Y轴必须从 电池栏的高度 + 导航栏高度
    UIView *headerView =
    [[UIView alloc] initWithFrame:CGRectMake (0, NavBarH + StatusBarH, kScreenW, FITHEIGHT (150))];
    [headerView setBackgroundColor:[UIColor colorWithHexString:@"45545C"]];

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

    // 设置左右边距
    CGFloat BandGap = FITWIDTH (22);

    // 设置按钮宽度
    CGFloat ButtonWidth = (kScreenW - 2 * BandGap) / 5;

    for (int i = 0; i < 5; i++)
    {
        UIButton *currButton = [[UIButton alloc]
        initWithFrame:CGRectMake (BandGap + ButtonWidth * i, FITHEIGHT (5), ButtonWidth, FITHEIGHT (154))];
        [currButton setTag:i];

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
        currButton.selected = NO;
        [self.navigationController.navigationBar addSubview:currButton];
        [headerView addSubview:currButton];
    }

    return headerView;
}

#pragma mark - 按钮点击事件
- (void)buttonClick:(UIButton *)button
{
    // 在被点击的按钮下方 添加细长白条
    if (_bottomImageView)
    {
        // 如果选中细长白条存在，则先删除
        [_bottomImageView removeFromSuperview];
    }

    // 如果升序降序图标存在，则先删除
    if (_orderImageView)
    {
        [_orderImageView removeFromSuperview];
    }

    // 如果之前已经有按钮处于选中状态，则将选中状态取消
    if (_selectedButton)
    {
        [_selectedButton setSelected:NO];
    }

    _bottomImageView = [[UIImageView alloc] init];
    _bottomImageView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    _bottomImageView.frame = CGRectMake (FITWIDTH (22), FITHEIGHT (144), FITWIDTH (200), FITHEIGHT (6));

    // 设置按钮为选中状态
    [button setSelected:YES];
    _selectedButton = button;

    switch (button.tag)
    {
    case 0:
        // 如果上次用户点击的与当前按钮相同，则修改排序方法
        if ([_type isEqualToString:@"type"])
        {
            if ([_order isEqualToString:ASC])
            {
                _order = DESC;
            }
            else
            {
                _order = ASC;
            }
        }
        else
        {
            _type = @"type";
            _order = DESC;
        }
        break;
    case 1:
        [_bottomImageView setOriginX:FITWIDTH (229)];
        // 如果上次用户点击的与当前按钮相同，则修改排序方法
        if ([_type isEqualToString:@"testTime"])
        {
            if ([_order isEqualToString:ASC])
            {
                _order = DESC;
            }
            else
            {
                _order = ASC;
            }
        }
        else
        {
            _type = @"testTime";
            _order = DESC;
        }

        break;
    case 2:
        [_bottomImageView setOriginX:FITWIDTH (436)];

        // 如果上次用户点击的与当前按钮相同，则修改排序方法
        if ([_type isEqualToString:@"UvMOS"])
        {
            if ([_order isEqualToString:ASC])
            {
                _order = DESC;
            }
            else
            {
                _order = ASC;
            }
        }
        else
        {
            _type = @"UvMOS";
            _order = DESC;
        }

        break;
    case 3:
        [_bottomImageView setOriginX:FITWIDTH (643)];

        // 如果上次用户点击的与当前按钮相同，则修改排序方法
        if ([_type isEqualToString:@"loadTime"])
        {
            if ([_order isEqualToString:ASC])
            {
                _order = DESC;
            }
            else
            {
                _order = ASC;
            }
        }
        else
        {
            _type = @"loadTime";
            _order = DESC;
        }

        break;
    case 4:
        [_bottomImageView setOriginX:FITWIDTH (850)];
        // 如果上次用户点击的与当前按钮相同，则修改排序方法
        if ([_type isEqualToString:@"bandwidth"])
        {
            if ([_order isEqualToString:ASC])
            {
                _order = DESC;
            }
            else
            {
                _order = ASC;
            }
        }
        else
        {
            _type = @"bandwidth";
            _order = DESC;
        }

        break;
    default:
        break;
    }

    // 在被点击的按钮下方 添加细长白条
    [_tableHeaderView addSubview:_bottomImageView];

    UIImage *orderImage;
    if ([_order isEqualToString:DESC])
    {
        orderImage = [UIImage imageNamed:@"ic_sort"];
    }
    else
    {
        orderImage = [UIImage imageNamed:@"ic_sort_asc"];
    }

    _orderImageView =
    [[UIImageView alloc] initWithFrame:CGRectMake (CGRectGetMaxX (button.titleLabel.frame),
                                                   button.titleLabel.frame.origin.y - FITWIDTH (35),
                                                   orderImage.size.width, orderImage.size.height)];
    [_orderImageView setImage:orderImage];
    [button addSubview:_orderImageView];

    // asc 生序  desc 降序
    [self readDataFromDB:_type order:_order];
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
    [_dataSource removeAllObjects];

    // 添加数据
    NSString *sql = [NSString
    stringWithFormat:@"select * from SVSummaryResultModel order by %@ %@ limit 100 offset 0;", type, order];
    NSArray *array = [_db executeQuery:[SVSummaryResultModel class] SQL:sql];
    [_dataSource addObjectsFromArray:array];
    // 刷新列表
    [_tableView reloadData];
}


#pragma mark - 添加NavigationRightItem
- (void)initNavigationBar
{
    // 设置NavigationBar标题
    self.navigationItem.title = I18N (@"Result List");
    // NavigationBar 添加删除图标
    UIBarButtonItem *rithtItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_clear"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector (clearAllOldData)];
    [rithtItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rithtItem;
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

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return FITHEIGHT (10);
}

//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FITHEIGHT (10);
}

//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 创建cell
    SVResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];
    if (cell == nil)
    {
        cell =
        [[SVResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aCell"];

        //取消cell 被点中的效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }

    // 初始化结果数据
    SVSummaryResultModel *summaryResultModel = _dataSource[indexPath.section];
    [cell setResultModel:summaryResultModel];

    NSInteger selectedColumnIndex = 0;
    if (_selectedButton)
    {
        selectedColumnIndex = _selectedButton.tag;
    }
    [cell chanageSelectedColumnColor:selectedColumnIndex];

    //设置cell的背景颜色
    cell.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    return cell;
}

#pragma mark - section中的cell的点击事件(按钮选中后的状态设置)
- (void)toolCellClick:(SVResultCell *)cell
{
    // 按钮点击后alloc一个界面
    SVDetailViewCtrl *detailViewCtrl = [[SVDetailViewCtrl alloc] init];
    SVSummaryResultModel *resultModel = [cell getResultModel];
    long long testId = [resultModel.testId longLongValue];
    SVInfo (@"查看结果%lld对应的结果明细", testId);
    [detailViewCtrl setTestId:testId];

    // 隐藏hidesBottomBarWhenPushed
    self.hidesBottomBarWhenPushed = YES;
    // push界面
    [self.navigationController pushViewController:detailViewCtrl animated:NO];
    // 返回时显示hidesBottomBarWhenPushed
    self.hidesBottomBarWhenPushed = NO;
}


#pragma mark - 清除所有测试结果
/**
 *  清除所有测试结果
 */
- (void)clearAllOldData
{
    NSString *title1 = I18N (@"Prompt");
    NSString *title2 = I18N (@"Clear all test results");
    NSString *title3 = I18N (@"No");
    NSString *title4 = I18N (@"Yes");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title1
                                                                   message:title2
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:title3
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                       SVInfo (@"不清除任何结果");

                                                     }];

    UIAlertAction *yesAction =
    [UIAlertAction actionWithTitle:title4
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                             SVInfo (@"清除所有测试结果");
                             //从数据库中删除
                             [_db executeUpdate:@"delete from SVSummaryResultModel;"];

                             //从数据库中删除
                             [_db executeUpdate:@"delete from SVDetailResultModel;"];
                             [self readDataFromDB:_type order:_order];
                           }];

    [alert addAction:noAction];
    [alert addAction:yesAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
