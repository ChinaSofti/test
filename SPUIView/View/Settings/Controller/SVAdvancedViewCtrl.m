//
//  SVAdvancedViewCtrl.m
//  SPUIView
//
//  Created by XYB on 16/2/16.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#import "SVAdvancedViewCtrl.h"
#import "SVBandWidthCtrl.h"
#import "SVProbeInfo.h"
#import "SVSpeedTestServers.h"
#import "SVSpeedTestServers.h"
#import "SVTextField.h"
#import "SVToast.h"

@interface SVAdvancedViewCtrl () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

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
    UITableView *_tableView2;
    UIButton *_buttonback;
    UIButton *_buttonback2;
    UIButton *_timebutton;
    UIButton *_timebutton2;

    // 播放时间数组
    NSArray *durationDic;

    // 视频清晰度数组
    NSArray *clarityDic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];

    // 初始化播放时间和清晰度
    durationDic = @[
        @{ @"1min": @"60" },
        @{ @"3min": @"180" },
        @{ @"5min": @"300" },
        @{ @"10min": @"600" },
        @{ @"30min": @"1800" }
    ];
    clarityDic = @[@"1080P", @"720P", @"480P"];

    // 初始化返回按钮
    [super initBackButtonWithTarget:self action:@selector (backButtonClick)];
    [self createScreenSizeUI];
    [self createVideotimeUI];
    [self createVideoQualityUI];
    [self createBandwidthUI];
    //    [self createResultUploadUI];
}

//进去时 隐藏tabBar
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //取点击的cell的值
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    SVSpeedTestServer *server = [servers getDefaultServer];
    _name = server.name;
    _sponsor = server.sponsor;

    if ([servers isAuto])
    {
        _button2.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _button.backgroundColor =
        [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    }
    else
    {
        _button.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _button2.backgroundColor =
        [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    }
    _label1.text = _name;
    _label2.text = _sponsor;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabBar" object:nil];
}
//出来时显示tabBar
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabBar" object:nil];
}

#pragma mark - 创建屏幕尺寸的UI界面
- (void)createScreenSizeUI
{
    // views
    UIView *views = [[UIView alloc] init];
    views.frame =
    CGRectMake (FITWIDTH (22), statusBarH + FITHEIGHT (192), kScreenW - FITHEIGHT (44), FITHEIGHT (130));
    views.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:views];

    // label屏幕尺寸
    UILabel *lableScreenSize = [[UILabel alloc] init];
    lableScreenSize.frame = CGRectMake (FITWIDTH (30), FITHEIGHT (36), FITWIDTH (488), FITHEIGHT (58));
    lableScreenSize.text = I18N (@"Screen Size:");
    lableScreenSize.textColor = [UIColor colorWithHexString:@"#CC000000"];
    lableScreenSize.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    [views addSubview:lableScreenSize];

    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];

    // 文本框
    _textField = [[SVTextField alloc] init];
    [_textField setDelegate:self];
    _textField.frame = CGRectMake (lableScreenSize.rightX, FITHEIGHT (36), FITWIDTH (488), FITHEIGHT (58));
    _textField.text = probeInfo.getScreenSize;
    _textField.placeholder = I18N (@"Please enter the number of 13~100");
    _textField.font = [UIFont systemFontOfSize:pixelToFontsize (42)];

    // 设置文本框类型
    _textField.borderStyle = UITextBorderStyleRoundedRect;

    // 输入键盘类型
    _textField.keyboardType = UIKeyboardTypeDecimalPad;
    [views addSubview:_textField];

    // 单位(英寸)
    UILabel *lableInch = [[UILabel alloc] init];
    lableInch.frame =
    CGRectMake (lableScreenSize.rightX + FITWIDTH (401), FITHEIGHT (36), FITWIDTH (87), FITHEIGHT (58));
    lableInch.text = I18N (@"inch");
    lableInch.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    lableInch.textColor = [UIColor colorWithHexString:@"#CC000000"];
    [views addSubview:lableInch];
}
// 退出键盘的方法
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![_textField isExclusiveTouch])
    {
        [_textField resignFirstResponder];
    }
}
#pragma mark - 创建视屏加载时长的UI界面
- (void)createVideotimeUI
{
    // views
    UIView *views = [[UIView alloc] init];
    views.frame =
    CGRectMake (FITWIDTH (22), statusBarH + FITHEIGHT (332), kScreenW - FITWIDTH (44), FITHEIGHT (130));
    views.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:views];

    // label视频时长
    UILabel *labelDuration = [[UILabel alloc] init];
    labelDuration.frame = CGRectMake (FITWIDTH (30), FITHEIGHT (36), FITWIDTH (488), FITHEIGHT (58));
    labelDuration.text = I18N (@"Video Test Duration:");
    labelDuration.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    labelDuration.textColor = [UIColor colorWithHexString:@"#CC000000"];
    [views addSubview:labelDuration];

    NSString *l = @"1min";
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    int videoPlayTime = [probeInfo getVideoPlayTime];
    if (videoPlayTime != 60)
    {
        l = [NSString stringWithFormat:@"%dmin", videoPlayTime / 60];
    }

    // 按钮
    // 初始化
    _timebutton = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, FITWIDTH (488), FITHEIGHT (82))];

    // 设置文字
    [_timebutton setTitle:l forState:UIControlStateNormal];

    // 文字颜色
    [_timebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    // 文字大小
    _timebutton.titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (42)];

    // 按钮背景颜色
    [_timebutton
    setBackgroundImage:[CTWBViewTools imageWithColor:[UIColor lightGrayColor]
                                                size:CGSizeMake (FITWIDTH (488), FITHEIGHT (104))]
              forState:UIControlStateHighlighted];
    [_timebutton
    setBackgroundImage:[CTWBViewTools imageWithColor:[UIColor whiteColor]
                                                size:CGSizeMake (FITWIDTH (488), FITHEIGHT (104))]
              forState:UIControlStateNormal];
    _timebutton.layer.cornerRadius = svCornerRadius (12);
    _timebutton.layer.masksToBounds = YES;
    [_timebutton addTarget:self
                    action:@selector (mybuttonClick:)
          forControlEvents:UIControlEventTouchUpInside];

    // 按钮框
    UIView *btnView = [[UIView alloc]
    initWithFrame:CGRectMake (labelDuration.rightX, FITHEIGHT (22), FITWIDTH (488), FITHEIGHT (82))];
    btnView.layer.borderWidth = 1;
    btnView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    btnView.layer.masksToBounds = YES;
    btnView.layer.cornerRadius = svCornerRadius (12);
    [btnView addSubview:_timebutton];
    [views addSubview:btnView];
}
//视频时长下拉按钮的点击事件
- (void)mybuttonClick:(UIButton *)btn
{
    [self creattableViewbackbutton];

    // 创建一个 tableView
    _tableView =
    [self createTableViewWithRect:CGRectMake (FITWIDTH (540), statusBarH + FITHEIGHT (462),
                                              FITWIDTH (488), FITHEIGHT (130) * durationDic.count)
                        WithStyle:UITableViewStylePlain
                        WithColor:[UIColor colorWithHexString:@"#FFFFFF"]
                     WithDelegate:self
                   WithDataSource:self];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [self.view addSubview:_tableView];
}

#pragma mark - 创建视频下拉tableview的隐藏按钮

- (void)creattableViewbackbutton
{
    _buttonback = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    _buttonback.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.0];
    [_buttonback addTarget:self

                    action:@selector (tableViewbackbutton:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonback];
}

// 返回按钮的点击事件
- (void)tableViewbackbutton:(UIButton *)btn
{
    [_tableView removeFromSuperview];
    [_buttonback removeFromSuperview];
}

#pragma mark - 创建视屏质量的UI界面
- (void)createVideoQualityUI
{
    // views
    UIView *views = [[UIView alloc] initWithFrame:CGRectMake (FITWIDTH (22), statusBarH + FITHEIGHT (472),
                                                              kScreenW - FITWIDTH (44), FITHEIGHT (130))];
    views.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:views];

    // label屏幕尺寸
    UILabel *lableVideoClarity = [[UILabel alloc] init];
    lableVideoClarity.frame = CGRectMake (FITWIDTH (30), FITHEIGHT (36), FITWIDTH (488), FITHEIGHT (58));
    lableVideoClarity.text = I18N (@"Video quality:");
    lableVideoClarity.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    lableVideoClarity.textColor = [UIColor colorWithHexString:@"#CC000000"];
    [views addSubview:lableVideoClarity];

    NSString *l = I18N (@"Auto");
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSString *videoClarity = [probeInfo getVideoClarity];
    if (![videoClarity isEqualToString:@"Auto"])
    {
        l = videoClarity;
    }

    // 按钮
    // 初始化
    _timebutton2 = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, FITWIDTH (488), FITHEIGHT (82))];

    // 设置文字
    [_timebutton2 setTitle:l forState:UIControlStateNormal];

    // 文字颜色
    [_timebutton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    // 文字大小
    _timebutton2.titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (42)];

    // 按钮背景颜色
    [_timebutton2
    setBackgroundImage:[CTWBViewTools imageWithColor:[UIColor lightGrayColor]
                                                size:CGSizeMake (FITWIDTH (488), FITHEIGHT (104))]
              forState:UIControlStateHighlighted];
    [_timebutton2
    setBackgroundImage:[CTWBViewTools imageWithColor:[UIColor whiteColor]
                                                size:CGSizeMake (FITWIDTH (488), FITHEIGHT (104))]
              forState:UIControlStateNormal];
    _timebutton2.layer.cornerRadius = svCornerRadius (12);
    _timebutton2.layer.masksToBounds = YES;
    [_timebutton2 addTarget:self
                     action:@selector (myQuabuttonClick:)
           forControlEvents:UIControlEventTouchUpInside];

    // 按钮框
    UIView *btnView = [[UIView alloc]
    initWithFrame:CGRectMake (lableVideoClarity.rightX, FITHEIGHT (22), FITWIDTH (488), FITHEIGHT (82))];
    btnView.layer.borderWidth = 1;
    btnView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    btnView.layer.masksToBounds = YES;
    btnView.layer.cornerRadius = svCornerRadius (12);
    [btnView addSubview:_timebutton2];
    [views addSubview:btnView];
}
//视频质量下拉按钮的点击事件
- (void)myQuabuttonClick:(UIButton *)btn
{
    SVInfo (@"视频时长下拉按钮");
    [self creatQuatableViewbackbutton];

    // 创建一个 tableView
    _tableView2 =
    [self createTableViewWithRect:CGRectMake (FITWIDTH (540), statusBarH + FITHEIGHT (602),
                                              FITWIDTH (488), FITHEIGHT (130) * clarityDic.count)
                        WithStyle:UITableViewStylePlain
                        WithColor:[UIColor colorWithHexString:@"#FFFFFF"]
                     WithDelegate:self
                   WithDataSource:self];
    _tableView2.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView2.separatorColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [self.view addSubview:_tableView2];
}

#pragma mark - 创建视频质量下拉tableview的隐藏按钮
- (void)creatQuatableViewbackbutton
{
    _buttonback2 = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    _buttonback2.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.0];
    [_buttonback2 addTarget:self

                     action:@selector (quatableViewbackbutton:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonback2];
}

// 返回按钮的点击事件
- (void)quatableViewbackbutton:(UIButton *)btn
{
    [_tableView2 removeFromSuperview];
    [_buttonback2 removeFromSuperview];
}

#pragma mark - tableview的代理方法
//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//设置 tableView的 numberOfRowsInSection(设置每个section中有几个cell)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
    {
        return durationDic.count;
    }
    else
    {
        return clarityDic.count;
    }
}

// 设置 tableView 的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FITHEIGHT (130);
}

//设置 tableView的 cellForRowIndexPath(设置每个cell内的具体内容)
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";

    UITableViewCell *cell =
    [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    if (tableView == _tableView)
    {
        //设置每个cell的内容
        if (indexPath.section == 0)
        {
            UILabel *label = [[UILabel alloc]
            initWithFrame:CGRectMake (FITWIDTH (30), FITHEIGHT (36), FITWIDTH (428), FITHEIGHT (58))];
            NSDictionary *dic = durationDic[indexPath.row];
            label.text = dic.allKeys[0];

            // 设置字体和是否加粗
            label.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
            [cell addSubview:label];
        }
    }
    else
    {
        // 设置每个cell的内容
        if (indexPath.section == 0)
        {
            UILabel *label = [[UILabel alloc]
            initWithFrame:CGRectMake (FITWIDTH (30), FITHEIGHT (36), FITWIDTH (428), FITHEIGHT (58))];
            label.text = clarityDic[indexPath.row];

            // 设置字体和是否加粗
            label.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
            [cell addSubview:label];
        }
    }
    return cell;
}

// 点击cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    if (tableView == _tableView)
    {
        if (indexPath.section == 0)
        {
            NSDictionary *dic = durationDic[indexPath.row];
            NSString *key = dic.allKeys[0];
            NSString *value = [dic valueForKey:key];
            [_timebutton setTitle:key forState:UIControlStateNormal];
            [probeInfo setVideoPlayTime:[value intValue]];

            [_tableView removeFromSuperview];
            [_buttonback removeFromSuperview];
        }
    }
    else
    {
        if (indexPath.section == 0)
        {
            [_timebutton2 setTitle:clarityDic[indexPath.row] forState:UIControlStateNormal];
            [probeInfo setVideoClarity:clarityDic[indexPath.row]];

            [_tableView2 removeFromSuperview];
            [_buttonback2 removeFromSuperview];
        }
    }
}

#pragma mark - 创建带框服务器设置的UI界面
- (void)createBandwidthUI
{
    // 获取默认值
    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    SVSpeedTestServer *object = [servers getDefaultServer];

    // 取数组里的值
    _defaultvalue = object;

    // views3
    UIView *bandWidthView = [[UIView alloc] init];
    bandWidthView.frame =
    CGRectMake (FITWIDTH (22), statusBarH + FITHEIGHT (612), kScreenW - FITWIDTH (44), FITHEIGHT (290));
    bandWidthView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bandWidthView];

    // label
    UILabel *bandWidthLabel = [[UILabel alloc] init];
    bandWidthLabel.frame = CGRectMake (FITWIDTH (30), FITHEIGHT (36), FITWIDTH (488), FITHEIGHT (58));
    bandWidthLabel.text = I18N (@"Speed Test Server Config");
    bandWidthLabel.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    bandWidthLabel.textColor = [UIColor colorWithHexString:@"#CC000000"];
    [bandWidthView addSubview:bandWidthLabel];

    // labelview
    UIView *labelview =
    [[UIView alloc] initWithFrame:CGRectMake (FITWIDTH (30), bandWidthLabel.bottomY + FITHEIGHT (22),
                                              FITWIDTH (580), FITHEIGHT (138))];
    labelview.layer.cornerRadius = svCornerRadius (12);
    [bandWidthView addSubview:labelview];

    // 归属地label
    _label1 = [[UILabel alloc] initWithFrame:CGRectMake (0, 0, FITWIDTH (580), FITHEIGHT (58))];
    _label1.text = _defaultvalue.name;
    _label1.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    [labelview addSubview:_label1];

    // 服务器地址label
    _label2 = [[UILabel alloc]
    initWithFrame:CGRectMake (0, _label1.bottomY + FITHEIGHT (22), FITWIDTH (580), FITHEIGHT (58))];
    _label2.text = _defaultvalue.sponsor;
    _label2.font = [UIFont systemFontOfSize:pixelToFontsize (35)];
    [labelview addSubview:_label2];

    // button自动
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake (labelview.rightX, FITHEIGHT (90), FITWIDTH (172), FITHEIGHT (110));
    _button.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];

    // 设置文字
    [_button setTitle:I18N (@"auto") forState:UIControlStateNormal];
    _button.titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    _button.titleLabel.textAlignment = NSTextAlignmentCenter;
    _button.layer.cornerRadius = svCornerRadius (12);
    [_button addTarget:self
                action:@selector (BtnClicked:)
      forControlEvents:UIControlEventTouchUpInside];
    [bandWidthView addSubview:_button];

    // button选择
    _button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _button2.frame =
    CGRectMake (_button.rightX + FITWIDTH (52), FITHEIGHT (90), FITWIDTH (172), FITHEIGHT (110));
    _button2.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [_button2 setTitle:I18N (@"select") forState:UIControlStateNormal];
    _button2.titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    _button2.titleLabel.textAlignment = NSTextAlignmentCenter;
    _button2.layer.cornerRadius = svCornerRadius (12);
    [_button2 addTarget:self
                 action:@selector (Btn2Clicked:)
       forControlEvents:UIControlEventTouchUpInside];
    [bandWidthView addSubview:_button2];
}
//自动按钮的点击事件
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
        [servers setDefaultServer:defaultvalue0];
    }
    [servers setAuto:YES];
    _button2.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _button.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
}
//选择按钮的点击事件
- (void)Btn2Clicked:(UIButton *)button2
{
    SVInfo (@"选择");
    _button.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _button2.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];

    //跳转到带宽测试服务器列表
    SVBandWidthCtrl *bandwidthCtrl = [[SVBandWidthCtrl alloc] init];
    bandwidthCtrl.title = I18N (@"Bandwidth test server configuration");
    [self.navigationController pushViewController:bandwidthCtrl animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    float screenSize = [[textField text] floatValue];
    if (screenSize < 13 || screenSize > 100)
    {
        NSString *message = [NSString stringWithFormat:@"%@ %@", I18N (@"Value is invalid"),
                                                       I18N (@"Please enter the number of 13~100")];
        [SVToast showWithText:message];

        SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
        _textField.text = probeInfo.getScreenSize;
    }
    else
    {
        SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
        [probeInfo setScreenSize:[_textField.text floatValue]];
    }
}
#pragma mark - 创建结果上传选择开关UI界面
- (void)createResultUploadUI
{
    // views4
    UIView *resultUploadView = [[UIView alloc] init];
    resultUploadView.frame =
    CGRectMake (FITWIDTH (22), statusBarH + FITHEIGHT (917), kScreenW - FITHEIGHT (44), FITHEIGHT (130));
    resultUploadView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:resultUploadView];

    // label结果上传
    UILabel *lableResultUpload = [[UILabel alloc] init];
    lableResultUpload.frame = CGRectMake (FITWIDTH (30), FITHEIGHT (36), FITWIDTH (488), FITHEIGHT (58));
    lableResultUpload.text = I18N (@"Result Upload");
    lableResultUpload.textColor = [UIColor colorWithHexString:@"#CC000000"];
    lableResultUpload.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    [resultUploadView addSubview:lableResultUpload];

    // switch选择开关
    UISwitch *mySwitch = [[UISwitch alloc] init];
    mySwitch.frame = CGRectMake (FITWIDTH (850), 0, 0, 0);
    mySwitch.centerY = lableResultUpload.centerY;
    [mySwitch addTarget:self
                 action:@selector (switchChange:)
       forControlEvents:UIControlEventValueChanged];

    // 设置switch开关的默认值
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    BOOL isUploadResult = [probeInfo isUploadResult];
    [mySwitch setOn:isUploadResult];
    [resultUploadView addSubview:mySwitch];
}
// switch选择开关点击事件
- (void)switchChange:(id)sender
{
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    UISwitch *mySwitch = (UISwitch *)sender;
    BOOL isButtonOn = [mySwitch isOn];
    if (isButtonOn)
    {
        SVInfo (@"Open result upload!");
        [probeInfo setUploadResult:YES];
    }
    else
    {
        SVInfo (@"Close result upload!");
        [probeInfo setUploadResult:NO];
    }
}

#pragma mark - 自定义创建BarButtonItem返回按钮
//返回按钮的点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
