//
//  CTWBLabel.m
//  SpeedPro
//
//  Created by WBapple on 16/5/17.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import "CTWBLabel.h"

@implementation CTWBLabel
/**
 *  重写父类text方法
 *
 *  @param rect 文字描边
 */
- (void)drawTextInRect:(CGRect)rect
{
    //描边
    CGContextRef c = UIGraphicsGetCurrentContext ();
    CGContextSetLineWidth (c, 10);
    CGContextSetLineJoin (c, kCGLineJoinRound);
    CGContextSetTextDrawingMode (c, kCGTextStroke);
    //描边颜色
    self.textColor = [UIColor colorWithHexString:@"#29a5e5"];
    [super drawTextInRect:rect];
    //文字颜色
    self.textColor = [UIColor colorWithHexString:@"#ffb901"];
    CGContextSetTextDrawingMode (c, kCGTextFill);
    [super drawTextInRect:rect];
}
@end