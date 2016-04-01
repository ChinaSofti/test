//
//  SVHeaderView.h
//  SpeedPro
//
//  Created by WBapple on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVHeaderView : UIView

//初始化方法
- (instancetype)initWithDic:(NSMutableDictionary *)dic;

/**
 * 将左侧的labe换成view
 */
- (void)replaceLeftLabelWithView:(UIView *)view;

/**
 * 更新左侧的label内容
 */
- (void)updateLeftValue:(NSString *)value;

/**
 * 更新中间的label内容
 */
- (void)updateMiddleValue:(NSString *)value;

/**
 * 更新右侧的label内容
 */
- (void)updateRightValue:(NSString *)value;

/**
 * 更新左侧的label内容
 */
- (void)updateLeftValue:(NSString *)value WithUnit:(NSString *)unit;

/**
 * 更新中间的label内容
 */
- (void)updateMiddleValue:(NSString *)value WithUnit:(NSString *)unit;

/**
 * 更新右侧的label内容
 */
- (void)updateRightValue:(NSString *)value WithUnit:(NSString *)unit;
@end
