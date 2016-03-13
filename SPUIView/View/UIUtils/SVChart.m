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
}

- (id)initWithView:(UIView *)showOnView
{
    CGSize size = showOnView.frame.size;
    self = [super initWithFrame:CGRectMake (0, 0, size.width, size.height)];
    if (self)
    {
        self.clipsToBounds = YES;
        _lineChart = [[SVLineChart alloc] initWithFrame:self.frame];
        [self addSubview:_lineChart];
        [showOnView addSubview:self];
    }

    return self;
}

- (void)addValue:(float)value
{
    [_lineChart addValue:value];
}


@end
