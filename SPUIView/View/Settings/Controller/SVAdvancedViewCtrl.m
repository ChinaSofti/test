//
//  SVAdvancedViewCtrl.m
//  SPUIView
//
//  Created by XYB on 16/2/16.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#import "SVAdvancedViewCtrl.h"
#import "SVBandWidthCtrl.h"
#import <SPService/SVProbeInfo.h>

@interface SVAdvancedViewCtrl () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation SVAdvancedViewCtrl
{
    UITextField *_textField;
    UIButton *_button;
    UIButton *_button2;
    NSString *_name;
    NSString *_sponsor;
    UILabel *_label1;
    UILabel *_label2;
    SVSpeedTestServer *_defaultvalue;
    UITableView *_tableView;
    //    UIButton *_buttonback;
    UIButton *_timebutton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];

    //设置LeftBarButtonItem
    [self createLeftBarButtonItem];
    [self createScreenSizeUI];
    [self createVideotimeUI];
}

//进去时 隐藏tabBar
- (void)viewWillAppear:(BOOL)animated
{
    //取点击的cell的值
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    SVSpeedTestServer *server = [servers getDefaultServer];
    _name = server.name;
    _sponsor = server.sponsor;
    [self createBandwidthUI];
    _button.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _button2.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    _label1.text = _name;
    _label2.text = _sponsor;
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
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    [probeInfo setScreenSize:[_textField.text floatValue]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createScreenSizeUI
{
    NSString *title1 = I18N (@"Screen Size:");
    NSString *title2 = I18N (@"Inch");
    // views
    UIView *views = [[UIView alloc] init];
    views.frame = CGRectMake (FITTHEIGHT (10), FITTHEIGHT (74), kScreenW - FITTHEIGHT (20), FITTHEIGHT (44));
    views.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:views];

    // label屏幕尺寸
    UILabel *lableScreenSize = [[UILabel alloc] init];
    lableScreenSize.frame = CGRectMake (10, 10, 100, 20);
    lableScreenSize.text = title1;
    lableScreenSize.font = [UIFont systemFontOfSize:14];
    [views addSubview:lableScreenSize];

    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    //文本框
    _textField = [[UITextField alloc] init];
    _textField.frame = CGRectMake (100, 10, kScreenW - 125, 20);
    _textField.text = probeInfo.getScreenSize;
    _textField.placeholder = I18N (@"Please enter the number of 13~100");
    _textField.font = [UIFont systemFontOfSize:14];
    //设置文本框类型
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    //输入键盘类型
    _textField.keyboardType = UIKeyboardTypeDecimalPad;
    [views addSubview:_textField];

    //单位(英寸)
    UILabel *lableInch = [[UILabel alloc] init];
    lableInch.frame = CGRectMake (kScreenW - 55, 10, 30, 20);
    lableInch.text = title2;
    lableInch.font = [UIFont systemFontOfSize:14];
    [views addSubview:lableInch];
}
- (void)createVideotimeUI
{
    NSString *title3 = I18N (@"Video Test Duration:");
    // views
    UIView *views = [[UIView alloc] init];
    views.frame = CGRectMake (FITTHEIGHT (10), FITTHEIGHT (74) + FITTHEIGHT (50),
                              kScreenW - FITTHEIGHT (20), FITTHEIGHT (44));
    views.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:views];

    // label屏幕尺寸
    UILabel *lableScreenSize = [[UILabel alloc] init];
    lableScreenSize.frame = CGRectMake (10, 10, 130, 20);
    lableScreenSize.text = title3;
    lableScreenSize.font = [UIFont systemFontOfSize:14];
    [views addSubview:lableScreenSize];

    NSString *l = @"60s";
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    int videoPlayTime = [probeInfo getVideoPlayTime];
    if (videoPlayTime != 60)
    {
        l = [NSString stringWithFormat:@"%dmin", videoPlayTime / 60];
    }

    //按钮
    //初始化
    _timebutton = [[UIButton alloc] initWithFrame:CGRectMake (161, 8, kScreenW - 202, 28)];
    //设置文字
    [_timebutton setTitle:l forState:UIControlStateNormal];

    //文字颜色
    [_timebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //文字大小
    _timebutton.titleLabel.font = [UIFont systemFontOfSize:14];
    //按钮背景颜色
    [_timebutton setBackgroundImage:[CTWBViewTools imageWithColor:[UIColor lightGrayColor]
                                                             size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                           forState:UIControlStateHighlighted];
    [_timebutton setBackgroundImage:[CTWBViewTools imageWithColor:[UIColor whiteColor]
                                                             size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                           forState:UIControlStateNormal];
    _timebutton.layer.cornerRadius = 6;
    _timebutton.layer.masksToBounds = YES;
    [_timebutton addTarget:self
                    action:@selector (mybuttonClick:)
          forControlEvents:UIControlEventTouchUpInside];

    //按钮蓝框
    UIView *imageView2 = [[UIView alloc] initWithFrame:CGRectMake (160, 7, kScreenW - 200, 30)];
    imageView2.layer.borderWidth = 1;
    imageView2.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    imageView2.layer.masksToBounds = YES;
    imageView2.layer.cornerRadius = 5;
    [views addSubview:imageView2];
    [views addSubview:_timebutton];
}
- (void)createBandwidthUI
{

    NSString *title4 = I18N (@"Speed Test Server Config");
    NSString *title5 = I18N (@"auto");
    NSString *title6 = I18N (@"select");
    //获取默认值
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    SVSpeedTestServer *object = [servers getDefaultServer];
    //取数组里的值
    _defaultvalue = object;

    NSString *title1 = title4;
    // views3
    UIView *views3 = [[UIView alloc] init];
    views3.frame = CGRectMake (FITTHEIGHT (10), FITTHEIGHT (125) + FITWIDTH (44),
                               kScreenW - FITTHEIGHT (20), FITTHEIGHT (100));
    views3.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:views3];
    // label
    UILabel *lableScreenSize = [[UILabel alloc] init];
    lableScreenSize.frame = CGRectMake (FITTHEIGHT (10), FITTHEIGHT (10), FITTHEIGHT (200), FITTHEIGHT (20));
    lableScreenSize.text = title1;
    lableScreenSize.font = [UIFont systemFontOfSize:14];
    [views3 addSubview:lableScreenSize];
    // labelview
    UIView *labelview = [[UIView alloc]
    initWithFrame:CGRectMake (FITTHEIGHT (10), FITTHEIGHT (30), FITTHEIGHT (200), FITTHEIGHT (60))];
    //        labelview.backgroundColor = [UIColor yellowColor];
    labelview.layer.cornerRadius = 5;
    [views3 addSubview:labelview];
    // label1
    _label1 = [[UILabel alloc]
    initWithFrame:CGRectMake (FITTHEIGHT (10), FITTHEIGHT (10), FITTHEIGHT (200), FITTHEIGHT (20))];
    _label1.text = _defaultvalue.name;
    _label1.font = [UIFont systemFontOfSize:14];
    //        label1.backgroundColor = [UIColor redColor];
    _label1.layer.cornerRadius = 5;
    [labelview addSubview:_label1];
    // label2
    _label2 = [[UILabel alloc]
    initWithFrame:CGRectMake (FITTHEIGHT (10), FITTHEIGHT (40), FITTHEIGHT (215), FITTHEIGHT (20))];
    _label2.text = _defaultvalue.sponsor;
    _label2.font = [UIFont systemFontOfSize:11];
    //        label2.backgroundColor = [UIColor redColor];
    _label2.layer.cornerRadius = 5;
    [labelview addSubview:_label2];
    // button自动
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake (FITTHEIGHT (215), FITTHEIGHT (27), FITTHEIGHT (60), FITTHEIGHT (45));
    _button.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    //设置文字
    [_button setTitle:title5 forState:UIControlStateNormal];
    _button.titleLabel.font = [UIFont systemFontOfSize:15];
    _button.titleLabel.textAlignment = NSTextAlignmentCenter;
    _button.layer.cornerRadius = 5;
    [_button addTarget:self
                action:@selector (BtnClicked:)
      forControlEvents:UIControlEventTouchUpInside];
    [views3 addSubview:_button];
    // button选择
    _button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _button2.frame = CGRectMake (FITTHEIGHT (285), FITTHEIGHT (27), FITTHEIGHT (60), FITTHEIGHT (45));
    _button2.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [_button2 setTitle:title6 forState:UIControlStateNormal];
    _button2.titleLabel.font = [UIFont systemFontOfSize:15];
    _button2.titleLabel.textAlignment = NSTextAlignmentCenter;
    _button2.layer.cornerRadius = 5;
    [_button2 addTarget:self

                 action:@selector (Btn2Clicked:)
       forControlEvents:UIControlEventTouchUpInside];
    [views3 addSubview:_button2];
}
- (void)BtnClicked:(UIButton *)button
{
    SVInfo (@"自动");
    //自动获取方法(取数组里的第一个值)
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    NSArray *array = [servers getAllServer];
    if (array && array.count > 0)
    {
        SVSpeedTestServer *defaultvalue0 = array[0];
        _label1.text = defaultvalue0.name;
        _label2.text = defaultvalue0.sponsor;
        NSLog (@"%@", defaultvalue0.name);
        [servers setDefaultServer:defaultvalue0];
    }
    _button2.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _button.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
}
- (void)Btn2Clicked:(UIButton *)button2
{
    SVInfo (@"选择");
    //跳转到带宽测试服务器列表
    SVBandWidthCtrl *bandwidthCtrl = [[SVBandWidthCtrl alloc] init];
    bandwidthCtrl.title = I18N (@"Bandwidth test server configuration");
    [self.navigationController pushViewController:bandwidthCtrl animated:YES];
}
//视频时长下拉按钮
- (void)mybuttonClick:(UIButton *)btn
{
    SVInfo (@"视频时长下拉按钮");
    [self creattableView];
}

#pragma mark - 视频时长下拉按钮生成的tableview


//创建tableview
- (void)creattableView
{
    //编辑界面
    //一.创建一个 tableView
    // 1.style:Grouped化合的,分组的

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake (170, 163, kScreenW - 202, 240)
                                              style:UITableViewStyleGrouped];
    // 2.设置背景颜色
    _tableView.backgroundColor = [UIColor redColor];
    _tableView.backgroundColor =
    [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1];
    //*4.设置代理
    _tableView.delegate = self;
    //*5.设置数据源
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    // 6.设置tableView不可上下拖动
    _tableView.bounces = NO;
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    //三.添加
    // 7.把tableView添加到 view
    [self.view addSubview:_tableView];
}

//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//设置 tableView的 numberOfRowsInSection(设置每个section中有几个cell)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

// 设置 tableView 的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellId = @"cell";

    UITableViewCell *cell =
    [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];

    //    //取消cell 被点中的效果
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //设置每个cell的内容
    if (indexPath.section == 0)
    {

        if (indexPath.row == 0)
        {
            UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake (10, 15, 70, 20)];
            label11.text = @"60s";
            //设置字体和是否加粗
            label11.font = [UIFont systemFontOfSize:16];
            [cell addSubview:label11];
        }
        if (indexPath.row == 1)
        {
            UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake (10, 15, 70, 20)];
            label11.text = @"3min";
            //设置字体和是否加粗
            label11.font = [UIFont systemFontOfSize:16];
            [cell addSubview:label11];
        }
        if (indexPath.row == 2)
        {
            UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake (10, 15, 70, 20)];
            label11.text = @"5min";
            //设置字体和是否加粗
            label11.font = [UIFont systemFontOfSize:16];
            [cell addSubview:label11];
        }
        if (indexPath.row == 3)
        {
            UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake (10, 15, 70, 20)];
            label11.text = @"10min";
            //设置字体和是否加粗
            label11.font = [UIFont systemFontOfSize:16];
            [cell addSubview:label11];
        }
        if (indexPath.row == 4)
        {
            UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake (10, 15, 70, 20)];
            label11.text = @"30min";
            //设置字体和是否加粗
            label11.font = [UIFont systemFontOfSize:16];
            [cell addSubview:label11];
        }
    }
    return cell;
}

//点击cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [_timebutton setTitle:@"60s" forState:UIControlStateNormal];
            [probeInfo setVideoPlayTime:60];
            NSLog (@"1");
        }
        if (indexPath.row == 1)
        {
            NSLog (@"2");
            [_timebutton setTitle:@"3min" forState:UIControlStateNormal];
            [probeInfo setVideoPlayTime:180];
        }
        if (indexPath.row == 2)
        {
            NSLog (@"3");
            [_timebutton setTitle:@"5min" forState:UIControlStateNormal];
            [probeInfo setVideoPlayTime:300];
        }
        if (indexPath.row == 3)
        {
            NSLog (@"4");
            [_timebutton setTitle:@"10min" forState:UIControlStateNormal];
            [probeInfo setVideoPlayTime:600];
        }
        if (indexPath.row == 4)
        {
            NSLog (@"5");
            [_timebutton setTitle:@"30min" forState:UIControlStateNormal];
            [probeInfo setVideoPlayTime:1800];
        }
        [_tableView removeFromSuperview];
    }
}

//设置 tableView 的 sectionHeader蓝色 的header的有无
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return 0;
}
//设置tableView的 sectionFooter黑色 的Footer的有无
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return 0;
}

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
//#pragma mark - 创建视频下拉tableview的隐藏按钮
//- (void)creattableViewbackbutton
//{
//    _buttonback = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
//    _buttonback.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.0];
//    [_buttonback addTarget:self
//
//                    action:@selector (tableViewbackbutton:)
//          forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_buttonback];
//}
//- (void)tableViewbackbutton:(UIButton *)btn
//{
//    [_tableView removeFromSuperview];
//    [_buttonback removeFromSuperview];
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
