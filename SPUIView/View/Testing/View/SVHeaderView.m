//
//  SVHeaderView.m
//  SpeedPro
//
//  Created by WBapple on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVHeaderView.h"

@implementation SVHeaderView
{
    // 定义三个view，对应左中右三个位置
    UIView *leftView;
    UIView *middleView;
    UIView *rightView;

    // 左侧指标值
    UILabel *leftValueLabel;

    // 左侧指标标题
    UILabel *leftTitleLabel;

    // 左侧指标单位
    UILabel *leftUnitLabel;

    // 中间指标值
    UILabel *middleValueLabel;

    // 中间指标标题
    UILabel *middleTitleLabel;

    // 中间指标单位
    UILabel *middleUnitLabel;

    // 右侧指标值
    UILabel *rightValueLabel;

    // 右侧指标标题
    UILabel *rightTitleLabel;

    // 右侧指标单位
    UILabel *rightUnitLabel;

    // 标题字体大小
    UIFont *labelFontSize;

    // 指标值字体大小
    UIFont *valueFontSize;

    // 指标单位字体大小
    UIFont *unitFontSize;

    // 标题颜色
    UIColor *labelColor;

    // 指标值颜色
    UIColor *valueColor;

    // 单位颜色
    UIColor *unitColor;
}

//初始化方法
- (instancetype)initWithDic:(NSMutableDictionary *)dic
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    // 设置view大小
    [self setFrame:CGRectMake (0, FITHEIGHT (144), kScreenW, FITHEIGHT (312))];

    // 初始化字体大小和颜色
    labelFontSize = dic[@"labelFontSize"];
    labelColor = dic[@"labelColor"];
    valueFontSize = dic[@"valueFontSize"];
    valueColor = dic[@"valueColor"];
    unitFontSize = dic[@"unitFontSize"];
    unitColor = dic[@"unitColor"];

    // 初始化左侧view
    leftView = [[UIView alloc]
    initWithFrame:CGRectMake (FITWIDTH (60), FITHEIGHT (108), FITWIDTH (320), FITHEIGHT (124))];

    // 初始化左侧指标值的label
    leftValueLabel = [[UILabel alloc] init];
    [leftValueLabel setTextColor:[UIColor colorWithHexString:@"#4C000000"]];
    [leftValueLabel setText:dic[@"leftDefaultValue"]];
    [leftValueLabel setFont:valueFontSize];

    // 左侧指标值的label
    leftTitleLabel = [[UILabel alloc] init];
    [leftTitleLabel setText:dic[@"leftTitle"]];
    [leftTitleLabel setTextColor:labelColor];
    [leftTitleLabel setFont:labelFontSize];

    // 左侧指标单位的label
    leftUnitLabel = [[UILabel alloc] init];
    [leftUnitLabel setTextColor:[UIColor colorWithHexString:@"#4C000000"]];
    [leftUnitLabel setText:dic[@"leftUnit"]];
    [leftUnitLabel setFont:unitFontSize];


    [leftView addSubview:leftValueLabel];
    [leftView addSubview:leftUnitLabel];
    [leftView addSubview:leftTitleLabel];

    // 初始化中间view
    middleView = [[UIView alloc]
    initWithFrame:CGRectMake (leftView.rightX, FITHEIGHT (108), FITWIDTH (320), FITHEIGHT (124))];

    // 中间指标值的label
    middleValueLabel = [[UILabel alloc] init];
    [middleValueLabel setTextColor:[UIColor colorWithHexString:@"#4C000000"]];
    [middleValueLabel setText:dic[@"middleDefaultValue"]];
    [middleValueLabel setFont:valueFontSize];

    // 中间指标值的label
    middleTitleLabel = [[UILabel alloc] init];
    [middleTitleLabel setText:dic[@"middleTitle"]];
    [middleTitleLabel setTextColor:labelColor];
    [middleTitleLabel setFont:labelFontSize];

    // 中间指标单位的label
    middleUnitLabel = [[UILabel alloc] init];
    [middleUnitLabel setTextColor:[UIColor colorWithHexString:@"#4C000000"]];
    [middleUnitLabel setText:dic[@"middleUnit"]];
    [middleUnitLabel setFont:unitFontSize];

    [middleView addSubview:middleValueLabel];
    [middleView addSubview:middleUnitLabel];
    [middleView addSubview:middleTitleLabel];

    // 初始化右侧view
    rightView = [[UIView alloc]
    initWithFrame:CGRectMake (middleView.rightX, FITHEIGHT (108), FITWIDTH (320), FITHEIGHT (124))];

    // 右侧指标值的label
    rightValueLabel = [[UILabel alloc] init];
    [rightValueLabel setTextColor:[UIColor colorWithHexString:@"#4C000000"]];
    [rightValueLabel setText:dic[@"rightDefaultValue"]];
    [rightValueLabel setFont:valueFontSize];

    // 右侧指标值的label
    rightTitleLabel = [[UILabel alloc] init];
    [rightTitleLabel setText:dic[@"rightTitle"]];
    [rightTitleLabel setTextColor:labelColor];
    [rightTitleLabel setFont:labelFontSize];

    // 右侧指标单位的label
    rightUnitLabel = [[UILabel alloc] init];
    [rightUnitLabel setTextColor:[UIColor colorWithHexString:@"#4C000000"]];
    [rightUnitLabel setText:dic[@"rightUnit"]];
    [rightUnitLabel setFont:unitFontSize];


    [rightView addSubview:rightValueLabel];
    [rightView addSubview:rightUnitLabel];
    [rightView addSubview:rightTitleLabel];

    // 初始化布局
    [self resetTitleLabelLayout];
    [self resetValueLabelLayout];

    [self addSubview:leftView];
    [self addSubview:middleView];
    [self addSubview:rightView];

    return self;
}

//初始化方法
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // webtesting
        NSString *title3 = I18N (@"Response Time");
        NSString *title4 = I18N (@"Download Speed");
        NSString *title5 = I18N (@"Load duration");
        //设置Label
        _ResponseLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (35), FITWIDTH (100), FITWIDTH (50), FITWIDTH (20))
                    withFont:16
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"N/A"];
        _ResponseLabel1 = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_ResponseLabel.rightX, FITWIDTH (100), FITWIDTH (30), FITWIDTH (20))
                    withFont:10
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"s"];
        _DownloadLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_ResponseLabel1.rightX, FITWIDTH (100), FITWIDTH (65), FITWIDTH (20))
                    withFont:16
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"N/A"];
        _DownloadLabel1 = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_DownloadLabel.rightX, FITWIDTH (100), FITWIDTH (35), FITWIDTH (20))
                    withFont:10
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"kbps"];

        _LoadLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_DownloadLabel1.rightX, FITWIDTH (100), FITWIDTH (58), FITWIDTH (20))
                    withFont:16
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"N/A"];
        _LoadLabel1 = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_LoadLabel.rightX, FITWIDTH (100), FITWIDTH (32), FITWIDTH (20))
                    withFont:10
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"s"];

        _ResponseNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (35), _ResponseLabel.bottomY + FITWIDTH (10),
                                         FITWIDTH (95), FITWIDTH (20))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title3];

        _DownloadNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_ResponseNumLabel.rightX, _ResponseLabel.bottomY + FITWIDTH (10),
                                         FITWIDTH (95), FITWIDTH (20))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title4];

        _LoadNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_DownloadNumLabel.rightX, _ResponseLabel.bottomY + FITWIDTH (10),
                                         FITWIDTH (95), FITWIDTH (20))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title5];
        //所有Label居中对齐
        _ResponseLabel.textAlignment = NSTextAlignmentRight;
        _ResponseLabel1.textAlignment = NSTextAlignmentLeft;
        _DownloadLabel.textAlignment = NSTextAlignmentRight;
        _DownloadLabel1.textAlignment = NSTextAlignmentLeft;
        _LoadLabel.textAlignment = NSTextAlignmentRight;
        _LoadLabel1.textAlignment = NSTextAlignmentLeft;

        _ResponseNumLabel.textAlignment = NSTextAlignmentCenter;
        _DownloadNumLabel.textAlignment = NSTextAlignmentCenter;
        _LoadNumLabel.textAlignment = NSTextAlignmentCenter;

        // speedtesting
        NSString *title6 = I18N (@"Delay");
        NSString *title7 = I18N (@"Download Speed");
        NSString *title8 = I18N (@"Upload speed");
        //设置Label
        _Delay = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (30), FITWIDTH (100), FITWIDTH (50), FITWIDTH (20))
                    withFont:16
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"N/A"];
        _Delay1 = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_Delay.rightX, FITWIDTH (100), FITWIDTH (30), FITWIDTH (20))
                    withFont:10
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"ms"];
        _Downloadspeed = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_Delay1.rightX, FITWIDTH (100), FITWIDTH (58), FITWIDTH (20))
                    withFont:16
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"N/A"];
        _Downloadspeed1 = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_Downloadspeed.rightX, FITWIDTH (100), FITWIDTH (42), FITWIDTH (20))
                    withFont:10
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"Mbps"];

        _Uploadspeed = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_Downloadspeed1.rightX, FITWIDTH (100), FITWIDTH (52), FITWIDTH (20))
                    withFont:16
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"N/A"];
        _Uploadspeed1 = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_Uploadspeed.rightX, FITWIDTH (101), FITWIDTH (38), FITWIDTH (20))
                    withFont:10
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"Mbps"];

        _DelayNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (30), _Delay.bottomY + FITWIDTH (10), FITWIDTH (80), FITWIDTH (20))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title6];

        _DownloadspeedNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_DelayNumLabel.rightX, _Delay.bottomY + FITWIDTH (10),
                                         FITWIDTH (100), FITWIDTH (20))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title7];

        _UploadspeedNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_DownloadspeedNumLabel.rightX,
                                         _Delay.bottomY + FITWIDTH (10), FITWIDTH (90), FITWIDTH (20))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title8];
        // 所有Label居中对齐
        _Delay.textAlignment = NSTextAlignmentRight;
        _Delay1.textAlignment = NSTextAlignmentLeft;
        _Downloadspeed.textAlignment = NSTextAlignmentRight;
        _Downloadspeed1.textAlignment = NSTextAlignmentLeft;
        _Uploadspeed.textAlignment = NSTextAlignmentRight;
        _Uploadspeed1.textAlignment = NSTextAlignmentLeft;

        _DelayNumLabel.textAlignment = NSTextAlignmentCenter;
        _DownloadspeedNumLabel.textAlignment = NSTextAlignmentCenter;
        _UploadspeedNumLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

/**
 * 更新左侧的label内容
 */
- (void)updateLeftValue:(NSString *)value
{
    leftValueLabel.text = value;
    [self resetValueLabelLayout];
}

/**
 * 更新中间的label内容
 */
- (void)updateMiddleValue:(NSString *)value
{
    middleValueLabel.text = value;
    [self resetValueLabelLayout];
}

/**
 * 更新右侧的label内容
 */
- (void)updateRightValue:(NSString *)value
{
    rightValueLabel.text = value;
    [self resetValueLabelLayout];
}

/**
 * 将左侧的labe换成view
 */
- (void)replaceLeftLabelWithView:(UIView *)view
{
    // 将原来的label去除
    [leftUnitLabel removeFromSuperview];
    [leftValueLabel removeFromSuperview];

    // 初始化view的frame
    [view setFrame:CGRectMake (leftTitleLabel.originX, 0, leftTitleLabel.width, FITHEIGHT (52))];

    // 添加新的view
    [leftView addSubview:view];
}

/**
 * 对所有标题的label重新布局，根据label中的内容自适应大小
 */
- (void)resetTitleLabelLayout
{
    // labelsize的最大值
    CGSize maximumLabelSize = CGSizeMake (320, 124);

    // 左侧标题
    CGSize leftExpectSize = [leftTitleLabel sizeThatFits:maximumLabelSize];
    float leftOffSet = (FITWIDTH (320) - leftExpectSize.width) / 2;
    leftTitleLabel.frame =
    CGRectMake (leftOffSet, FITHEIGHT (82), leftExpectSize.width, leftExpectSize.height);

    // 中间标题
    CGSize middleExpectSize = [middleTitleLabel sizeThatFits:maximumLabelSize];
    float middleOffSet = (FITWIDTH (320) - middleExpectSize.width) / 2;
    middleTitleLabel.frame =
    CGRectMake (middleOffSet, FITHEIGHT (82), middleExpectSize.width, middleExpectSize.height);

    // 右侧标题
    CGSize rightExpectSize = [rightTitleLabel sizeThatFits:maximumLabelSize];
    float rightOffSet = (FITWIDTH (320) - rightExpectSize.width) / 2;
    rightTitleLabel.frame =
    CGRectMake (rightOffSet, FITHEIGHT (82), rightExpectSize.width, rightExpectSize.height);
}

/**
 * 对左侧的label重新布局，根据label中的内容自适应大小
 */
- (void)resetValueLabelLayout
{
    // 左侧布局
    [self resetLayoutWithValueLabel:leftValueLabel UnitLabel:leftUnitLabel];

    // 中间布局
    [self resetLayoutWithValueLabel:middleValueLabel UnitLabel:middleUnitLabel];

    // 右侧布局
    [self resetLayoutWithValueLabel:rightValueLabel UnitLabel:rightUnitLabel];
}

/**
 * 对label重新布局，根据label中的内容自适应大小
 */
- (void)resetLayoutWithValueLabel:(UILabel *)valueLabel UnitLabel:(UILabel *)unitLabel
{
    // labelsize的最大值
    CGSize maximumLabelSize = CGSizeMake (320, 124);

    // 左侧：获取指标值和单位的高宽
    CGSize valueExpectSize = [valueLabel sizeThatFits:maximumLabelSize];
    float valueWidth = valueExpectSize.width;
    float valueHeight = valueExpectSize.height;
    CGSize unitExpectSize = [unitLabel sizeThatFits:maximumLabelSize];
    float unitWidth = unitExpectSize.width;
    float unitHeight = unitExpectSize.height;

    // 计算左间距，使label居中
    float leftOffset = (FITWIDTH (320) - (valueWidth + unitWidth)) / 2;

    // 设置布局
    valueLabel.frame = CGRectMake (leftOffset, 0, valueWidth, valueHeight);
    unitLabel.frame = CGRectMake (valueLabel.rightX, valueHeight - unitHeight, unitWidth, unitHeight);

    // 设置字体大小和颜色
    [valueLabel setTextColor:valueColor];
    [valueLabel setFont:valueFontSize];
    [unitLabel setTextColor:unitColor];
    [unitLabel setFont:unitFontSize];
}

@end
