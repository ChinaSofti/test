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
}

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
        return 3;
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
//调整cell中线条的长度
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
//forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
//    {
//        [cell setLayoutMargins:UIEdgeInsetsMake(0, -50, 0, 0)];
//
//    }
////    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
////    {
//////    [cell setLayoutMargins:UIEdgeInsetsMake(0, -20, 0, 20)];
////    //[cell setLayoutMargins:UIEdgeInsetsMake(0, 100, 0, 0)];
////    }
//}
//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            cell.textLabel.text = @"当前连接:WIFI";
            cell.detailTextLabel.text =
            @"\n所属运营商中国联通 北京市， 带宽类型未知， 带宽套餐未知";
            cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
            [cell.detailTextLabel setNumberOfLines:0];
        }
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        //        if (indexPath.row == 0)
        //        {
        //            cell.textLabel.text = @"版本升级";
        //        }
        //        if (indexPath.row == 1)
        //        {
        //            cell.textLabel.text = @"分享";
        //        }
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"关于";
            //   cell.frame = CGRectMake(10, 0, kScreenW-20, 40);
        }
        //        if (indexPath.row == 3)
        //        {
        //            cell.textLabel.text = @"FAQ";
        //        }
        if (indexPath.row == 1)
        {
            cell.textLabel.text = @"语言设置";
        }
        //        if (indexPath.row == 5)
        //        {
        //            cell.textLabel.text = @"上传日志";
        //        }
        if (indexPath.row == 2)
        {
            cell.textLabel.text = @"高级设置";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //当前连接
    if (indexPath.section == 0)
    {
        SVBWSettingViewCtrl *bandwidthSetting = [[SVBWSettingViewCtrl alloc] init];
        bandwidthSetting.title = @"带宽设置";
        [self.navigationController pushViewController:bandwidthSetting animated:YES];
    }

    if (indexPath.section == 1)
    {
        //关于
        if (indexPath.row == 0)
        {
            SVAboutViewCtrl *about = [[SVAboutViewCtrl alloc] init];
            about.title = @"关于";
            [self.navigationController pushViewController:about animated:YES];
        }
        //语言设置
        if (indexPath.row == 1)
        {
            SVLanguageSettingViewCtrl *languageSetting = [[SVLanguageSettingViewCtrl alloc] init];
            languageSetting.title = @"语言设置";
            [self.navigationController pushViewController:languageSetting animated:YES];
        }
        //高级设置
        if (indexPath.row == 2)
        {
            SVAdvancedViewCtrl *advanced = [[SVAdvancedViewCtrl alloc] init];
            advanced.title = @"高级设置";
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
