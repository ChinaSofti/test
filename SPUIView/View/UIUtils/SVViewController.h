//
//  SVViewController.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/29.
//  Copyright © 2016年 Huawei. All rights reserved.
//

@interface SVViewController : UIViewController

// 初始化标题
- (void)initTitleView;

// 初始化标题
- (void)initTitleViewWithTitle:(nonnull NSString *)title;

// 初始化返回按钮
- (void)initBackButtonWithTarget:(nullable id)target action:(nullable SEL)action;

// 获取NavigationBar的高度
- (CGFloat)getNavigationBarH;

// 设置图片透明度
- (nullable UIImage *)imageByApplyingAlpha:(CGFloat)alpha image:(nonnull UIImage *)image;

// 初始化TableView
- (nullable UITableView *)createTableViewWithRect:(CGRect)rect
                                        WithStyle:(UITableViewStyle)style
                                        WithColor:(nonnull UIColor *)bgColor
                                     WithDelegate:(nonnull id)delegate
                                   WithDataSource:(nonnull id)dataSource;

// 当前页面是否正在显示
- (BOOL)isVisible;

@end
