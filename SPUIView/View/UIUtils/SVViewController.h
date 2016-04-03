//
//  SVViewController.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/29.
//  Copyright © 2016年 Huawei. All rights reserved.
//

@interface SVViewController : UIViewController

@property (nonatomic, strong) UIButton *backBtn;

// 初始化标题
- (void)initTitleView;

// 初始化标题
- (void)initTitleViewWithTitle:(NSString *)title;

// 初始化返回按钮
- (void)initBackButton;
@end
