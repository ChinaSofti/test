//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "AlertView.h"
#import "UIView+Exten.h"
#import <SPCommon/SVI18N.h>

static NSInteger BtnTag = 10086;
@interface AlertView ()
{
    UIView *_bgView;
    UIButton *_typeBtn;
}
@property (nonatomic, strong) UIView *imageView;
@property (nonatomic, strong) UIView *imageView2;

@end

@implementation AlertView
//按钮边框
- (UIView *)imageView
{
    if (_imageView == nil)
    {
        _imageView = [[UIView alloc] init];
        _imageView.layer.borderWidth = 1;
        _imageView.layer.borderColor =
        [[UIColor colorWithRed:61 / 255.0 green:173 / 255.0 blue:231 / 255.0 alpha:1] CGColor];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 5;
    }
    return _imageView;
}
- (UIView *)imageView2
{
    if (_imageView2 == nil)
    {
        _imageView2 = [[UIView alloc] init];
        _imageView2.layer.borderWidth = 1;
        _imageView2.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _imageView2.layer.masksToBounds = YES;
        _imageView2.layer.cornerRadius = 5;
    }
    return _imageView2;
}
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
    }

    return self;
}

- (void)createUI
{
    NSString *title1 = I18N (@"Setting Bandwidth Information");
    NSString *title2 = I18N (@"Type ");
    NSString *title3 = I18N (@"unknown");
    NSString *title4 = I18N (@"Fiber");
    NSString *title5 = I18N (@"Copper");
    NSString *title6 = I18N (@"Package");
    NSString *title7 = I18N (@"Carrier");
    NSString *title8 = I18N (@"China Unicom Beijing");
    NSString *title9 = I18N (@"Ignore");
    NSString *title10 = I18N (@"Save");
    //标题
    UILabel *titleLabel = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (0), FITWIDTH (15), FITWIDTH (279), FITWIDTH (20))
                withFont:17
          withTitleColor:[UIColor blackColor]
               withTitle:title1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //类型
    UILabel *internetTypeLabel = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (15), titleLabel.bottomY + FITWIDTH (15), FITWIDTH (60), FITWIDTH (20))
                withFont:15
          withTitleColor:RGBACOLOR (88, 88, 88, 1)
               withTitle:title2];
    //三个button
    for (int i = 0; i < 3; i++)
    {
        //初始化
        _typeBtn = [[UIButton alloc]
        initWithFrame:CGRectMake (FITWIDTH (84) + FITWIDTH (60) * i, internetTypeLabel.originY,
                                  FITWIDTH (60), FITWIDTH (20))];
        [_typeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_typeBtn
        setTitleColor:[UIColor colorWithRed:61 / 255.0 green:173 / 255.0 blue:231 / 255.0 alpha:1]
             forState:UIControlStateSelected];
        [_typeBtn setBackgroundImage:[CTWBViewTools imageWithColor:[UIColor whiteColor]
                                                              size:CGSizeMake (FITWIDTH (35), FITWIDTH (20))]
                            forState:UIControlStateSelected];
        _typeBtn.titleLabel.font = [UIFont systemFontOfSize:15];

        _typeBtn.tag = BtnTag + i;

        if (_typeBtn.tag == 0 + BtnTag)
        {
            [_typeBtn setTitle:title3 forState:UIControlStateNormal];
        }
        if (_typeBtn.tag == 1 + BtnTag)
        {
            [_typeBtn setTitle:title4 forState:UIControlStateNormal];
        }
        if (_typeBtn.tag == 2 + BtnTag)
        {
            [_typeBtn setTitle:title5 forState:UIControlStateNormal];
        }

        [_typeBtn addTarget:self
                     action:@selector (selectBtn:)
           forControlEvents:UIControlEventTouchUpInside];

        if (_typeBtn.tag == 10086)
        {
            _typeBtn.selected = YES;
            self.imageView.frame = CGRectMake (FITWIDTH (83), FITWIDTH (45), FITHEIGHT (61), FITHEIGHT (30));
            [_bgView addSubview:self.imageView];
        }
        [_bgView addSubview:_typeBtn];
    }
    //宽带套餐
    UILabel *internetMealLabel = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (15), internetTypeLabel.bottomY + FITWIDTH (15),
                                     FITWIDTH (60), FITWIDTH (20))
                withFont:15
          withTitleColor:RGBACOLOR (88, 88, 88, 1)
               withTitle:title6];
    //线
    UIView *lineView = [CTWBViewTools
    lineViewWithFrame:CGRectMake (FITWIDTH (80), internetMealLabel.bottomY, FITWIDTH (170), FITWIDTH (1.5))
            withColor:RGBACOLOR (67, 184, 202, 1)];
    //单位
    UILabel *M =
    [[UILabel alloc] initWithFrame:CGRectMake (FITWIDTH (255), internetTypeLabel.bottomY + FITWIDTH (15),
                                               FITHEIGHT (20), FITHEIGHT (20))];
    M.font = [UIFont systemFontOfSize:14];
    M.text = @"M";
    //输入文本
    _mealTextField = [CTWBViewTools
    createTextFieldWithFrame:CGRectMake (FITWIDTH (140), internetMealLabel.originY, FITWIDTH (100), FITWIDTH (20))
                 placeholder:nil
                        Font:15
                   fontColor:[UIColor blackColor]];
    //所属运营商
    UILabel *internetCompanyLabel = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (15), internetMealLabel.bottomY + FITWIDTH (15),
                                     FITWIDTH (80), FITWIDTH (20))
                withFont:15
          withTitleColor:RGBACOLOR (88, 88, 88, 1)
               withTitle:title7];
    //运营商
    _contentLabel = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (100), internetMealLabel.bottomY + FITWIDTH (15),
                                     FITWIDTH (160), FITWIDTH (20))
                withFont:15
          withTitleColor:[UIColor blackColor]
               withTitle:title8];
    _contentLabel.textAlignment = NSTextAlignmentRight;
    //按钮篮筐
    _imageView2 = [[UIView alloc] init];
    _imageView2.layer.borderWidth = 1;
    _imageView2.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _imageView2.layer.masksToBounds = YES;
    _imageView2.layer.cornerRadius = 5;
    self.imageView2.frame = CGRectMake (FITWIDTH (15), internetCompanyLabel.bottomY + FITWIDTH (25),
                                        FITWIDTH (115), FITWIDTH (40));
    //忽略按钮
    UIButton *overLookBtn = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (15), internetCompanyLabel.bottomY + FITWIDTH (25),
                              FITWIDTH (115), FITWIDTH (40))];
    [overLookBtn setTitle:title9 forState:UIControlStateNormal];
    [overLookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [overLookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [overLookBtn setBackgroundImage:[CTWBViewTools imageWithColor:RGBACOLOR (35, 144, 222, 1)
                                                             size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                           forState:UIControlStateHighlighted];
    overLookBtn.layer.cornerRadius = 5;
    overLookBtn.layer.masksToBounds = YES;
    [overLookBtn addTarget:self
                    action:@selector (overBtnClick:)
          forControlEvents:UIControlEventTouchUpInside];

    //保存按钮
    UIButton *saveBtn = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (150), internetCompanyLabel.bottomY + FITWIDTH (25),
                              FITWIDTH (115), FITWIDTH (40))];
    [saveBtn setTitle:title10 forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [saveBtn setBackgroundImage:[CTWBViewTools imageWithColor:RGBACOLOR (35, 144, 222, 1)
                                                         size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                       forState:UIControlStateHighlighted];
    saveBtn.layer.cornerRadius = 5;
    saveBtn.layer.masksToBounds = YES;
    saveBtn.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    [saveBtn addTarget:self
                action:@selector (saveButtonClick:)
      forControlEvents:UIControlEventTouchUpInside];

    [_bgView addSubview:titleLabel];
    [_bgView addSubview:internetTypeLabel];
    [_bgView addSubview:internetMealLabel];
    [_bgView addSubview:lineView];
    [_bgView addSubview:M];
    [_bgView addSubview:_mealTextField];
    [_bgView addSubview:internetCompanyLabel];
    [_bgView addSubview:_contentLabel];
    [_bgView addSubview:_imageView2];
    [_bgView addSubview:overLookBtn];
    [_bgView addSubview:saveBtn];
}

//按钮点击事件
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

            self.imageView.frame = CGRectMake (FITWIDTH (83), FITWIDTH (45), FITHEIGHT (61), FITHEIGHT (30));

            [self.imageView removeFromSuperview];
            [_bgView addSubview:self.imageView];
        }
        if (sender.tag == BtnTag + 1)
        {
            btnOne.selected = NO;
            btnThree.selected = NO;
            self.imageView.frame =
            CGRectMake (FITWIDTH (83) + FITHEIGHT (60), FITWIDTH (45), FITHEIGHT (61), FITHEIGHT (30));

            [self.imageView removeFromSuperview];
            [_bgView addSubview:self.imageView];
        }
        if (sender.tag == BtnTag + 2)
        {
            btnOne.selected = NO;
            btnTwo.selected = NO;
            self.imageView.frame =
            CGRectMake (FITWIDTH (83) + FITHEIGHT (120), FITWIDTH (45), FITHEIGHT (61), FITHEIGHT (30));

            [self.imageView removeFromSuperview];
            [_bgView addSubview:self.imageView];
        }
    }
}

//忽略按钮
- (void)overBtnClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector (alertView:overLookBtnClick:)])
    {
        [self.delegate alertView:self overLookBtnClick:btn];
    }
}
//保存按钮
- (void)saveButtonClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector (alertView:saveBtnClick:)])
    {
        [self.delegate alertView:self saveBtnClick:btn];
    }
}


@end
