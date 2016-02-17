//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "AlertView.h"
#import "CTYYLToolView.h"
#import "UIView+Exten.h"

static NSInteger BtnTag = 10086;
@interface AlertView ()
{
    UIView *_bgView;
    UIButton *_typeBtn;
}
@end

@implementation AlertView

- (instancetype)initWithFrame:(CGRect)frame bgColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self)
    {

        _bgView = [[UIView alloc] initWithFrame:CGRectMake (0, 0, frame.size.width, frame.size.height)];
        _bgView.backgroundColor = color;
        _bgView.layer.cornerRadius = 5;
        _bgView.layer.masksToBounds = YES;

        [self addSubview:_bgView];
        [self createUI];

        UIImageView *imageView =
        [[UIImageView alloc] initWithFrame:CGRectMake (FITWIDTH (80), _bgView.bottomY + FITWIDTH (50),
                                                       FITWIDTH (20), FITWIDTH (20))];
        imageView.image = [UIImage imageNamed:@"a"];
        UILabel *signLabel = [CTYYLToolView
        createLabelWithFrame:CGRectMake (FITWIDTH (105), _bgView.bottomY + FITWIDTH (50),
                                         FITWIDTH (100), FITWIDTH (20))
                    withFont:14
              withTitleColor:[UIColor whiteColor]
                   withTitle:@"您正在使用WiFi"];

        [self addSubview:imageView];
        [self addSubview:signLabel];
    }
    return self;
}

- (void)createUI
{
    UILabel *titleLabel = [CTYYLToolView
    createLabelWithFrame:CGRectMake (FITWIDTH (50), FITWIDTH (15), FITWIDTH (180), FITWIDTH (20))
                withFont:17
          withTitleColor:[UIColor blackColor]
               withTitle:@"设置带宽信息"];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    UILabel *internetTypeLabel = [CTYYLToolView
    createLabelWithFrame:CGRectMake (FITWIDTH (15), titleLabel.bottomY + FITWIDTH (15), FITWIDTH (60), FITWIDTH (20))
                withFont:15
          withTitleColor:RGBACOLOR (88, 88, 88, 1)
               withTitle:@"带宽类型"];

    for (int i = 0; i < 3; i++)
    {
        _typeBtn = [self btnWithFrame:CGRectMake (FITWIDTH (140) + FITWIDTH (45) * i,
                                                  internetTypeLabel.originY, FITWIDTH (35), FITWIDTH (20))
                                title:nil];
        _typeBtn.tag = BtnTag + i;

        if (_typeBtn.tag == 0 + BtnTag)
        {
            [_typeBtn setTitle:@"未知" forState:UIControlStateNormal];
        }
        if (_typeBtn.tag == 1 + BtnTag)
        {
            [_typeBtn setTitle:@"光纤" forState:UIControlStateNormal];
        }
        if (_typeBtn.tag == 2 + BtnTag)
        {
            [_typeBtn setTitle:@"铜线" forState:UIControlStateNormal];
        }

        [_typeBtn addTarget:self
                     action:@selector (selectBtn:)
           forControlEvents:UIControlEventTouchUpInside];

        [_bgView addSubview:_typeBtn];
    }

    UILabel *internetMealLabel = [CTYYLToolView
    createLabelWithFrame:CGRectMake (FITWIDTH (15), internetTypeLabel.bottomY + FITWIDTH (15),
                                     FITWIDTH (60), FITWIDTH (20))
                withFont:15
          withTitleColor:RGBACOLOR (88, 88, 88, 1)
               withTitle:@"带宽套餐"];

    UIView *lineView = [CTYYLToolView
    lineViewWithFrame:CGRectMake (FITWIDTH (140), internetMealLabel.bottomY, FITWIDTH (100), FITWIDTH (1.5))
            withColor:RGBACOLOR (67, 184, 202, 1)];

    UIImageView *imageView = [[UIImageView alloc]
    initWithFrame:CGRectMake (FITWIDTH (245), internetMealLabel.originY + FITWIDTH (3),
                              FITWIDTH (14), FITWIDTH (14))];
    imageView.image = [UIImage imageNamed:@"m"];

    _mealTextField = [CTYYLToolView
    createTextFieldWithFrame:CGRectMake (FITWIDTH (140), internetMealLabel.originY, FITWIDTH (100), FITWIDTH (20))
                 placeholder:nil
                        Font:15
                   fontColor:[UIColor blackColor]];

    UILabel *internetCompanyLabel = [CTYYLToolView
    createLabelWithFrame:CGRectMake (FITWIDTH (15), internetMealLabel.bottomY + FITWIDTH (15),
                                     FITWIDTH (80), FITWIDTH (20))
                withFont:15
          withTitleColor:RGBACOLOR (88, 88, 88, 1)
               withTitle:@"所属运营商"];

    _contentLabel = [CTYYLToolView
    createLabelWithFrame:CGRectMake (FITWIDTH (140), internetMealLabel.bottomY + FITWIDTH (15),
                                     FITWIDTH (120), FITWIDTH (20))
                withFont:15
          withTitleColor:[UIColor blackColor]
               withTitle:@"中国电信 江苏省"];
    _contentLabel.textAlignment = NSTextAlignmentRight;

    UIButton *overLookBtn = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (15), internetCompanyLabel.bottomY + FITWIDTH (25),
                              FITWIDTH (115), FITWIDTH (40))];
    [overLookBtn setTitle:@"忽略" forState:UIControlStateNormal];
    [overLookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [overLookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [overLookBtn setBackgroundImage:[CTYYLToolView imageWithColor:RGBACOLOR (35, 144, 222, 1)
                                                             size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                           forState:UIControlStateHighlighted];
    overLookBtn.layer.cornerRadius = 5;
    overLookBtn.layer.masksToBounds = YES;

    [overLookBtn addTarget:self
                    action:@selector (overBtnClick:)
          forControlEvents:UIControlEventTouchUpInside];

    UIButton *saveBtn = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (150), internetCompanyLabel.bottomY + FITWIDTH (25),
                              FITWIDTH (115), FITWIDTH (40))];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [saveBtn setBackgroundImage:[CTYYLToolView imageWithColor:RGBACOLOR (35, 144, 222, 1)
                                                         size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                       forState:UIControlStateHighlighted];
    saveBtn.layer.cornerRadius = 5;
    saveBtn.layer.masksToBounds = YES;

    [saveBtn addTarget:self
                action:@selector (saveButtonClick:)
      forControlEvents:UIControlEventTouchUpInside];

    [_bgView addSubview:titleLabel];
    [_bgView addSubview:internetTypeLabel];
    [_bgView addSubview:internetMealLabel];
    [_bgView addSubview:lineView];
    [_bgView addSubview:imageView];
    [_bgView addSubview:_mealTextField];
    [_bgView addSubview:internetCompanyLabel];
    [_bgView addSubview:_contentLabel];
    [_bgView addSubview:overLookBtn];
    [_bgView addSubview:saveBtn];
}

- (UIButton *)btnWithFrame:(CGRect)frame title:(NSString *)title
{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];

    [button setTitle:title forState:UIControlStateNormal];

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:RGBACOLOR (37, 146, 224, 1) forState:UIControlStateSelected];
    [button setBackgroundImage:[CTYYLToolView imageWithColor:[UIColor yellowColor]
                                                        size:CGSizeMake (FITWIDTH (35), FITWIDTH (20))]
                      forState:UIControlStateSelected];

    button.titleLabel.font = [UIFont systemFontOfSize:15];

    return button;
}

- (void)selectBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector (alertView:didClickBtn:)])
    {
        [self.delegate alertView:self didClickBtn:sender.tag];
    }
    sender.selected = !sender.selected;
    UIView *view = [sender superview];
    UIButton *btnOne = [view viewWithTag:BtnTag];
    UIButton *btnTwo = [view viewWithTag:1 + BtnTag];
    UIButton *btnThree = [view viewWithTag:2 + BtnTag];

    if (sender.selected)
    {
        if (sender.tag == BtnTag)
        {
            btnTwo.selected = NO;
            btnThree.selected = NO;
        }
        if (sender.tag == BtnTag + 1)
        {
            btnOne.selected = NO;
            btnThree.selected = NO;
        }
        if (sender.tag == BtnTag + 2)
        {
            btnOne.selected = NO;
            btnTwo.selected = NO;
        }
    }
}
/**
 *  <#Description#>
 *
 *  @param btn <#btn description#>
 */
- (void)overBtnClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector (alertView:overLookBtnClick:)])
    {
        [self.delegate alertView:self overLookBtnClick:btn];
    }
}
/**
 *  保存按钮方法
 *
 *  @param btn 按钮
 */
- (void)saveButtonClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector (alertView:saveBtnClick:)])
    {
        [self.delegate alertView:self saveBtnClick:btn];
    }
}
/*

 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
