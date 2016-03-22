//
//  SVGetDistance.h
//  SpeedPro
//
//  Created by Rain on 3/21/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVGetDistance : NSObject

/**
 *  计算两个坐标经纬度
 *  参考：http://www.cnblogs.com/ycsfwhh/archive/2010/12/20/1911232.html
 *
 *  @param lat  A点纬度
 *  @param lon  A点经度
 *  @param lat2 B点纬度
 *  @param lon2 B点经度
 *
 *  @return 两个坐标距离
 */
+ (double)getDistance:(double)lat lon:(double)lon lat2:(double)lat2 lon2:(double)lon2;

@end
