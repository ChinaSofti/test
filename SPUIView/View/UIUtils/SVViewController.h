//
//  SVViewController.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/29.
//  Copyright © 2016年 Huawei. All rights reserved.
//

@interface SVViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

// 初始化标题
- (void)initTitleView;

// 初始化标题
- (void)initTitleViewWithTitle:(NSString *)title;

// 初始化返回按钮
- (void)initBackButtonWithTarget:(nullable id)target action:(nullable SEL)action;

// 获取NavigationBar的高度
- (CGFloat)getNavigationBarH;

// 设置图片透明度
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha image:(UIImage *)image;

// 初始化TableView
- (UITableView *)createTableViewWithRect:(CGRect)rect WithColor:(UIColor *)bgColor;
@end
