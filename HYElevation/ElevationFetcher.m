//
//  ElevationFetcher.m
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import "ElevationFetcher.h"
#import "HYElevationPoint.h"

@implementation ElevationFetcher

+ (NSArray *)fetchTestElevationPointsData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"elevationData" ofType:@"archive"];
    NSArray *testData=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
    HYElevationPoint *temp;
    for (NSUInteger i=0; i < testData.count; i++) {
        temp = (HYElevationPoint *)testData[i];
        if (i == 60) temp.elevationPointName = @"aPoint";
        else if (i == 120) temp.elevationPointName = @"otherPoint";
    }
    return testData;
}

@end
