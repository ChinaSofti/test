//
//  SVGuideView.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/6/23.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVGuideView.h"
#import "SVI18N.h"

@implementation SVGuideView
{
    // 引导页的数量
    int guideViewNumber;

    // 指示当前处于第几个引导页
    UIPageControl *pageControl;

    // 用于存放并显示引导页
    UIScrollView *scrollView;

    // 我知道了按钮
    UIButton *startBtn;
}

/**
 * 根据页面个数初始化View
 */
- (id)initWithPageNumber:(int)pageNumber
{
    self = [super initWithFrame:kScreen];
    if (!self)
    {
        return nil;
    }

    guideViewNumber = pageNumber;

    // 初始化引导页
    scrollView = [[UIScrollView alloc] initWithFrame:kScreen];

    // 设置代理
    scrollView.delegate = self;

    // 设置整页显示
    scrollView.pagingEnabled = YES;

    // 设置内容大小
    scrollView.contentSize = CGSizeMake (kScreenW * pageNumber, kScreenH);

    // 不显示滚动条
    scrollView.showsHorizontalScrollIndicator = NO;

    //避免弹跳效果,避免把根视图露出来
    [scrollView setBounces:NO];
    [self addSubview:scrollView];

    // 初始化分页信息
    pageControl = [[UIPageControl alloc]
    initWithFrame:CGRectMake (0, kScreenH - FITHEIGHT (100), kScreenW, FITHEIGHT (50))];

    // 设置未选中分页的颜色
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];

    // 设置选中分页的颜色
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"29A5E5"];

    // 设置用户不可交互
    pageControl.userInteractionEnabled = NO;
    [self addSubview:pageControl];

    // 设置总页数
    pageControl.numberOfPages = pageNumber;

    // 初始化每个引导页的图片
    for (int index = 1; index <= pageNumber; index++)
    {
        [self createGuideViewWithIndex:index];
    }
    return self;
}

- (void)createGuideViewWithIndex:(int)index
{
    // 获取语言
    SVI18N *i18n = [SVI18N sharedInstance];
    NSString *language = [i18n getLanguage];

    // 根据语言获取图片，并将图片添加到引导页
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"guide_view_%@_%d", language, index]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake (kScreenW * (index - 1), 0, kScreenW, kScreenH);

    // 如果是最后一页，添加按钮
    if (index == guideViewNumber)
    {
        imageView.userInteractionEnabled = YES;
        [imageView addSubview:[self createStartBtn]];
    }

    [scrollView addSubview:imageView];
}

//有网时候的按钮
- (UIButton *)createStartBtn
{
    if (startBtn == nil)
    {
        // 按钮类型
        startBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        // 按钮尺寸
        startBtn.frame =
        CGRectMake (FITWIDTH (220), kScreenH - FITHEIGHT (500), FITWIDTH (600), FITHEIGHT (116));

        // 按钮背景颜色
        startBtn.backgroundColor = [UIColor clearColor];
        [startBtn setTitle:I18N (@"I Know") forState:UIControlStateNormal];

        // 设置边框
        [startBtn.layer setBorderWidth:1.0];

        // 按钮点击事件
        [startBtn addTarget:self
                     action:@selector (btnClick)
           forControlEvents:UIControlEventTouchUpInside];

        // 按钮圆角
        startBtn.layer.cornerRadius = svCornerRadius (12);

        // 设置居中
        startBtn.titleLabel.textAlignment = NSTextAlignmentCenter;

        // 按钮文字颜色和类型
        [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        // 设置字体大小
        [startBtn.titleLabel setFont:[UIFont systemFontOfSize:pixelToFontsize (48)]];
    }
    return startBtn;
}

- (void)btnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector (hideGuideView:)])
    {
        [self.delegate hideGuideView:self];
    }
}

/**
 * 滚动结束
 */
- (void)scrollViewDidScroll:(UIScrollView *)view
{
    // 计算当前是第几页
    int index = fabs (view.contentOffset.x / kScreenW);

    // 设置当前页
    [pageControl setCurrentPage:index];
}
@end
