//
//  UUBar.m
//  UUChartDemo
//
//  Created by Rain on 2/12/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "UUBar.h"
//#import "UUChartConst.h"

@implementation UUBar
{

    CAShapeLayer *_chartLine;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        _chartLine = [CAShapeLayer layer];
        _chartLine.lineCap = kCALineCapSquare;
        _chartLine.fillColor = [UIColor whiteColor].CGColor;
        _chartLine.lineWidth = self.frame.size.width;
        _chartLine.strokeEnd = 0.0;
        [self.layer addSublayer:_chartLine];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 2.0;
    }
    return self;
}

- (void)setBarValue:(float)barValue
{
    UIBezierPath *progressline = [UIBezierPath bezierPath];
    [progressline moveToPoint:CGPointMake (self.frame.size.width / 2.0, self.frame.size.height * 2)];
    [progressline
    addLineToPoint:CGPointMake (self.frame.size.width / 2.0, self.frame.size.height - (barValue * 6))];
    [progressline setLineWidth:1.0];
    [progressline setLineCapStyle:kCGLineCapSquare];
    _chartLine.path = progressline.CGPath;
    _chartLine.strokeColor = [UIColor orangeColor].CGColor;
    _chartLine.strokeEnd = 2.0;
}

@end
