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
#import <SPCommon/SVRealReachability.h>
#import <SPService/SVIPAndISPGetter.h>
//微信分享
#import "WXApi.h"
//上传日志提示
#import "SVToast.h"

@interface SVSettingsViewCtrl () <UITableViewDelegate, UITableViewDataSource, SVRealReachabilityDelegate, WXApiDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *grey;
@property (nonatomic, strong) UIWindow *window;
@end

@implementation SVSettingsViewCtrl

{
    UITableViewCell *_photocell;
    UIImageView *_imageView;
    UILabel *_label;
}
static NSString *kLinkURL = @"http://58.60.106.185:12210";
static NSString *kLinkTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
static NSString *kLinkTitle = @"SpeedPro";
static NSString *kLinkDescription = @"福利来了,大家注意了";
- (void)networkStatusChange:(SVRealReachabilityStatus)status
{
    if (_imageView)
    {
        [_imageView removeFromSuperview];
    }
    if (_label)
    {
        [_label removeFromSuperview];
    }

    if (status == SV_RealStatusViaWiFi)
    {
        UIImage *image1 = [UIImage imageNamed:@"ic_settings_wifi"];
        _imageView = [[UIImageView alloc] initWithImage:image1];
        _imageView.frame = CGRectMake (10, 10, 60, 60);
        [_photocell addSubview:_imageView];

        _label = [[UILabel alloc] initWithFrame:CGRectMake (170, 15, 50, 20)];
        _label.font = [UIFont systemFontOfSize:16];
        _label.text = @"WiFi";
        [_photocell addSubview:_label];
    }
    else
    {
        UIImage *image2 = [UIImage imageNamed:@"ic_settings_mobile"];
        _imageView = [[UIImageView alloc] initWithImage:image2];
        _imageView.frame = CGRectMake (10, 10, 60, 60);
        [_photocell addSubview:_imageView];

        NSString *title7 = I18N (@"Mobile network");
        _label = [[UILabel alloc] initWithFrame:CGRectMake (170, 15, 50, 20)];
        _label.font = [UIFont systemFontOfSize:16];
        _label.text = title7;
        [_photocell addSubview:_label];
    }
}
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
        return 5;
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
    SVIPAndISP *ipAndISP = [SVIPAndISPGetter getIPAndISP];
    NSString *title2 = ipAndISP.isp;
    NSString *title21 = I18N (@"Share");
    NSString *title3 = I18N (@"About");
    //    NSString *title31 = I18N (@"FAQ");
    NSString *title4 = I18N (@"Language Setting");
    NSString *title5 = I18N (@"Upload Logs");
    NSString *title6 = I18N (@"Advanced setting");

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

            _photocell = cell;

            UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake (100, 15, 70, 20)];
            label11.text = title1;
            //设置字体和是否加粗
            label11.font = [UIFont systemFontOfSize:16];
            [cell addSubview:label11];

            UILabel *label111 = [[UILabel alloc] initWithFrame:CGRectMake (170, 15, 50, 20)];
            //设置字体和是否加粗
            label111.font = [UIFont systemFontOfSize:16];
            label111.text = @"WiFi";
            [cell addSubview:label111];
            _photocell = cell;

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
        //        if (indexPath.row == 2)
        //        {
        //            cell.textLabel.text = title31;
        //        }
        if (indexPath.row == 2)
        {
            cell.textLabel.text = title4;
        }
        if (indexPath.row == 3)
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
        if (indexPath.row == 4)
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
    initWithFrame:CGRectMake (kScreenW / 2 - FITTHEIGHT (90) - 15, kScreenH / 10 + FITTHEIGHT (70), 50, 20)];
    label3.text = title10;
    label3.font = [UIFont systemFontOfSize:15];
    label3.textColor = [UIColor lightGrayColor];
    label3.textAlignment = NSTextAlignmentCenter;
    //创建一个显示微信朋友圈的label4
    UILabel *label4 = [[UILabel alloc]
    initWithFrame:CGRectMake (kScreenW / 2 - 35 + FITTHEIGHT (40), kScreenH / 10 + FITTHEIGHT (70), 130, 20)];
    label4.text = title11;
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
    //创建发送对象实例
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO; //不使用文本信息
    sendReq.scene = 0; // 0 = 好友列表 1 = 朋友圈 2 = 收藏

    //创建分享内容对象
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    urlMessage.title = kLinkTitle; //分享标题
    urlMessage.description = kLinkDescription; //分享描述
    [urlMessage setThumbImage:[UIImage imageNamed:@"testImg"]]; //分享图片,使用SDK的setThumbImage方法可压缩图片大小

    //创建多媒体对象
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = kLinkURL; //分享链接

    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;

    //发送分享信息
    [WXApi sendReq:sendReq];
}
//微信朋友圈的分享方法实现
- (void)Button2Click
{
    //创建发送对象实例
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO; //不使用文本信息
    sendReq.scene = 1; // 0 = 好友列表 1 = 朋友圈 2 = 收藏

    //创建分享内容对象
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    urlMessage.title = kLinkTitle; //分享标题
    urlMessage.description = kLinkDescription; //分享描述
    [urlMessage setThumbImage:[UIImage imageNamed:@"testImg"]]; //分享图片,使用SDK的setThumbImage方法可压缩图片大小

    //创建多媒体对象
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = kLinkURL; //分享链接

    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;

    //发送分享信息
    [WXApi sendReq:sendReq];
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
        //上传日志
        SVInfo (@"开始上传日志");
        [self performSelector:@selector (delayMethod1) withObject:nil afterDelay:0.5f];
        [self performSelector:@selector (delayMethod) withObject:nil afterDelay:5.0f];
    }
}
- (void)delayMethod1
{
    NSString *title1 = I18N (@"Uploading");
    [SVToast showWithText:title1];
}
//上传成功与失败判断
- (void)delayMethod
{
    NSString *title2 = I18N (@"Upload Success");
    NSString *title3 = I18N (@"Upload Failed");
    @try
    {
        SVLog *log = [SVLog alloc];
        NSString *filePath = [log compressLogFiles];
        SVInfo (@"upload log file:%@", filePath);
        SVUploadFile *upload = [[SVUploadFile alloc] init];
        NSString *urlString = @"https://58.60.106.188:12210/speedpro/log?op=list&begin=0&end=50";
        [upload uploadFileWithURL:[NSURL URLWithString:urlString] filePath:filePath];
        [SVToast showWithText:title2];
    }
    @catch (NSException *exception)
    {
        SVError (@"上传失败. %@", exception);
        [SVToast showWithText:title3];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title0 = I18N (@"Bandwidth Settings");
    NSString *title3 = I18N (@"About");
    //    NSString *title31 = I18N (@"FAQ");
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
        //        // FAQ
        //        if (indexPath.row == 2)
        //        {
        //            SVFAQViewCtrl *FAQ = [[SVFAQViewCtrl alloc] init];
        //            FAQ.title = title31;
        //            [self.navigationController pushViewController:FAQ animated:YES];
        //        }
        //语言设置
        if (indexPath.row == 2)
        {
            SVLanguageSettingViewCtrl *languageSetting = [[SVLanguageSettingViewCtrl alloc] init];
            languageSetting.title = title4;
            [self.navigationController pushViewController:languageSetting animated:YES];
        }
        //上传日志
        if (indexPath.row == 3)
        {
            SVLogsViewCtrl *logs = [[SVLogsViewCtrl alloc] init];
            logs.title = title5;
        }
        //高级设置
        if (indexPath.row == 4)
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
