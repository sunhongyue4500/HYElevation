//
//  HYElevationPoint.h
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HYElevationPoint : NSObject

@property (nonatomic, copy) NSString *elevationPointName;

@property (nonatomic, assign) NSUInteger index;
/** longtitude(deg)*/
@property (nonatomic, assign) CGFloat lon;
/** latitude(deg)*/
@property (nonatomic, assign) CGFloat lat;

@property (nonatomic, assign) NSUInteger level;
@property (nonatomic, assign) NSUInteger fileOffset;
/** elevation(m)*/
@property (nonatomic, assign) NSInteger elevation;

@end
