//
//  SVLabelTools.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/4/1.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVLabelTools : NSObject

/**
 * 获取可以自动换行的UILabel，如果该label下面还有label，则需要将该label的位置重新调整一下
 */
+ (void)wrapForLabel:(UILabel *)label nextLabel:(UILabel *)nextLabel;

/**
 * 对label重新布局，根据label中的内容自适应大小
 */
+ (void)resetLayoutWithValueLabel:(UILabel *)valueLabel
                        UnitLabel:(UILabel *)unitLabel
                        WithWidth:(double)maxWidth
                       WithHeight:(double)maxHeight
                            WithY:(double)y;
@end
