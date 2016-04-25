//
//  SVLineChart.h
//  LineChart
//
//  Created by Rain on 3/12/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVLineChart : UIView


- (id)initWithFrame:(CGRect)frame maxY:(float)maxY;

- (void)addValue:(float)value;

@end
