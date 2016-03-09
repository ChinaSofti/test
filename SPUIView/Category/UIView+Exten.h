//
//  UIView+Exten.h
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

/**
 *  自定义分类
 */

#import <UIKit/UIKit.h>

@interface UIView (Exten)
// x
@property (nonatomic) CGFloat originX;
// y
@property (nonatomic) CGFloat originY;
//右x
@property (nonatomic) CGFloat rightX;
//底y
@property (nonatomic) CGFloat bottomY;
//宽
@property (nonatomic) CGFloat width;
//高
@property (nonatomic) CGFloat height;
//中心x
@property (nonatomic) CGFloat centerX;
//中心y
@property (nonatomic) CGFloat centerY;
//包含xy
@property (nonatomic) CGPoint origin;
//包含宽高
@property (nonatomic) CGSize size;
@end
