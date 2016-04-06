//
//  SVViewController.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/29.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVViewController.h"

@interface SVViewController ()

@end

@implementation SVViewController

{
    double originHeight;
}

@synthesize backBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //电池显示不了,设置样式让电池显示
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

// 初始化标题
- (void)initTitleView
{
    // 定义图片
    UIImage *titleImage = [UIImage imageNamed:@"speedpro"];

    // 自定义navigationItem.titleView
    UIImageView *imageView =
    [[UIImageView alloc] initWithFrame:CGRectMake (0, 0, titleImage.size.width, titleImage.size.height)];

    //设置图片名称
    imageView.image = titleImage;

    //让图片适应
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    //把图片添加到navigationItem.titleView
    self.navigationItem.titleView = imageView;
}

// 初始化标题
- (void)initTitleViewWithTitle:(NSString *)title
{
    // 设置图片宽和高
    CGFloat imageW = FITWIDTH (489);
    CGFloat imageH = FITHEIGHT (83);

    // 自定义navigationItem.titleView
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake (0, 0, imageW, imageH)];

    //设置标题名称
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (54)];
    titleLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    //把图片添加到navigationItem.titleView
    self.navigationItem.titleView = titleLabel;
}

// 初始化返回按钮
- (void)initBackButton
{
    // 添加返回按钮
    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, FITWIDTH (140), FITHEIGHT (70))];
    //    backBtn.backgroundColor = [UIColor redColor];
    [self.backBtn setImage:[UIImage imageNamed:@"homeindicator"] forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    UIBarButtonItem *fixeSpaceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                  target:nil
                                                                                  action:nil];
    fixeSpaceBtn.width = FITWIDTH (-50);
    self.navigationItem.leftBarButtonItems = @[fixeSpaceBtn, backButton];

    // 为了保持平衡添加一个leftBtn
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake (0, 0, FITWIDTH (140), FITHEIGHT (70))];
    UIBarButtonItem *rightBackBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBackBtn;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 在显示view的时候修改navigationBar的高度
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 设置navigationBar的高度
    CGRect rect = self.navigationController.navigationBar.frame;

    // 缓存原始的高度
    originHeight = rect.size.height;

    // 设置新的高度
    [self.navigationController.navigationBar
    setFrame:CGRectMake (rect.origin.x, rect.origin.y, rect.size.width, FITHEIGHT (144))];

    // 设置标题距离底部的距离
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:-0.0
                                                                  forBarMetrics:UIBarMetricsDefault];

    // 设置返回按钮距离底部的距离
    [self.navigationItem.leftBarButtonItem setBackgroundVerticalPositionAdjustment:-0.0
                                                                     forBarMetrics:UIBarMetricsDefault];
}

// 在页面节将消失时，还原设置
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // 设置navigationBar的高度
    CGRect rect = self.navigationController.navigationBar.frame;
    [self.navigationController.navigationBar
    setFrame:CGRectMake (rect.origin.x, rect.origin.y, rect.size.width, originHeight)];

    // 设置标题距离底部的距离
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:-0.0
                                                                  forBarMetrics:UIBarMetricsDefault];

    // 设置返回按钮距离底部的距离
    [self.navigationItem.leftBarButtonItem setBackgroundVerticalPositionAdjustment:-0.0
                                                                     forBarMetrics:UIBarMetricsDefault];
}

// 获取NavigationBar的高度
- (CGFloat)getNavigationBarH
{
    return self.navigationController.navigationBar.frame.size.height;
}

// 设置图片透明度
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha image:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions (image.size, NO, 0.0f);

    CGContextRef ctx = UIGraphicsGetCurrentContext ();
    CGRect area = CGRectMake (0, 0, image.size.width, image.size.height);

    CGContextScaleCTM (ctx, 1, -1);
    CGContextTranslateCTM (ctx, 0, -area.size.height);

    CGContextSetBlendMode (ctx, kCGBlendModeMultiply);

    CGContextSetAlpha (ctx, alpha);

    CGContextDrawImage (ctx, area, image.CGImage);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext ();

    UIGraphicsEndImageContext ();

    return newImage;
}

@end
