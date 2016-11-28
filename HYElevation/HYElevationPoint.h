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
@property (nonatomic, assign) double lon;
@property (nonatomic, assign) double lat;

@property (nonatomic, assign) int level;
@property (nonatomic, assign) long fileOffset;
@property (nonatomic, assign) int elevation;

@end
