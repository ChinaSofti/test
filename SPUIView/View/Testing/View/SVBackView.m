//
//  SVBackView.m
//  SPUIView
//
//  Created by WBapple on 16/1/26.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "CTYYLToolView.h"
#import "SVBackView.h"
#import "UIView+Exten.h"

static NSInteger BtnTag = 10086;
@interface SVBackView ()
{
    UIView *_bgView;
    UIButton *_typeBtn;
}
@end

@implementation SVBackView

- (instancetype)initWithFrame:(CGRect)frame bgColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self)
    {

        _bgView = [[UIView alloc]
        initWithFrame:CGRectMake (FITWIDTH (0), FITWIDTH (65), FITWIDTH (280), FITWIDTH (160))];
        _bgView.backgroundColor = color;
        _bgView.layer.cornerRadius = 5;
        _bgView.layer.masksToBounds = YES;

        [self addSubview:_bgView];
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    //标头
    UILabel *titleLabel = [CTYYLToolView
    createLabelWithFrame:CGRectMake (FITWIDTH (50), FITWIDTH (15), FITWIDTH (180), FITWIDTH (20))
                withFont:17
          withTitleColor:[UIColor blackColor]
               withTitle:@"终止测试"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //标头2
    UILabel *titleLabel2 = [CTYYLToolView
    createLabelWithFrame:CGRectMake (FITWIDTH (50), FITWIDTH (65), FITWIDTH (180), FITWIDTH (20))
                withFont:17
          withTitleColor:[UIColor blackColor]
               withTitle:@"确定退出本次测试吗?"];
    titleLabel2.textAlignment = NSTextAlignmentCenter;

    //否
    UIButton *overLookBtn = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (15), FITWIDTH (105), FITWIDTH (115), FITWIDTH (40))];
    [overLookBtn setTitle:@"否" forState:UIControlStateNormal];
    [overLookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [overLookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [overLookBtn setBackgroundImage:[CTYYLToolView imageWithColor:RGBACOLOR (35, 144, 222, 1)
                                                             size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                           forState:UIControlStateHighlighted];
    [overLookBtn
    setBackgroundImage:[CTYYLToolView imageWithColor:[UIColor colorWithWhite:0.925 alpha:1.000]
                                                size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
              forState:UIControlStateNormal];
    overLookBtn.layer.cornerRadius = 5;
    overLookBtn.layer.masksToBounds = YES;

    [overLookBtn addTarget:self
                    action:@selector (overBtnClick:)
          forControlEvents:UIControlEventTouchUpInside];

    //是
    UIButton *saveBtn = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (150), FITWIDTH (105), FITWIDTH (115), FITWIDTH (40))];
    [saveBtn setTitle:@"是" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[CTYYLToolView imageWithColor:RGBACOLOR (35, 144, 222, 1)
                                                         size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                       forState:UIControlStateHighlighted];
    [saveBtn setBackgroundImage:[CTYYLToolView imageWithColor:RGBACOLOR (35, 144, 222, 1)
                                                         size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                       forState:UIControlStateNormal];
    saveBtn.layer.cornerRadius = 5;
    saveBtn.layer.masksToBounds = YES;

    [saveBtn addTarget:self
                action:@selector (saveButtonClick:)
      forControlEvents:UIControlEventTouchUpInside];


    [_bgView addSubview:titleLabel];
    [_bgView addSubview:titleLabel2];

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
    if ([self.delegate respondsToSelector:@selector (backView:didClickBtn:)])
    {
        [self.delegate backView:self didClickBtn:sender.tag];
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

- (void)overBtnClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector (backView:overLookBtnClick:)])
    {
        [self.delegate backView:self overLookBtnClick:btn];
    }
}

- (void)saveButtonClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector (backView:saveBtnClick:)])
    {
        [self.delegate backView:self saveBtnClick:btn];
    }
}

@end