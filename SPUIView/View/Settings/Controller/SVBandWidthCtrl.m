//
//  SVBandWidthCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/3/4.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#import "SVBandWidthCtrl.h"
#import "SVGetDistance.h"
#import "SVIPAndISPGetter.h"
#import "SVSpeedTestServers.h"

@interface SVBandWidthCtrl () <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>
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
    SVInfo (@"SVBandWidthCtrl");
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];

    // 初始化返回按钮
    [super initBackButtonWithTarget:self action:@selector (backButtonClick)];

    //一.创建一个 tableView,style:Grouped化合的,分组的
    _tableView = [self
    createTableViewWithRect:CGRectMake (FITWIDTH (29), FITHEIGHT (0), kScreenW - FITHEIGHT (48), kScreenH)
                  WithStyle:UITableViewStyleGrouped
                  WithColor:[UIColor colorWithHexString:@"#fafafa"]
               WithDelegate:self
             WithDataSource:self];

    // 把tableView添加到 view
    [self.view addSubview:_tableView];

    _ipAndISP = [SVIPAndISPGetter getIPAndISP];
}
//进去时 隐藏tabBar
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    _array = [servers getAllServer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabBar" object:nil];
}
//出来时 显示tabBar
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabBar" object:nil];
}
#pragma mark - tableview代理方法
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
    return FITHEIGHT (143);
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
        initWithFrame:CGRectMake (FITWIDTH (14), FITHEIGHT (14), FITWIDTH (434), FITHEIGHT (58))];
        label1.text = server.name;
        //设置字体和是否加粗
        label1.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
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
        initWithFrame:CGRectMake (FITWIDTH (843), FITHEIGHT (24), FITWIDTH (153), FITHEIGHT (58))];
        //        label2.backgroundColor = [UIColor redColor];
        label2.text = [NSString stringWithFormat:@"%.2f", distance];
        //设置字体和是否加粗
        label2.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
        label2.textAlignment = NSTextAlignmentRight;
        [cell addSubview:label2];

        UILabel *label3 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (14), FITHEIGHT (72), FITWIDTH (216), FITHEIGHT (58))];
        label3.text = @"Hosted by:";
        label3.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
        [cell addSubview:label3];

        UILabel *label4 = [[UILabel alloc]
        initWithFrame:CGRectMake (label3.rightX, FITHEIGHT (72), FITWIDTH (692), FITHEIGHT (58))];
        label4.text = server.sponsor;
        label4.font = [UIFont systemFontOfSize:pixelToFontsize (36)];
        [cell addSubview:label4];

        UILabel *label5 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (958), FITHEIGHT (72), FITWIDTH (58), FITHEIGHT (58))];
        label5.text = @"km";
        label5.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
        [cell addSubview:label5];
        //添加点击事件
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, FITHEIGHT (143))];
        [button addTarget:self
                   action:@selector (CellClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    }
    return cell;
}

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return FITHEIGHT (58);
    }
    return FITHEIGHT (9);
}
//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
#pragma mark - 点击事件
- (void)CellClicked:(UIButton *)button
{
    //获取section的点击第几个section
    UITableViewCell *cell = (UITableViewCell *)[button superview]; //获取cell
    NSIndexPath *indexPathAll = [_tableView indexPathForCell:cell]; //获取cell对应的section
    SVSpeedTestServer *server = [_array objectAtIndex:indexPathAll.section];
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    [servers setDefaultServer:server];
    [servers setAuto:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
//返回按钮
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
