//
//  SVToolCell.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVToolCell.h"

@interface SVToolCell ()
@property (nonatomic, retain) SVToolModel *model;
@property (nonatomic, retain) UIImageView *imgView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *rightImgView;
@end

@implementation SVToolCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {

        self.backgroundColor = [UIColor whiteColor];

        // 初始化按钮
        _bgdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgdBtn.frame = CGRectMake (FITWIDTH (22), 0, FITWIDTH (1036), FITHEIGHT (209));
        _bgdBtn.layer.cornerRadius = svCornerRadius (12);
        _bgdBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _bgdBtn.layer.borderWidth = 1;
        [_bgdBtn addTarget:self
                    action:@selector (bgdBtnClick1:)
          forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bgdBtn];

        // 初始化按钮左侧图片
        _imgView = [[UIImageView alloc]
        initWithFrame:CGRectMake (FITWIDTH (63), FITHEIGHT (44.5), FITWIDTH (120), FITHEIGHT (120))];
        [_bgdBtn addSubview:_imgView];

        // 初始化按钮右侧图片
        _rightImgView = [[UIImageView alloc]
        initWithFrame:CGRectMake (_bgdBtn.width - FITWIDTH (120) - FITWIDTH (63), FITHEIGHT (49.5),
                                  FITWIDTH (110), FITWIDTH (110))];
        [_bgdBtn addSubview:_rightImgView];

        // 初始化标题
        _titleLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (_imgView.rightX + FITWIDTH (114), _imgView.originY,
                                  _rightImgView.originX - _imgView.rightX - FITWIDTH (114), FITHEIGHT (120))];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#B2000000"];
        _titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (51)];

        //初始化透明度
        _bgdBtn.alpha = 0.5;
        [_bgdBtn addSubview:_titleLabel];

        //        _imgView.backgroundColor = [UIColor blueColor];
        //        _titleLabel.backgroundColor = [UIColor greenColor];
        //        _rightImgView.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)cellViewModel:(SVToolModel *)model section:(NSInteger)section
{
    _model = model;
    _imgView.image = [UIImage imageNamed:model.img_normal];
    _titleLabel.text = model.title;
    _rightImgView.image = [UIImage imageNamed:model.rightImg_normal];
    _bgdBtn.tag = section;
    [_bgdBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)bgdBtnClick1:(UIButton *)btn
{
    btn.selected = !btn.selected;

    if (btn.selected)
    {
        _imgView.image = [UIImage imageNamed:_model.img_selected];
        _rightImgView.image = [UIImage imageNamed:_model.rightImg_selected];

        UIImage *img = _rightImgView.image;
        _bgdBtn.layer.borderColor =
        [CTViewTools colorWithImg:img
                            point:CGPointMake (img.size.width * 0.75, img.size.height * 0.75)]
        .CGColor;
        //选中后透明度设置为1.0
        _bgdBtn.alpha = 1;
    }
    else
    {
        _imgView.image = [UIImage imageNamed:_model.img_normal];
        _rightImgView.image = [UIImage imageNamed:_model.rightImg_normal];
        _bgdBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        //不选的时候透明度设为0.5

        _bgdBtn.alpha = 0.5;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector (toolCellClick:)])
    {
        [self.delegate toolCellClick:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
