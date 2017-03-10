//
//  HYUtils.h
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYUtils : NSObject

+ (CGFloat)distanceBetween:(CGFloat)lon1 lat1:(CGFloat)lat1 andlon2:(CGFloat)lon2 lat2:(CGFloat)lat2;
+ (CGFloat)altitudeAdvisor;
+ (BOOL)getX:(CGFloat *)x Y:(CGFloat *)y withPoint1:(CGPoint)point1 point2:(CGPoint)point2 withLineY:(CGFloat)yLine;

CGFloat convert2Radin(CGFloat deg);
CGFloat convert2Deg(CGFloat rad);

@end
