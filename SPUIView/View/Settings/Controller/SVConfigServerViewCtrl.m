//
//  SVConfigServerViewCtrl.m
//  SpeedPro
//
//  Created by WBapple on 16/5/11.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVConfigServerURL.h"
#import "SVConfigServerViewCtrl.h"
@interface SVConfigServerViewCtrl () <UITextFieldDelegate>

@end

@implementation SVConfigServerViewCtrl
{
    UIView *_views;
    UITableView *_tableView;
    UIButton *_choosebutton;
    UIButton *_savebutton;
    UIButton *_buttonback;
    UITextField *_textField;
    NSString *_url;
    NSArray *_array;
    NSString *_sign;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
    [super initBackButtonWithTarget:self action:@selector (backButtonClick)];
    //初始化默认数据
    SVConfigServerURL *configServerURL = [SVConfigServerURL sharedInstance];
    _url = [configServerURL getConfigServerUrl];
    _array = [configServerURL getConfigServerUrlListArray];
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
#pragma mark - 创建UI
- (void)createUI
{
    //配置服务器views
    _views = [[UIView alloc] init];
    _views.frame =
    CGRectMake (FITWIDTH (22), statusBarH + FITHEIGHT (332), kScreenW - FITWIDTH (44), FITHEIGHT (130));
    _views.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_views];

    // 配置服务器label
    UILabel *labelConfigServer = [[UILabel alloc] init];
    labelConfigServer.frame = CGRectMake (FITWIDTH (30), FITHEIGHT (36), FITWIDTH (230), FITHEIGHT (58));
    labelConfigServer.text = @"配置服务器:";
    labelConfigServer.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    labelConfigServer.textColor = [UIColor colorWithHexString:@"#000000"];
    [_views addSubview:labelConfigServer];

    // textfield文本输入框
    _textField = [[UITextField alloc] init];
    _textField.frame = CGRectMake (labelConfigServer.rightX, FITHEIGHT (36), FITWIDTH (608), FITHEIGHT (58));
    _textField.text = _url;
    _textField.placeholder = @"请输入URL";
    _textField.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.keyboardType = UIKeyboardTypeDefault;
    //添加textfield实时监听的方法
    [_textField addTarget:self
                   action:@selector (textFieldEditChanged:)
         forControlEvents:UIControlEventEditingChanged];
    [_views addSubview:_textField];

    // 选择按钮
    _choosebutton =
    [[UIButton alloc] initWithFrame:CGRectMake (_textField.rightX + FITWIDTH (12), FITHEIGHT (16),
                                                FITWIDTH (136), FITHEIGHT (96))];
    NSString *title = I18N (@"选择");
    [_choosebutton setTitle:title forState:UIControlStateNormal];
    [_choosebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _choosebutton.titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    _choosebutton.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    _choosebutton.layer.cornerRadius = svCornerRadius (12);
    _choosebutton.layer.masksToBounds = YES;
    [_choosebutton addTarget:self
                      action:@selector (mychooseButtonClick:)
            forControlEvents:UIControlEventTouchUpInside];
    [_views addSubview:_choosebutton];

    // 保存按钮初
    CGFloat saveBtnH = FITHEIGHT (116);
    _savebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    _savebutton.frame = CGRectMake (saveBtnH, kScreenH - saveBtnH * 5, kScreenW - saveBtnH * 2, saveBtnH);
    _savebutton.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    NSString *title2 = (@"保存");
    [_savebutton setTitle:title2 forState:UIControlStateNormal];
    [_savebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _savebutton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_savebutton.titleLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (48)]];
    _savebutton.layer.cornerRadius = svCornerRadius (12);
    [_savebutton addTarget:self
                    action:@selector (mysavebuttonClick:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_savebutton];
}

//创建tableviewUI
- (void)creatTableviewUI
{
    CGFloat tableviewH;
    if ((unsigned long)_array.count < 7)
    {
        tableviewH = FITHEIGHT (130) * (unsigned long)_array.count;
    }
    else
    {
        tableviewH = FITHEIGHT (130) * 6;
    }
    // 创建一个 tableView
    _tableView = [self
    createTableViewWithRect:CGRectMake (_textField.originX, _views.bottomY, _textField.width, tableviewH)
                  WithStyle:UITableViewStylePlain
                  WithColor:[UIColor colorWithHexString:@"#FFFFFF"]
               WithDelegate:self
             WithDataSource:self];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [self.view addSubview:_tableView];
}
//创建视频下拉tableview的隐藏按钮
- (void)creattableViewbackbutton
{
    _buttonback = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, kScreenW, kScreenH)];
    _buttonback.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.0];
    [_buttonback addTarget:self

                    action:@selector (tableViewbackbutton:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonback];
}
#pragma mark - tableview的代理方法

//设置 tableView 的 numberOfSectionsInTableView(设置几个 section)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (unsigned long)_array.count;
}
//设置 tableView的 numberOfRowsInSection(设置每个section中有几个cell)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
    //    设置每个cell的内容
    UILabel *label = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (30), FITHEIGHT (36), _textField.width, FITHEIGHT (58))];
    label.text = _array[indexPath.section];
    // 设置字体和是否加粗
    label.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
    [cell addSubview:label];
    return cell;
}

// 点击cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i = 0; i < (unsigned long)_array.count; i++)
    {
        if (indexPath.section == i)
        {
            _textField.text = _array[i];
            _sign = [NSString stringWithFormat:@"%d", i];
        }
    }
    [self tableViewbackbutton:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 点击事件
//选择按钮的点击事件
- (void)mychooseButtonClick:(UIButton *)btn
{
    [self creattableViewbackbutton];
    [self creatTableviewUI];
}
//保存按钮的点击事件
- (void)mysavebuttonClick:(UIButton *)btn
{
    //保存数据
    for (int i = 0; i < (unsigned long)_array.count; i++)
    {
        if ([_sign isEqual:[NSString stringWithFormat:@"%d", i]])
        {
            SVConfigServerURL *configServerURL = [SVConfigServerURL sharedInstance];
            [configServerURL setConfigServerUrl:_array[i]];
        }
    }
    //获取textfield的值
    [self textFieldEditChanged:_textField];

    if (_textField)
    {
        SVConfigServerURL *configServerURL = [SVConfigServerURL sharedInstance];
        [configServerURL setConfigServerUrl:_textField.text];
        //退出键盘
        [_textField resignFirstResponder];
    }
    [self backButtonClick];
}
// 退出键盘的方法
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![_textField isExclusiveTouch])
    {
        [_textField resignFirstResponder];
    }
}
//返回按钮的点击事件
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
// tableview消失的点击事件
- (void)tableViewbackbutton:(UIButton *)btn
{
    [_tableView removeFromSuperview];
    [_buttonback removeFromSuperview];
}
//添加输入改变的方法
- (void)textFieldEditChanged:(UITextField *)textField
{
    //    SVInfo (@"%@", _textField.text);
}
@end
