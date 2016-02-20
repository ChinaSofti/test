//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVSettingsViewCtrl.h"

#import "SVAboutViewCtrl.h"
#import "SVAdvancedViewCtrl.h"
#import "SVBWSettingViewCtrl.h"
#import "SVLanguageSettingViewCtrl.h"
#import "SVLogsViewCtrl.h"
#import <SPCommon/SVI18N.h>

@interface SVSettingsViewCtrl () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SVSettingsViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog (@"SVSettingsView");

    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];

    //电池显示不了,设置样式让电池显示
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //编辑界面
    //一.创建一个 tableView
    // 1.style:Grouped化合的,分组的
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake (10, 0, kScreenW - 20, kScreenH - 50)
                                              style:UITableViewStyleGrouped];
    // 2.设置背景颜色
    //    _tableView.backgroundColor = [UIColor whiteColor];
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
    //三.添加
    // 7.把tableView添加到 view
    [self.view addSubview:_tableView];
    //    //在cell的imageview上加一圈白环
    //    [self addView];
}

//- (void)addView
//{
//    UIView *imageView = [[UIView alloc] init];
//    imageView.frame = CGRectMake (23.5, 84.5, 87.5, 79);
//    imageView.layer.borderWidth = 10;
//    imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    imageView.layer.masksToBounds = YES;
//    imageView.layer.cornerRadius = 40;
//
//    [self.view addSubview:imageView];
//}


//方法:
//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//设置 tableView的 numberOfRowsInSection(设置每个section中有几个cell)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
        return 4;
}

// 设置 tableView 的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 80;
    }
    else
        return 40;
}

//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title1 = I18N (@"Current connection");
    NSString *title2 = I18N (@"China Unicom Beijing");
    NSString *title3 = I18N (@"About");
    NSString *title4 = I18N (@"Language Setting");
    NSString *title5 = I18N (@"Upload Logs");
    NSString *title6 = I18N (@"Advanced setting");


    static NSString *cellId = @"cell";

    UITableViewCell *cell =
    [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];

    //取消cell 被点中的效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    // 设置cell的textLabel
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];


    //设置每个cell的内容
    if (indexPath.section == 0)
    {

        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        if (indexPath.row == 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"ic_settings_wifi"];
            cell.textLabel.text = title1;
            cell.detailTextLabel.text = title2;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
            [cell.detailTextLabel setNumberOfLines:0];
        }
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        if (indexPath.row == 0)
        {
            cell.textLabel.text = title3;
        }
        if (indexPath.row == 1)
        {
            cell.textLabel.text = title4;
        }
        if (indexPath.row == 2)
        {
            cell.textLabel.text = title5;

            //添加上传日志的点击事件
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, 40)];
            //            button.backgroundColor = [UIColor redColor];
            [button addTarget:self
                       action:@selector (removeButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
        }
        if (indexPath.row == 3)
        {
            cell.textLabel.text = title6;
        }
    }
    return cell;
}
//上传日志按钮的点击事件
- (void)removeButtonClicked:(UIButton *)button

{
    NSString *title1 = I18N (@"Upload Logs");
    NSString *title2 = I18N (@"Are you sure Upload logs");
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
        //如果点击上传怎样,写在这里
        /*


         雨哥加代码处


         */
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title0 = I18N (@"Bandwidth Settings");
    NSString *title3 = I18N (@"About");
    NSString *title4 = I18N (@"Language Setting");
    NSString *title5 = I18N (@"Upload logs");
    NSString *title6 = I18N (@"Advanced setting");
    //当前连接
    if (indexPath.section == 0)
    {
        SVBWSettingViewCtrl *bandwidthSetting = [[SVBWSettingViewCtrl alloc] init];
        bandwidthSetting.title = title0;
        [self.navigationController pushViewController:bandwidthSetting animated:YES];
    }

    if (indexPath.section == 1)
    {
        //关于
        if (indexPath.row == 0)
        {
            SVAboutViewCtrl *about = [[SVAboutViewCtrl alloc] init];
            about.title = title3;
            [self.navigationController pushViewController:about animated:YES];
        }
        //语言设置
        if (indexPath.row == 1)
        {
            SVLanguageSettingViewCtrl *languageSetting = [[SVLanguageSettingViewCtrl alloc] init];
            languageSetting.title = title4;
            [self.navigationController pushViewController:languageSetting animated:YES];
        }
        //上传日志
        if (indexPath.row == 2)
        {
            SVLogsViewCtrl *logs = [[SVLogsViewCtrl alloc] init];
            logs.title = title5;
        }
        //高级设置
        if (indexPath.row == 3)
        {
            SVAdvancedViewCtrl *advanced = [[SVAdvancedViewCtrl alloc] init];
            advanced.title = title6;
            [self.navigationController pushViewController:advanced animated:YES];
        }
    }
}


//设置 tableView 的 sectionHeader蓝色 的header的有无
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view =
    [[UIView alloc] initWithFrame:CGRectMake (0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    //        view.backgroundColor = [UIColor blueColor];
    view.alpha = 0.5;

    return view;
}
//设置tableView的 sectionFooter黑色 的Footer的有无
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view =
    [[UIView alloc] initWithFrame:CGRectMake (0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    //    view.backgroundColor = [UIColor blackColor];
    return view;
}

//设置 tableView的section 的Header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 20;
    }
    else
        return 10;
}
//设置 tableView的section 的Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 4)
    {
        //添加按钮:开始测试
        //创建一个switch并添加
        UISwitch *abcd = [[UISwitch alloc] initWithFrame:CGRectMake (265, 6, 0, 0)];
        //改变switch的位置
        //                abcd = [[UISwitch alloc]initWithFrame:CGRectMakeF(265,
        //                6, 0, 0)];
        //改变switch的状态
        abcd.on = YES;
        //添加
        //        [cell.contentView addSubview:abcd];
        return 10;
    }
    else
        return 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
