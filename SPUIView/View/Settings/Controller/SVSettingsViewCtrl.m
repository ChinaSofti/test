//
//  SVSettingsViewCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVAboutViewCtrl.h"
#import "SVAdvancedViewCtrl.h"
#import "SVBWSettingViewCtrl.h"
#import "SVFAQViewCtrl.h"
#import "SVLanguageSettingViewCtrl.h"
#import "SVLogsViewCtrl.h"
#import "SVSettingsViewCtrl.h"
#import "SVUploadFile.h"

@interface SVSettingsViewCtrl () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *grey;
@property (nonatomic, strong) UIWindow *window;
@end

@implementation SVSettingsViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    SVInfo (@"SVSettingsView");

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
    // 6.设置tableView不可上下拖动
    _tableView.bounces = NO;
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
        return 6;
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
    NSString *title1 = I18N (@"Current:");
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSString *title2 = probeInfo.isp;
    NSString *title21 = I18N (@"Share");
    NSString *title3 = I18N (@"About");
    NSString *title31 = I18N (@"FAQ");
    NSString *title4 = I18N (@"Language Setting");
    NSString *title5 = I18N (@"Upload Logs");
    NSString *title6 = I18N (@"Advanced setting");
    NSString *title7 = I18N (@"WIFI");

    static NSString *cellId = @"cell";

    UITableViewCell *cell =
    [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];

    //取消cell 被点中的效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //设置每个cell的内容
    if (indexPath.section == 0)
    {

        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        if (indexPath.row == 0)
        {
            UIImage *image1 = [UIImage imageNamed:@"ic_settings_wifi"];
            UIImageView *imageView1 = [[UIImageView alloc] initWithImage:image1];
            imageView1.frame = CGRectMake (10, 10, 60, 60);
            [cell addSubview:imageView1];

            UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake (100, 15, 70, 20)];
            label11.text = title1;
            //设置字体和是否加粗
            label11.font = [UIFont systemFontOfSize:16];
            [cell addSubview:label11];

            UILabel *label111 = [[UILabel alloc] initWithFrame:CGRectMake (170, 15, 50, 20)];
            label111.text = title7;
            //设置字体和是否加粗
            label111.font = [UIFont systemFontOfSize:16];
            [cell addSubview:label111];

            UILabel *label22 = [[UILabel alloc] initWithFrame:CGRectMake (100, 45, 160, 20)];
            label22.text = title2;
            label22.font = [UIFont systemFontOfSize:13];
            [cell addSubview:label22];
        }
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        ;

        if (indexPath.row == 0)
        {
            cell.textLabel.text = title21;
            //添加分享的点击事件
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, 40)];
            //                        button.backgroundColor = [UIColor redColor];
            [button addTarget:self
                       action:@selector (ShareClicked:)
             forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
        }
        if (indexPath.row == 1)
        {
            cell.textLabel.text = title3;
        }
        if (indexPath.row == 2)
        {
            cell.textLabel.text = title31;
        }
        if (indexPath.row == 3)
        {
            cell.textLabel.text = title4;
        }
        if (indexPath.row == 4)
        {
            cell.textLabel.text = title5;

            //添加上传日志的点击事件
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, 40)];
            //            button.backgroundColor = [UIColor redColor];
            [button addTarget:self
                       action:@selector (UploadClicked:)
             forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
        }
        if (indexPath.row == 5)
        {
            cell.textLabel.text = title6;
        }
    }
    return cell;
}
//分享的点击事件
- (void)ShareClicked:(UIButton *)button

{
    NSString *title8 = I18N (@"Share on");
    NSString *title9 = I18N (@"Cancel");
    NSString *title10 = I18N (@"WeChat");
    NSString *title11 = I18N (@"WeChat Friend Circle");

    //添加覆盖grayview
    //获取整个屏幕的window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //    // 0.开始动画
    //    [UIView beginAnimations:nil context:nil];
    //    // 0.1设置动画时间
    //    [UIView setAnimationDuration:6.0];
    //创建一个覆盖garyView

    _grey = [[UIView alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    _grey.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    //创建一个分享到sharetoview
    UIView *sharetoview = [[UIView alloc]
    initWithFrame:CGRectMake (0, kScreenH - FITTHEIGHT (200), kScreenW, FITTHEIGHT (200))];
    sharetoview.backgroundColor = [UIColor whiteColor];
    //创建一个分享到label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH / 10)];
    //    label.centerX = sharetoview.centerX;
    //    label.centerY = sharetoview.centerY/2;
    //    label.width = sharetoview.width/4;
    //    label.height = sharetoview.height/4;
    //    label.backgroundColor = [UIColor redColor];
    label.text = title8;
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    //创建一个显示取消的label2
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake (0, 15, kScreenW, kScreenH / 2)];
    label2.text = title9;
    label2.font = [UIFont systemFontOfSize:15];
    label2.textColor = [UIColor colorWithRed:0.179 green:0.625 blue:1.000 alpha:1.000];
    label2.textAlignment = NSTextAlignmentCenter;
    //创建2个分享按钮
    UIButton *button1 = [[UIButton alloc]
    initWithFrame:CGRectMake (kScreenW / 2 - FITTHEIGHT (80) - 35, kScreenH - FITTHEIGHT (140), 70, 70)];
    [button1 setImage:[UIImage imageNamed:@"share_to_wechat"] forState:UIControlStateNormal];
    [button1 addTarget:self
                action:@selector (Button1Click)
      forControlEvents:UIControlEventTouchUpInside];
    UIButton *button2 = [[UIButton alloc]
    initWithFrame:CGRectMake (kScreenW / 2 - 35 + FITTHEIGHT (80), kScreenH - FITTHEIGHT (140), 70, 70)];
    [button2 setImage:[UIImage imageNamed:@"share_to_wechatmoments"] forState:UIControlStateNormal];
    [button2 addTarget:self
                action:@selector (Button2Click)
      forControlEvents:UIControlEventTouchUpInside];
    //添加2个label
    //创建一个显示微信的label3
    UILabel *label3 = [[UILabel alloc]
    initWithFrame:CGRectMake (kScreenW / 2 - FITTHEIGHT (90) - 40, kScreenH / 10 + FITTHEIGHT (70), 100, 20)];
    label3.text = title10;
    label3.font = [UIFont systemFontOfSize:15];
    label3.textColor = [UIColor lightGrayColor];
    label3.textAlignment = NSTextAlignmentCenter;
    //创建一个显示微信朋友圈的label4
    UILabel *label4 = [[UILabel alloc]
    initWithFrame:CGRectMake (kScreenW / 2 - 35 + FITTHEIGHT (40), kScreenH / 10 + FITTHEIGHT (70), 150, 20)];
    label4.text = title11;
//    label4.backgroundColor = [UIColor redColor];
    label4.font = [UIFont systemFontOfSize:15];
    label4.textColor = [UIColor lightGrayColor];
    label4.textAlignment = NSTextAlignmentCenter;

    //创建取消button
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    [button3 addTarget:self
                action:@selector (Button3Click)
      forControlEvents:UIControlEventTouchUpInside];


    //添加
    [sharetoview addSubview:label];
    [sharetoview addSubview:label2];
    [sharetoview addSubview:label3];
    [sharetoview addSubview:label4];
    [_grey addSubview:sharetoview];
    [window addSubview:_grey];
    [_grey addSubview:button3];
    [_grey addSubview:button1];
    [_grey addSubview:button2];
    //    // 0.2提交动画
    //    [UIView commitAnimations];
}
//微信群组的分享方法实现
- (void)Button1Click
{
}
//微信朋友圈的分享方法实现
- (void)Button2Click
{
}
//取消方法实现
- (void)Button3Click
{
    NSLog (@"取消");
    [_grey removeFromSuperview];
}
//上传日志按钮的点击事件
- (void)UploadClicked:(UIButton *)button

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
        @try
        {
            //上传日志
            SVInfo (@"开始上传日志");
            SVLog *log = [SVLog alloc];
            NSString *filePath = [log compressLogFiles];
            SVInfo (@"upload log file:%@", filePath);

            SVUploadFile *upload = [[SVUploadFile alloc] init];
            NSString *urlString =
            @"https://58.60.106.188:12210/speedpro/log?op=list&begin=0&end=50";
            [upload uploadFileWithURL:[NSURL URLWithString:urlString] filePath:filePath];
        }
        @catch (NSException *exception)
        {
            //上传失败
            SVError (@"上传失败. %@", exception);
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title0 = I18N (@"Bandwidth Settings");
    NSString *title3 = I18N (@"About");
    NSString *title31 = I18N (@"FAQ");
    NSString *title4 = I18N (@"Language Setting");
    NSString *title5 = I18N (@"Upload Logs");
    NSString *title6 = I18N (@"Advanced");
    //当前连接
    if (indexPath.section == 0)
    {
        SVBWSettingViewCtrl *bandwidthSetting = [[SVBWSettingViewCtrl alloc] init];
        bandwidthSetting.title = title0;
        [self.navigationController pushViewController:bandwidthSetting animated:YES];
    }

    if (indexPath.section == 1)
    {
        //分享
        if (indexPath.row == 0)
        {
            //            UIView *share = [[UIView alloc] init];
        }
        //关于
        if (indexPath.row == 1)
        {
            SVAboutViewCtrl *about = [[SVAboutViewCtrl alloc] init];
            about.title = title3;
            [self.navigationController pushViewController:about animated:YES];
        }
        // FAQ
        if (indexPath.row == 2)
        {
            SVFAQViewCtrl *FAQ = [[SVFAQViewCtrl alloc] init];
            FAQ.title = title31;
            [self.navigationController pushViewController:FAQ animated:YES];
        }
        //语言设置
        if (indexPath.row == 3)
        {
            SVLanguageSettingViewCtrl *languageSetting = [[SVLanguageSettingViewCtrl alloc] init];
            languageSetting.title = title4;
            [self.navigationController pushViewController:languageSetting animated:YES];
        }
        //上传日志
        if (indexPath.row == 4)
        {
            SVLogsViewCtrl *logs = [[SVLogsViewCtrl alloc] init];
            logs.title = title5;
        }
        //高级设置
        if (indexPath.row == 5)
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
    return 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
