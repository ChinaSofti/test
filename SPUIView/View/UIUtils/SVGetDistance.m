//
//  SVGetDistance.m
//  SpeedPro
//
//  Created by Rain on 3/21/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVGetDistance.h"

#define rad(d) d *M_PI / 180.0

@implementation SVGetDistance

//地球半径, 单位千米
const double EARTH_RADIUS = 6378.137;


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
+ (double)getDistance:(double)lat lon:(double)lon lat2:(double)lat2 lon2:(double)lon2
{
    double radLat1 = rad (lat);
    double radLat2 = rad (lat2);
    double a = radLat1 - radLat2;
    double b = rad (lon) - rad (lon2);
    double s =
    2 * asin (sqrt (pow (sin (a / 2), 2) + cos (radLat1) * cos (radLat2) * pow (sin (b / 2), 2)));
    s = s * EARTH_RADIUS;
    s = round (s * 10000) / 10000;
    return s;
}

@end
