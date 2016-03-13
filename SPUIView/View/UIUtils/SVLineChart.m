//
//  SVLineChart.m
//  LineChart
//
//  Created by Rain on 3/12/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVLineChart.h"

@implementation SVLineChart
{
    NSMutableArray *_arrays;
    CAShapeLayer *_chartLine;
    CGSize _frameSize;
    CGFloat _frameWidth;
    CGFloat _frameHeight;

    CGPoint lastPoint;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake (0, 0, frame.size.width, frame.size.height)];
    if (self)
    {
        _frameSize = self.frame.size;
        _frameWidth = _frameSize.width;
        _frameHeight = _frameSize.height;
        self.clipsToBounds = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        _arrays = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)addValue:(float)value
{
    [_arrays addObject:[NSString stringWithFormat:@"%.2f", value]];
    [self redraw];
}

- (void)redraw
{
    long pointsNumbers = _arrays.count;

    // 创建layer并设置属性
    CAShapeLayer *_layer = [CAShapeLayer layer];
    _layer.fillColor = [UIColor clearColor].CGColor;
    _layer.lineWidth = 1.0f;
    _layer.lineCap = kCALineCapRound;
    _layer.lineJoin = kCALineJoinRound;
    _layer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:_layer];

    if (pointsNumbers == 1)
    {
        // 第一个点， 即起点
        CGPoint point = CGPointMake (0, _frameHeight);
        [self addPoint:point];

        // 创建贝塞尔路径~
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake (0, _frameHeight)];

        // 第二个点，根据用户设置的数据设置点的位置
        //        NSString *value = _arrays[0];
        long index = _arrays.count;
        NSString *value = _arrays[index - 1];

        NSLog (@"%@ ", value);
        CGPoint point2 = CGPointMake ([self nextPointX:index], [self nextPointY:[value floatValue]]);
        [self addPoint:point2];
        lastPoint = CGPointMake ([self nextPointX:index], [self nextPointY:[value floatValue]]);
        [path addLineToPoint:lastPoint];
        // 关联layer和贝塞尔路径~
        _layer.path = path.CGPath;
        // 动画
        //        CABasicAnimation *ani =
        //        [CABasicAnimation animationWithKeyPath:NSStringFromSelector (@selector
        //        (strokeEnd))];
        //        ani.fromValue = @0;
        //        ani.toValue = @1;
        //        ani.duration = 0.1;
        //        [_layer addAnimation:ani forKey:NSStringFromSelector (@selector (strokeEnd))];
    }
    else
    {
        // 创建贝塞尔路径~
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:lastPoint];
        // 第二个点，根据用户设置的数据设置点的位置
        long index = _arrays.count;
        NSString *value = _arrays[index - 1];

        CGPoint point2 = CGPointMake ([self nextPointX:index], [self nextPointY:[value floatValue]]);
        NSLog (@"%@ ", value);
        [self addPoint:point2];

        lastPoint = CGPointMake ([self nextPointX:index], [self nextPointY:[value floatValue]]);
        [path addLineToPoint:lastPoint];

        // 关联layer和贝塞尔路径~
        _layer.path = path.CGPath;

        // 动画
        //        CABasicAnimation *ani =
        //        [CABasicAnimation animationWithKeyPath:NSStringFromSelector (@selector
        //        (strokeEnd))];
        //        ani.fromValue = @0;
        //        ani.toValue = @1;
        //        ani.duration = 0.1;
        //        [_layer addAnimation:ani forKey:NSStringFromSelector (@selector (strokeEnd))];
    }
}


- (CGFloat)nextPointX:(long)pointIndex
{
    CGFloat one_column_width = _frameWidth / 10;
    return one_column_width * pointIndex;
}

- (CGFloat)nextPointY:(float)value
{
    CGFloat one_row_width = _frameHeight / 100;
    CGFloat height = _frameHeight - one_row_width * value;
    return height;
}


- (void)addPoint:(CGPoint)point
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake (0, 0, 8, 8)];
    view.center = point;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 6;
    view.layer.borderWidth = 1.2;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.backgroundColor = [UIColor redColor];
    [self addSubview:view];
}


@end
