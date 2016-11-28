//
//  HYElevationPoint.h
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYElevationPoint : NSObject

@property (nonatomic, copy) NSString *elevationPointName;

@property (nonatomic, assign) int index;
/** longtitude(deg)*/
@property (nonatomic, assign) double lon;
/** latitude(deg)*/
@property (nonatomic, assign) double lat;

@property (nonatomic, assign) int level;
@property (nonatomic, assign) long fileOffset;
/** elevation(m)*/
@property (nonatomic, assign) int elevation;

@end
