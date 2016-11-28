//
//  HYUtils.m
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYUtils.h"
#import "HYConstant.h"


@implementation HYUtils

/**
 *  calculate two position distance 参考：http://www.movable-type.co.uk/scripts/latlong.html
 *
 *  @param lon1 lon1(deg)
 *  @param lat1 lat1(deg)
 *  @param lon2 lon2(deg)
 *  @param lat2 lat2(deg)
 *
 *  @return great circle distance(km)
 */
+ (double)distanceBetween:(double)lon1 lat1:(double)lat1 andlon2:(double)lon2 lat2:(double)lat2 {
    /*
     a = sin²(Δφ/2) + cos φ1 ⋅ cos φ2 ⋅ sin²(Δλ/2)
     c = 2 ⋅ atan2( √a, √(1−a) )
     d = R ⋅ c
     */
    double FI1 = convert2Radin(lat1);
    double FI2 = convert2Radin(lat2);
    double deltFI = convert2Radin(lat2 - lat1);
    double deltLamda = convert2Radin(lon2 - lon1);
    double a = sin(deltFI/2) * sin(deltFI/2) + cos(FI1)*cos(FI2) * sin(deltLamda/2) * sin(deltLamda/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    return EARTH_RADIUS * c;
}

double convert2Radin(double deg) {
    return deg * M_PI / 180;
}

double convert2Deg(double rad) {
    return rad * 180 / M_PI;
}

+ (double)altitudeAdvisor {
    return 1000.0;
}

/**
 intersection point of line(point1 to point2) and line yLine
 
 @param x x coordinate return
 @param y y coordinate returnq
 @param point1 point1
 @param point2 point2
 @param yLine  line y = yline
 @return YES indicates theres is a intersection point
 */
+ (BOOL)getX:(double *)x Y:(double *)y withPoint1:(CGPoint)point1 point2:(CGPoint)point2 withLineY:(double)yLine {
    double minY = (point1.y <= point2.y ? point1.y : point2.y);
    double maxY = (point1.y >= point2.y ? point1.y : point2.y);
    if (yLine < minY || yLine > maxY) return NO;
    
    if (point2.y - point1.y == 0) {
        if (point1.y != yLine) return NO;
        else {
            *x = point1.x;
            *y = yLine;
            return YES;
        }
    }
    *x = (point2.x -point1.x) * (yLine - point1.y) / (point2.y - point1.y) + point1.x;
    *y = yLine;
    return YES;
}


@end
