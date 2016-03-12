//
//  SVToolCells.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVToolCells.h"

@interface SVToolCells ()
@property (nonatomic, retain) SVToolModels *model;
@property (nonatomic, retain) UILabel *keyLabel;
@property (nonatomic, retain) UILabel *valueLabel;

@end

@implementation SVToolCells

// 初始化cell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {

        // 设置背景颜色
        self.backgroundColor = [UIColor clearColor];

        // 将该cell设置为不可选中
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        // 创建UIView，所有内容都在该view上面显示
        UIView *bgdView = [[UIView alloc] init];
        bgdView.frame = CGRectMake (kMargin, 0, kScreenW - 2 * kMargin, kScreenH * 0.07);
        bgdView.layer.borderColor =
        [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1].CGColor;
        bgdView.backgroundColor = [UIColor whiteColor];
        bgdView.layer.borderWidth = 1;


        // 设置指标名称的label
        _keyLabel = [[UILabel alloc] initWithFrame:CGRectMake (10, 0, kScreenW * 0.36, kScreenH * 0.07)];
        [bgdView addSubview:_keyLabel];
        _keyLabel.font = [UIFont systemFontOfSize:12.0f];

        // 设置指标值的label
        _valueLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (kScreenW * 0.36, 0, kScreenW - kScreenW * 0.36 - 30, kScreenH * 0.07)];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        [bgdView addSubview:_valueLabel];
        _valueLabel.font = [UIFont systemFontOfSize:12.0f];

        // 将UIView放到cell中
        [self addSubview:bgdView];
    }
    return self;
}

// 初始化标题的cell
- (instancetype)initTitleCellWithStyle:(UITableViewCellStyle)style
                       reuseIdentifier:(NSString *)reuseIdentifier
                                 title:(NSString *)title
                             imageName:(NSString *)imageName
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        // 设置背景颜色
        self.backgroundColor =
        [UIColor colorWithRed:240.0f / 255 green:240.0f / 255 blue:240.0f / 255 alpha:1.0];

        // 将该cell设置为不可选中
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        // 初始化UIView
        UIView *titleView = [[UIView alloc] init];

        // 设置背景图片
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake (kMargin, 10, 17, 17);
        [titleView addSubview:imageView];

        // 设置title
        UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake (kMargin + 22, 1, kScreenW - 2 * kMargin, 35)];
        label.text = title;
        label.font = [UIFont systemFontOfSize:12.0f];
        [titleView addSubview:label];

        // 将UIView放到cell中
        [self addSubview:titleView];
    }
    return self;
}

// 初始化testUrl的cell
- (instancetype)initUrlCellWithStyle:(UITableViewCellStyle)style
                     reuseIdentifier:(NSString *)reuseIdentifier
                             testUrl:(NSString *)testUrl
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {

        // 设置背景颜色
        self.backgroundColor = [UIColor clearColor];

        // 将该cell设置为不可选中
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        // 创建UIView，所有内容都在该view上面显示
        UIView *testUrlView = [[UIView alloc] init];
        testUrlView.frame = CGRectMake (kMargin, 0, kScreenW - 2 * kMargin, kScreenH * 0.07);
        testUrlView.layer.borderColor =
        [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1].CGColor;
        testUrlView.backgroundColor = [UIColor whiteColor];
        testUrlView.layer.borderWidth = 1;

        // 设置testUrl的label
        UILabel *testUrlLabel =
        [[UILabel alloc] initWithFrame:CGRectMake (kMargin, 0, kScreenW - 2 * kMargin, kScreenH * 0.07)];
        testUrlLabel.textAlignment = NSTextAlignmentCenter;
        testUrlLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        testUrlLabel.text = testUrl;
        testUrlLabel.textColor =
        [UIColor colorWithRed:52 / 255.0 green:199 / 255.0 blue:73 / 255.0 alpha:1];
        [testUrlView addSubview:testUrlLabel];

        // 将UIView放到cell中
        [self addSubview:testUrlView];
    }
    return self;
}

// 变更指标名称和指标值显示的内容
- (void)cellViewModelByToolModel:(SVToolModels *)model Section:(NSInteger)section
{
    _model = model;
    _keyLabel.text = model.key;
    _valueLabel.text = model.value;
}

// 设置是否选中
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
