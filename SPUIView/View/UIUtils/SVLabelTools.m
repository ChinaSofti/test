//
//  SVLabelTools.m
//  SpeedPro
//
//  Created by 徐瑞 on 16/4/1.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "SVLabelTools.h"

@implementation SVLabelTools

/**
 * 获取可以自动换行的UILabel，如果该label下面还有label，则需要将该label的位置重新调整一下
 */
+ (void)wrapForLabel:(UILabel *)label nextLabel:(UILabel *)nextLabel
{
    // 初始化
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    double bottomY = label.bottomY;


    // 设置自适应
    CGSize size = [label sizeThatFits:CGSizeMake (label.frame.size.width, label.frame.size.height)];
    label.frame = CGRectMake (label.frame.origin.x, label.frame.origin.y, label.frame.size.width, size.height);

    if (nextLabel)
    {
        // 调整下面label的位置
        CGRect oldFrame = nextLabel.frame;
        double offsetY = oldFrame.origin.y - bottomY;

        nextLabel.frame =
        CGRectMake (oldFrame.origin.x, label.bottomY + offsetY, oldFrame.size.width, oldFrame.size.height);
    }
}

/**
 * 对label重新布局，根据label中的内容自适应大小
 */
+ (void)resetLayoutWithValueLabel:(UILabel *)valueLabel
                        UnitLabel:(UILabel *)unitLabel
                        WithWidth:(double)maxWidth
                       WithHeight:(double)maxHeight
{
    // labelsize的最大值
    CGSize maximumLabelSize = CGSizeMake (maxWidth, maxHeight);

    // 左侧：获取指标值和单位的高宽
    CGSize valueExpectSize = [valueLabel sizeThatFits:maximumLabelSize];
    float valueWidth = valueExpectSize.width;
    float valueHeight = valueExpectSize.height;
    CGSize unitExpectSize = [unitLabel sizeThatFits:maximumLabelSize];
    float unitWidth = unitExpectSize.width;
    float unitHeight = unitExpectSize.height;

    // 计算左间距，使label居中
    float leftOffset = (maxWidth - (valueWidth + unitWidth)) / 2;
    float topOffset = (maxHeight - valueHeight) / 2;

    // 设置布局
    valueLabel.frame = CGRectMake (leftOffset, topOffset, valueWidth, valueHeight);
    unitLabel.frame =
    CGRectMake (valueLabel.rightX, topOffset + (valueHeight - unitHeight), unitWidth, unitHeight);
}

/**
 * 对label重新布局，根据label中的内容自适应大小
 */
+ (void)resetLayoutWithValueLabel:(UILabel *)valueLabel
                        UnitLabel:(UILabel *)unitLabel
                        WithWidth:(double)maxWidth
                       WithHeight:(double)maxHeight
                            WithY:(double)y
{
    // labelsize的最大值
    CGSize maximumLabelSize = CGSizeMake (maxWidth, maxHeight);

    // 左侧：获取指标值和单位的高宽
    CGSize valueExpectSize = [valueLabel sizeThatFits:maximumLabelSize];
    float valueWidth = valueExpectSize.width;
    float valueHeight = valueExpectSize.height;
    CGSize unitExpectSize = [unitLabel sizeThatFits:maximumLabelSize];
    float unitWidth = unitExpectSize.width;
    float unitHeight = unitExpectSize.height;

    // 计算左间距，使label居中
    float leftOffset = (maxWidth - (valueWidth + unitWidth)) / 2;

    // 设置布局
    valueLabel.frame = CGRectMake (leftOffset, y, valueWidth, valueHeight);
    unitLabel.frame = CGRectMake (valueLabel.rightX, y + (valueHeight - unitHeight), unitWidth, unitHeight);
}

/**
 * 对label重新布局，根据label中的内容自适应大小
 */
+ (void)resetLayoutWithTitleLabel:(UILabel *)titleLabel
                        WithWidth:(double)maxWidth
                       WithHeight:(double)maxHeight
{
    // labelsize的最大值
    CGSize maximumLabelSize = CGSizeMake (maxWidth, maxHeight);

    // 左侧：获取指标值和单位的高宽
    CGSize titleExpectSize = [titleLabel sizeThatFits:maximumLabelSize];
    float titleWidth = titleExpectSize.width;
    float titleHeight = titleExpectSize.height;

    // 计算左间距，使label居中
    float leftOffset = (maxWidth - titleWidth) / 2;
    float topOffset = (maxHeight - titleHeight) / 2;

    // 设置布局
    titleLabel.frame = CGRectMake (leftOffset, topOffset, titleWidth, titleHeight);
}

/**
 * 对label重新布局，根据label中的内容自适应大小
 */
+ (void)resetLayoutWithTitleLabel:(UILabel *)titleLabel
                        WithWidth:(double)maxWidth
                       WithHeight:(double)maxHeight
                            WithY:(double)y
{
    // labelsize的最大值
    CGSize maximumLabelSize = CGSizeMake (maxWidth, maxHeight);

    // 左侧：获取指标值和单位的高宽
    CGSize titleExpectSize = [titleLabel sizeThatFits:maximumLabelSize];
    float titleWidth = titleExpectSize.width;
    float titleHeight = titleExpectSize.height;

    // 计算左间距，使label居中
    float leftOffset = (maxWidth - titleWidth) / 2;

    // 设置布局
    titleLabel.frame = CGRectMake (leftOffset, y, titleWidth, titleHeight);
}

@end
