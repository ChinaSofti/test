//
//  SVBWSettingViewCtrl.m
//  SPUIView
//
//  Created by XYB on 16/2/16.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#define BUTTON_TAG 30

#import "SVBWSettingViewCtrl.h"
#import "SVIPAndISPGetter.h"
#import "SVProbeInfo.h"
#import "SVTextField.h"

@interface SVBWSettingViewCtrl ()

@property (nonatomic, strong) UIView *imageView;

@end

@implementation SVBWSettingViewCtrl
{
    SVTextField *_textField;
    int _bandwidthTypeIndex;
    NSMutableArray *bandwidthTypeButtonArray;
}

- (UIView *)imageView
{
    if (_imageView == nil)
    {
        _imageView = [[UIView alloc] init];
        _imageView.layer.borderWidth = 1;
        _imageView.layer.borderColor = [UIColor colorWithHexString:@"#29a5e5"].CGColor;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = svCornerRadius (12);
    }
    return _imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
    // 初始化返回按钮
    [super initBackButton];
    [[super backBtn] addTarget:self
                        action:@selector (backButtonClick)
              forControlEvents:UIControlEventTouchUpInside];
    [self createUI];
}

//进去时 隐藏tabBar
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabBar" object:nil];
}
//出来时 显示tabBar
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabBar" object:nil];
}
#pragma mark -  创建UI
- (void)createUI
{
    NSString *title1 = I18N (@"Type");
    NSString *title2 = I18N (@"Unknown");
    NSString *title3 = I18N (@"Fiber");
    NSString *title4 = I18N (@"Copper");
    NSString *title5 = I18N (@"Package");
    NSString *title7 = I18N (@"Carrier");
    //    NSString *title8 = I18N (@"China Unicom Beijing");
    //    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    SVIPAndISP *ipAndISP = [SVIPAndISPGetter getIPAndISP];
    NSString *title8 = ipAndISP.isp;
    NSString *title9 = I18N (@"Save");

    // views
    UIView *views = [[UIView alloc] init];
    views.frame = CGRectMake (FITWIDTH (22), FITHEIGHT (279), FITWIDTH (1036), FITHEIGHT (650));
    views.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    views.layer.cornerRadius = svCornerRadius (12);
    views.layer.borderColor = [UIColor colorWithHexString:@"#dddddd"].CGColor;
    [self.view addSubview:views];

    // lableBWType
    UILabel *lableBWType = [[UILabel alloc] init];
    lableBWType.frame = CGRectMake (FITWIDTH (33), FITHEIGHT (45), FITWIDTH (580), FITHEIGHT (58));
    lableBWType.text = title1;
    lableBWType.font = [UIFont systemFontOfSize:pixelToFontsize (36)];
    lableBWType.textColor = [UIColor colorWithHexString:@"#CC000000"];
    [views addSubview:lableBWType];

    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    NSString *type = [probeInfo getBandwidthType];
    int bandwidthTypeIndex = [type intValue];

    bandwidthTypeButtonArray = [[NSMutableArray alloc] init];
    //三个button
    NSArray *titleArr = @[title2, title3, title4];
    UIButton *selectedButton = nil;
    for (int i = 0; i < 3; i++)
    {
        UIButton *button = [[UIButton alloc] init];
        [bandwidthTypeButtonArray addObject:button];
        button.frame =
        CGRectMake (FITWIDTH (208) + i * FITWIDTH (210), FITHEIGHT (114), FITWIDTH (198), FITHEIGHT (79));
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        // button普通状态下的字体颜色
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        // button选中状态下的字体颜色
        [button setTitleColor:[UIColor colorWithHexString:@"#e50000000"]
                     forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithHexString:@"#29a5e5"]
                     forState:UIControlStateSelected];

        button.titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (42)];

        [button addTarget:self
                   action:@selector (buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        button.tag = BUTTON_TAG + i;
        [views addSubview:button];
        //设置初始默认选择按钮
        //        SVInfo (@"%d  %d", i, bandwidthTypeIndex);
        if (!bandwidthTypeIndex && i == 0)
        {
            selectedButton = button;
        }

        if (bandwidthTypeIndex && bandwidthTypeIndex == i)
        {
            selectedButton = button;
        }
    }

    [self buttonClicked:selectedButton];

    // lableBWPackage
    UILabel *lableBWPackage = [[UILabel alloc] init];
    lableBWPackage.frame = CGRectMake (FITWIDTH (29), FITHEIGHT (246), FITWIDTH (290), FITHEIGHT (58));
    lableBWPackage.text = title5;
    lableBWPackage.font = [UIFont systemFontOfSize:pixelToFontsize (36)];
    [views addSubview:lableBWPackage];

    _textField = [[SVTextField alloc] init];
    //大小
    _textField.frame =
    CGRectMake (FITWIDTH (29), FITHEIGHT (315), kScreenW - FITWIDTH (115), FITHEIGHT (58));
    //文字
    _textField.text = [probeInfo getBandwidth];
    _textField.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    _textField.textColor = [UIColor colorWithHexString:@"#4C000000"];
    _textField.layer.cornerRadius = svCornerRadius (12);
    //边框
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    //灰色提示框
    _textField.placeholder = @"Please input bandwidth";
    //键盘类型
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    [_textField setCharacterLength:5];

    //添加
    [views addSubview:_textField];

    UILabel *M = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (928), FITHEIGHT (315), FITWIDTH (58), FITHEIGHT (58))];
    M.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    M.text = @"M";
    [views addSubview:M];

    // lableCarrier
    UILabel *lableCarrier = [[UILabel alloc] init];
    lableCarrier.frame = CGRectMake (FITWIDTH (29), FITHEIGHT (453), FITWIDTH (290), FITHEIGHT (58));
    lableCarrier.text = title7;
    lableCarrier.font = [UIFont systemFontOfSize:pixelToFontsize (36)];
    [views addSubview:lableCarrier];

    UILabel *lableCarriers = [[UILabel alloc] init];
    lableCarriers.frame = CGRectMake (FITWIDTH (29), FITHEIGHT (536), FITWIDTH (434), FITHEIGHT (58));
    lableCarriers.text = title8;
    lableCarriers.font = [UIFont systemFontOfSize:pixelToFontsize (45)];
    [views addSubview:lableCarriers];

    //添加保存按钮
    //保存按钮高度
    CGFloat saveBtnH = FITHEIGHT (116);
    //保存按钮类型
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //保存按钮尺寸
    saveBtn.frame = CGRectMake (saveBtnH, views.bottomY + FITHEIGHT (465), FITWIDTH (872), saveBtnH);
    //保存按钮背景颜色
    saveBtn.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    //保存按钮文字和颜色
    [saveBtn setTitle:title9 forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //设置居中
    saveBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    //保存按钮点击事件
    [saveBtn addTarget:self
                action:@selector (saveBtnClicked:)
      forControlEvents:UIControlEventTouchUpInside];
    //保存按钮圆角
    saveBtn.layer.cornerRadius = svCornerRadius (12);
    ;
    //保存按钮交互
    saveBtn.userInteractionEnabled = YES;
    // 设置字体大小
    [saveBtn.titleLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (48)]];
    [self.view addSubview:saveBtn];
}
//退出键盘的方法
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![_textField isExclusiveTouch])
    {
        [_textField resignFirstResponder];
    }
}
#pragma mark - 点击事件
- (void)buttonClicked:(UIButton *)button
{
    for (UIButton *bb in bandwidthTypeButtonArray)
    {
        bb.selected = NO;
    }

    button.selected = YES;

    switch (button.tag - BUTTON_TAG)
    {
    case 0:
        //跟随系统
        SVInfo (@"未知");

        self.imageView.frame = CGRectMake (FITWIDTH (230), FITHEIGHT (393), FITWIDTH (198), FITHEIGHT (79));

        [self.imageView removeFromSuperview];
        [self.view addSubview:self.imageView];
        _bandwidthTypeIndex = 0;
        break;
    case 1:
        //简体中文
        SVInfo (@"光纤");
        self.imageView.frame = CGRectMake (FITWIDTH (438), FITHEIGHT (393), FITWIDTH (198), FITHEIGHT (79));

        [self.imageView removeFromSuperview];
        [self.view addSubview:self.imageView];
        _bandwidthTypeIndex = 1;
        break;
    case 2:
        // English
        SVInfo (@"铜线");
        self.imageView.frame = CGRectMake (FITWIDTH (651), FITHEIGHT (393), FITWIDTH (198), FITHEIGHT (79));

        [self.imageView removeFromSuperview];
        [self.view addSubview:self.imageView];
        _bandwidthTypeIndex = 2;
        break;

    default:
        break;
    }
}
//保存按钮
- (void)saveBtnClicked:(UIButton *)button
{
    SVInfo (@"带宽设置--保存");
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
    if (_textField.text)
    {
        SVInfo (@"%@", _textField.text);
        [probeInfo setBandwidth:_textField.text];

        // 更新probeInfo的内容
        SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
        [probeInfo setBandwidth:_textField.text];
    }

    if (_bandwidthTypeIndex > 0)
    {
        SVInfo (@"%d", _bandwidthTypeIndex);
        [probeInfo setBandwidthType:[NSString stringWithFormat:@"%d", _bandwidthTypeIndex]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
//返回按钮
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
