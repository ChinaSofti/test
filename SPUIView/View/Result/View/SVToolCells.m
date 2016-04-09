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
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {

        // 设置背景颜色
        self.backgroundColor = [UIColor clearColor];

        // 将该cell设置为不可选中
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        // 创建UIView，所有内容都在该view上面显示
        UIView *bgdView = [[UIView alloc]
        initWithFrame:CGRectMake (FITWIDTH (22), 0, kScreenW - 2 * FITWIDTH (22), FITHEIGHT (132))];
        bgdView.layer.borderColor = [UIColor colorWithHexString:@"#DDDDDD"].CGColor;
        bgdView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
        bgdView.layer.borderWidth = FITHEIGHT (1);


        // 设置指标名称的label
        _keyLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (33), 0, (bgdView.frame.size.width - 2 * FITWIDTH (33)) * 0.4,
                                  FITHEIGHT (132))];
        _keyLabel.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
        _keyLabel.textAlignment = NSTextAlignmentLeft;
        _keyLabel.textColor = [UIColor colorWithHexString:@"#CC000000"];
        [bgdView addSubview:_keyLabel];

        // 设置指标值的label
        _valueLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (_keyLabel.rightX, 0, (bgdView.frame.size.width - 2 * FITWIDTH (33)) * 0.6,
                                  FITHEIGHT (132))];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
        _valueLabel.textColor = [UIColor colorWithHexString:@"#E5000000"];
        [bgdView addSubview:_valueLabel];


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
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        // 设置背景颜色
        self.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];

        // 将该cell设置为不可选中
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        // 设置背景图片
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake (FITWIDTH (22), FITHEIGHT (60), FITWIDTH (36), FITHEIGHT (36));

        // 设置title
        UILabel *label = [[UILabel alloc]
        initWithFrame:CGRectMake (imageView.rightX + FITWIDTH (15), FITHEIGHT (60),
                                  kScreenW - 2 * (imageView.rightX + FITWIDTH (15)), FITHEIGHT (36))];
        label.text = title;
        label.font = [UIFont systemFontOfSize:pixelToFontsize (36)];
        label.textColor = [UIColor colorWithHexString:@"#B2000000"];

        // 将UIView放到cell中
        [self addSubview:imageView];
        [self addSubview:label];
    }
    return self;
}

// 初始化testUrl的cell
- (instancetype)initUrlCellWithStyle:(UITableViewCellStyle)style
                     reuseIdentifier:(NSString *)reuseIdentifier
                             testUrl:(NSString *)testUrl
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {

        // 设置背景颜色
        self.backgroundColor = [UIColor clearColor];

        // 将该cell设置为不可选中
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        // 设置testUrl的label
        UILabel *label = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (22), 0, kScreenW - 2 * FITWIDTH (22), FITHEIGHT (132))];
        label.text = testUrl;
        label.font = [UIFont systemFontOfSize:pixelToFontsize (42)];
        label.textColor = [UIColor colorWithHexString:@"#FF38C695"];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.borderColor = [UIColor colorWithHexString:@"#DDDDDD"].CGColor;
        label.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
        label.layer.borderWidth = FITHEIGHT (1);

        // 将UIView放到cell中
        [self addSubview:label];
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
