//
//  SVBandWidthCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/3/4.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#import "SVBandWidthCtrl.h"
#import "SVGetDistance.h"
#import <SPService/SVSpeedTestServers.h>

@interface SVBandWidthCtrl () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    //列表内容数组
    NSArray *_array;
    SVIPAndISP *_ipAndISP;
}
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SVBandWidthCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //设置LeftBarButtonItem
    [self createLeftBarButtonItem];
    SVInfo (@"SVBandWidthCtrl");

    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];

    //电池显示不了,设置样式让电池显示
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //编辑界面
    //一.创建一个 tableView
    // 1.style:Grouped化合的,分组的
    _tableView = [[UITableView alloc]
    initWithFrame:CGRectMake (FITTHEIGHT (10), FITTHEIGHT (0), kScreenW - FITTHEIGHT (20), kScreenH)
            style:UITableViewStyleGrouped];
    // 2.设置背景颜色
    _tableView.backgroundColor =
    [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1];
    // 3.设置 table 的行高
    //    _tableView.rowHeight = 50;
    //*4.设置代理
    _tableView.delegate = self;
    //*5.设置数据源
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    //    _tableView.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
    // 6.设置tableView不可上下拖动
    _tableView.bounces = NO;
    //三.添加
    // 7.把tableView添加到 view
    [self.view addSubview:_tableView];

    _ipAndISP = [SVIPAndISPGetter getIPAndISP];
}

//方法:
//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _array.count;
}
//设置 tableView的 numberOfRowsInSection(设置每个section中有几个cell)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// 设置 tableView 的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FITTHEIGHT (50);
}

//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellId = @"cell";

    UITableViewCell *cell =
    [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];

    //取消cell 被点中的效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //取数组里的值
    SVSpeedTestServer *server = _array[indexPath.section];
    //设置每个cell的内容
    if (indexPath.row == 0)
    {
        UILabel *label1 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITTHEIGHT (5), FITTHEIGHT (5), FITTHEIGHT (150), FITTHEIGHT (20))];
        label1.text = server.name;
        //设置字体和是否加粗
        label1.font = [UIFont systemFontOfSize:14];
        [cell addSubview:label1];

        double distance = 0.0;
        if (_ipAndISP)
        {
            if (_ipAndISP.lat && _ipAndISP.lon)
            {
                double lat1 = [_ipAndISP.lat doubleValue];
                double lon1 = [_ipAndISP.lon doubleValue];
                double lat2 = server.lat;
                double lon2 = server.lon;
                distance = [SVGetDistance getDistance:lat1 lon:lon1 lat2:lat2 lon2:lon2];
            }
        }


        UILabel *label2 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITTHEIGHT (285), FITTHEIGHT (8), FITTHEIGHT (50), FITTHEIGHT (20))];
        label2.text = [NSString stringWithFormat:@"%.2f", distance];
        //设置字体和是否加粗
        label2.font = [UIFont systemFontOfSize:14];
        label2.textAlignment = NSTextAlignmentRight;
        [cell addSubview:label2];

        UILabel *label3 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITTHEIGHT (5), FITTHEIGHT (25), FITTHEIGHT (75), FITTHEIGHT (20))];
        label3.text = @"Hosted by:";
        label3.font = [UIFont systemFontOfSize:11];
        [cell addSubview:label3];

        UILabel *label4 = [[UILabel alloc]
        initWithFrame:CGRectMake (label3.rightX, FITTHEIGHT (25), FITTHEIGHT (240), FITTHEIGHT (20))];
        label4.text = server.sponsor;
        label4.font = [UIFont systemFontOfSize:11];
        [cell addSubview:label4];

        UILabel *label5 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITTHEIGHT (320), FITTHEIGHT (25), FITTHEIGHT (20), FITTHEIGHT (20))];
        label5.text = @"km";
        label5.font = [UIFont systemFontOfSize:11];
        [cell addSubview:label5];
        //添加点击事件
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, FITTHEIGHT (50))];
        [button addTarget:self
                   action:@selector (CellClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    }
    return cell;
}
- (void)CellClicked:(UIButton *)button

{

    //获取section的点击第几个section
    UITableViewCell *cell = (UITableViewCell *)[button superview]; //获取cell
    NSIndexPath *indexPathAll = [_tableView indexPathForCell:cell]; //获取cell对应的section
    NSLog (@"indexPath:--------%@", indexPathAll);
    SVSpeedTestServer *server = [_array objectAtIndex:indexPathAll.section];
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    [servers setDefaultServer:server];
    [self.navigationController popViewControllerAnimated:YES];
}
//#pragma mark-- 实现UIActionSheetDelegate //- (void)actionSheet:(UIActionSheet *)actionSheet
// clickedButtonAtIndex:(NSInteger)buttonIndex { //}

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 20;
    }
    return 3;
}
//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 3;
}

//进去时 隐藏tabBar
- (void)viewWillAppear:(BOOL)animated
{
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    _array = [servers getAllServer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabBar" object:nil];
}
//出来时 显示tabBar
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabBar" object:nil];
}

- (void)createLeftBarButtonItem
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, 45, 23)];
    [button setImage:[UIImage imageNamed:@"homeindicator"] forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *back0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil
                                                                           action:nil];
    back0.width = -15;
    self.navigationItem.leftBarButtonItems = @[back0, backButton];
    [button addTarget:self
               action:@selector (leftBackButtonClick)
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)leftBackButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
