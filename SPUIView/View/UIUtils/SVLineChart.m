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

    CGFloat _maxY;
    NSMutableArray *_pathArrays;
    NSMutableArray *_heightArrays;
}

- (id)initWithFrame:(CGRect)frame maxY:(float)maxY
{
    self = [super initWithFrame:CGRectMake (0, 0, frame.size.width, frame.size.height - 10)];
    if (self)
    {
        _frameSize = self.frame.size;
        _frameWidth = _frameSize.width;
        _frameHeight = _frameSize.height;
        self.clipsToBounds = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        _arrays = [[NSMutableArray alloc] init];

        _maxY = maxY;
        _pathArrays = [[NSMutableArray alloc] init];
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
    //    _layer.strokeColor = [UIColor redColor].CGColor;
    _layer.strokeColor = [UIColor colorWithHexString:@"#F54D2D"].CGColor;
    [self.layer insertSublayer:_layer atIndex:0];

    //绘制渐变色层
    CAGradientLayer *colorLayer = [CAGradientLayer layer];
    colorLayer.frame = self.frame;
    colorLayer.colors = @[
        (__bridge id)[UIColor colorWithHexString:@"#FEDDBD"]
        .CGColor,
        (__bridge id)[UIColor colorWithHexString:@"#FEDDBD" alpha:0.0].CGColor
    ];
    colorLayer.locations = @[@0.0, @1.0];
    [self.layer insertSublayer:colorLayer atIndex:0];

    CAShapeLayer *arc = [CAShapeLayer layer];
    colorLayer.mask = arc;

    if (pointsNumbers == 1)
    {
        // 第一个点， 即起点
        CGPoint point = CGPointMake (0, _frameHeight);
        [self addPoint:point];

        // 创建贝塞尔路径~
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake (0, _frameHeight)];

        // 添加原点
        [self labelWithFrame:self.frame index:0];

        // 第二个点，根据用户设置的数据设置点的位置
        //        NSString *value = _arrays[0];
        long index = _arrays.count;
        NSString *value = _arrays[index - 1];

        [self labelWithFrame:self.frame index:(int)index];

        NSLog (@"%@ ", value);
        CGPoint point2 = CGPointMake ([self nextPointX:index], [self nextPointY:[value floatValue]]);
        [self addPoint:point2];

        UIBezierPath *colorPath =
        [self createPathWithFirstPoint:CGPointMake (0, _frameHeight) SecondPoint:point2];
        arc.path = colorPath.CGPath;
        [_pathArrays addObject:colorPath];

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

        [self labelWithFrame:self.frame index:(int)index];

        CGPoint point2 = CGPointMake ([self nextPointX:index], [self nextPointY:[value floatValue]]);
        NSLog (@"%@ ", value);
        [self addPoint:point2];

        UIBezierPath *colorPath = [self createPathWithFirstPoint:lastPoint SecondPoint:point2];
        arc.path = colorPath.CGPath;

        [_pathArrays addObject:colorPath];

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
    CGFloat one_row_width = _frameHeight / _maxY;
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
    view.backgroundColor = [UIColor colorWithHexString:@"#F54D2D"];
    [self addSubview:view];
}

// 创建X轴间距值 label
- (void)labelWithFrame:(CGRect)frame index:(int)index
{
    CGFloat x = (frame.origin.x - 4) + index * (_frameWidth / 10);
    if (index == 0)
    {
        x = x + 2;
    }
    else if (index == 10)
    {
        x = x - 4;
    }
    CGFloat y = frame.size.height;
    CGFloat w = 10;
    CGFloat h = 10;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake (x, y, w, h)];
    label.text = [NSString stringWithFormat:@"%d", index];
    label.textColor = [UIColor colorWithHexString:@"#F54D2D"];
    label.font = [UIFont systemFontOfSize:8];
    label.textAlignment = NSTextAlignmentCenter;
    [self.superview addSubview:label];
}

// 每一秒添加背景颜色
- (UIBezierPath *)createPathWithFirstPoint:(CGPoint)firstP SecondPoint:(CGPoint)secondP
{
    UIBezierPath *path = [UIBezierPath bezierPath];

    [path moveToPoint:firstP]; //第一个点
    [path addLineToPoint:secondP]; //第二个点

    [path addLineToPoint:CGPointMake (secondP.x, self.frame.size.height)]; //第三个点
    [path addLineToPoint:CGPointMake (firstP.x, self.frame.size.height)]; //第四个点
    [path closePath];

    return path;
}

@end
