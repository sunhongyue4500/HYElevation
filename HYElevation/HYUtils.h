//
//  HYUtils.h
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYUtils : NSObject

+ (double)distanceBetween:(double)lon1 lat1:(double)lat1 andlon2:(double)lon2 lat2:(double)lat2;
+ (double)altitudeAdvisor;
+ (BOOL)getX:(double *)x Y:(double *)y withPoint1:(CGPoint)point1 point2:(CGPoint)point2 withLineY:(double)yLine;

double convert2Radin(double deg);
double convert2Deg(double rad);

@end
