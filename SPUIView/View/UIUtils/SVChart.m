//
//  SVChart.m
//  LineChart
//
//  Created by Rain on 3/13/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVChart.h"

@implementation SVChart
{
    SVLineChart *_lineChart;

    NSMutableArray *_arrays;
    CGFloat _maxY;
}

- (id)initWithView:(UIView *)showOnView
{
    CGSize size = showOnView.frame.size;
    self = [super initWithFrame:CGRectMake (0, 0, size.width, size.height)];
    if (self)
    {
        _maxY = 0.1;
        self.clipsToBounds = YES;
        _lineChart = [[SVLineChart alloc] initWithFrame:self.frame maxY:_maxY];
        [self addSubview:_lineChart];
        [showOnView addSubview:self];

        _arrays = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)addValue:(float)value
{
    [_lineChart addValue:value];

    [_arrays addObject:[NSString stringWithFormat:@"%f", value]];

    if (_maxY * 0.8 < value)
    {
        _maxY = value / 0.8;
        for (UIView *view in self.subviews)
        {
            [view removeFromSuperview];
        }
        _lineChart = [[SVLineChart alloc] initWithFrame:self.frame maxY:_maxY];
        [self addSubview:_lineChart];
        for (int i = 0; i < _arrays.count; i++)
        {
            [_lineChart addValue:[_arrays[i] floatValue]];
        }
    }
}


@end
