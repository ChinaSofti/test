//
//  SVWarningView.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/3/15.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVWarningView.h"

@interface SVWarningView ()
{
    UIView *_bgView;
}
@property (nonatomic, strong) UIView *btnView;

@end

@implementation SVWarningView

// 初始化告警框
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

// 创建告警框的内容
- (void)createUI
{
    NSString *message = I18N (@"Upload the test result faile, continue?");
    NSString *cancelStr = I18N (@"Cancel");
    NSString *continueStr = I18N (@"Continue");

    // 告警消息
    UILabel *messageLabel = [CTWBViewTools
    createLabelWithFrame:CGRectMake (FITWIDTH (0), FITWIDTH (15), FITWIDTH (279), FITWIDTH (20))
                withFont:17
          withTitleColor:[UIColor blackColor]
               withTitle:message];
    messageLabel.textAlignment = NSTextAlignmentCenter;

    // 按钮篮筐
    _btnView = [[UIView alloc] init];
    _btnView.layer.borderWidth = 1;
    _btnView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnView.layer.masksToBounds = YES;
    _btnView.layer.cornerRadius = 5;
    self.btnView.frame = CGRectMake (FITWIDTH (15), FITWIDTH (25), FITWIDTH (85), FITWIDTH (20));

    // 取消按钮
    UIButton *cancelBtn = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (15), FITWIDTH (25), FITWIDTH (85), FITWIDTH (20))];
    [cancelBtn setTitle:cancelStr forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancelBtn setBackgroundImage:[CTWBViewTools imageWithColor:RGBACOLOR (35, 144, 222, 1)
                                                           size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                         forState:UIControlStateHighlighted];
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.masksToBounds = YES;
    [cancelBtn addTarget:self
                  action:@selector (alertViewCancel:)
        forControlEvents:UIControlEventTouchUpInside];

    // 继续按钮
    UIButton *continueBtn = [[UIButton alloc]
    initWithFrame:CGRectMake (FITWIDTH (150), FITWIDTH (25), FITWIDTH (85), FITWIDTH (20))];
    [continueBtn setTitle:continueStr forState:UIControlStateNormal];
    continueBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [continueBtn setBackgroundImage:[CTWBViewTools imageWithColor:RGBACOLOR (35, 144, 222, 1)
                                                             size:CGSizeMake (FITWIDTH (114), FITWIDTH (40))]
                           forState:UIControlStateHighlighted];
    continueBtn.layer.cornerRadius = 5;
    continueBtn.layer.masksToBounds = YES;
    continueBtn.backgroundColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];
    [continueBtn addTarget:self
                    action:@selector (alertView:clickedButtonAtIndex:)
          forControlEvents:UIControlEventTouchUpInside];

    [_bgView addSubview:messageLabel];
    [_bgView addSubview:_btnView];
    [_bgView addSubview:cancelBtn];
    [_bgView addSubview:continueBtn];
}
@end
