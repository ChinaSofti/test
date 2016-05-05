//
//  SVAlertView.m
//  SpeedPro
//
//  Created by Rain on 5/5/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVAlertView.h"
#import "SVReloadingDataAlertView.h"

@implementation SVAlertView
{
    BOOL isShowing;
}

- (id)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.3]];
    }

    return self;
}

- (void)showAlertView
{
    isShowing = TRUE;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];


    UIView *loadDataView = [[UIView alloc] init];
    [loadDataView setSize:CGSizeMake (kScreenW - 50, FITHEIGHT (550))];
    [loadDataView setCenter:CGPointMake (kScreenW / 2, kScreenH / 2)];
    [loadDataView setBackgroundColor:[UIColor colorWithHexString:@"#FFFAFAFA"]];
    //    [loadDataView setBackgroundColor:[UIColor redColor]];
    [loadDataView.layer setCornerRadius:5];

    CGFloat height = loadDataView.frame.size.height;
    CGFloat width = loadDataView.frame.size.width;

    // --------title
    NSString *prompt = I18N (@"Prompt");
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:pixelToFontsize (52)],
    };

    CGRect textRect = [prompt boundingRectWithSize:CGSizeMake (width, FITHEIGHT (150))
                                           options:NSStringDrawingTruncatesLastVisibleLine
                                        attributes:attributes
                                           context:nil];

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake (0, 0, width, FITHEIGHT (150))];
    UILabel *title = [[UILabel alloc] init];
    [title setSize:CGSizeMake (textRect.size.width, textRect.size.height)];
    [title setText:prompt];
    [title setFont:[UIFont systemFontOfSize:pixelToFontsize (52)]];
    [title setCenter:CGPointMake (titleView.frame.size.width / 2, titleView.frame.size.height / 2)];
    [titleView addSubview:title];
    // --------title  end--

    // --------Content
    UIView *contentView = [[UIView alloc]
    initWithFrame:CGRectMake (0, titleView.frame.size.height, width, height - FITHEIGHT (350))];

    CGFloat contentViewWidth = contentView.frame.size.width;
    CGFloat contentViewHeight = contentView.frame.size.height;
    UILabel *content = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (50), 0, contentViewWidth - FITWIDTH (100), contentViewHeight)];
    [content setText:I18N (@"Network Connection Changed")];
    [content setFont:[UIFont systemFontOfSize:pixelToFontsize (46)]];
    [content setLineBreakMode:NSLineBreakByWordWrapping];
    [content setNumberOfLines:0];
    [contentView addSubview:content];
    // --------Content  end--

    // --------按钮
    UIView *buttonView =
    [[UIView alloc] initWithFrame:CGRectMake (0, height - FITHEIGHT (170), width, FITHEIGHT (170))];

    CGFloat offset = (width - FITWIDTH (300) * 2) / 8;
    UIColor *selectedColor =
    [UIColor colorWithRed:51 / 255.0 green:166 / 255.0 blue:226 / 255.0 alpha:1.0];

    CGFloat buttonViewHeight = buttonView.frame.size.height;
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setSize:CGSizeMake (FITWIDTH (300), FITHEIGHT (116))];
    [leftButton setCenter:CGPointMake (width / 4 + offset, buttonViewHeight / 2)];
    [leftButton setTitle:I18N (@"No") forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [leftButton.layer setBorderWidth:0.4];
    [leftButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [leftButton.layer setCornerRadius:5];
    [leftButton addTarget:self
                   action:@selector (leftButtonClick:)
         forControlEvents:UIControlEventTouchUpInside];

    UIButton *rightButton = [[UIButton alloc] init];
    [rightButton setSize:CGSizeMake (FITWIDTH (300), FITHEIGHT (116))];
    [rightButton setCenter:CGPointMake (width / 4 * 3 - offset, buttonViewHeight / 2)];
    [rightButton setTitle:I18N (@"Yes") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton.layer setCornerRadius:5];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [rightButton setBackgroundColor:selectedColor];
    [rightButton setSelected:YES];
    [rightButton addTarget:self
                    action:@selector (rightButtonClick:)
          forControlEvents:UIControlEventTouchUpInside];

    [buttonView addSubview:leftButton];
    [buttonView addSubview:rightButton];
    // --------按钮  end--

    [loadDataView addSubview:titleView];
    [loadDataView addSubview:contentView];
    [loadDataView addSubview:buttonView];

    [self addSubview:loadDataView];
    [keyWindow addSubview:self];
}


- (void)hideAlertView
{
    [self removeFromSuperview];
    isShowing = FALSE;
}

- (void)leftButtonClick:(UIButton *)button
{
    [self hideAlertView];
}

- (void)rightButtonClick:(UIButton *)button
{
    NSLog (@"reload data");
    [self hideAlertView];

    SVReloadingDataAlertView *reloadingData = [[SVReloadingDataAlertView alloc] init];
    [reloadingData showAlertView];
}

- (BOOL)isShowing
{
    return isShowing;
}

@end
