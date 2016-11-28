//
//  HYElevationPoint.m
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import "HYElevationPoint.h"

@interface HYElevationPoint () <NSCoding>

@end

@implementation HYElevationPoint

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.elevationPointName forKey:@"elevationPointName"];
    [encoder encodeInt:self.index forKey:@"index"];
    [encoder encodeDouble:self.lon forKey:@"lon"];
    [encoder encodeDouble:self.lat forKey:@"lat"];
    [encoder encodeInt:self.level forKey:@"level"];
    [encoder encodeInteger:self.fileOffset forKey:@"fileOffset"];
    [encoder encodeInt:self.elevation forKey:@"elevation"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self.elevationPointName = [decoder decodeObjectForKey:@"elevationPointName"];
    self.index = [decoder decodeIntForKey:@"index"];
    self.lon = [decoder decodeDoubleForKey:@"lon"];
    self.lat = [decoder decodeDoubleForKey:@"lat"];
    self.level = [decoder decodeIntForKey:@"level"];
    self.fileOffset = [decoder decodeIntegerForKey:@"fileOffset"];
    self.elevation = [decoder decodeIntForKey:@"elevation"];
    return self;
}


@end
