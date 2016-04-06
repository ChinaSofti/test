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

// 初始化TableView
- (UITableView *)createTableViewWithRect:(CGRect)rect WithColor:(UIColor *)bgColor
{
    // 创建一个 tableView
    UITableView *_tableView =
    [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];

    // 设置背景颜色
    _tableView.backgroundColor = bgColor;

    // 设置代理
    _tableView.delegate = self;

    // 设置数据源
    _tableView.dataSource = self;

    // 设置tableView的section的分割线隐藏
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // 设置tableView不可上下拖动
    _tableView.bounces = NO;

    return _tableView;
}

// 初始化返回按钮
- (void)initBackButtonWithTarget:(nullable id)target action:(nullable SEL)action
{
    // 添加返回按钮
    UIBarButtonItem *backButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"homeindicator"]
                                     style:UIBarButtonItemStylePlain
                                    target:target
                                    action:action];
    [backButton setTintColor:[UIColor whiteColor]];
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
