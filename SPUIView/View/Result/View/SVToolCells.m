//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVToolCells.h"

@interface SVToolCells ()
@property (nonatomic, retain) SVToolModels *model;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *titleLabel2;

@end

@implementation SVToolCells
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {

        self.backgroundColor = [UIColor clearColor];

        _bgdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgdBtn.frame = CGRectMake (kMargin, 0, kScreenW - 2 * kMargin, kScreenH * 0.07);
        _bgdBtn.layer.cornerRadius = kCornerRadius;
        _bgdBtn.layer.borderColor =
        [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1].CGColor;
        _bgdBtn.backgroundColor = [UIColor whiteColor];
        _bgdBtn.layer.borderWidth = 1;
        [self addSubview:_bgdBtn];


        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake (10, 0, kScreenW * 0.36, kScreenH * 0.07)];
        [_bgdBtn addSubview:_titleLabel];
        _titleLabel.font = [UIFont systemFontOfSize:12.0f];


        _titleLabel2 = [[UILabel alloc]
        initWithFrame:CGRectMake (kScreenW * 0.36, 0, kScreenW - kScreenW * 0.36 - 30, kScreenH * 0.07)];
        _titleLabel2.textAlignment = NSTextAlignmentRight;
        [_bgdBtn addSubview:_titleLabel2];
        _titleLabel2.font = [UIFont systemFontOfSize:12.0f];


        //        _titleLabel.backgroundColor = [UIColor greenColor];
        //        _titleLabel2.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (void)cellViewModel2:(SVToolModels *)model section:(NSInteger)section
{
    _model = model;
    _titleLabel.text = model.title;
    _titleLabel2.text = model.title2;
    _bgdBtn.tag = section;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
