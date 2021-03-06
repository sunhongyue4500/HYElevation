//
//  Constant.h
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import "HYColorConstant.h"
#import "HYFontConstant.h"
#import "HYStringConstant.h"

static const CGFloat EARTH_RADIUS = 6378.137;

#pragma mark - **************** Elevation

/** first strike turn red value km*/
static CGFloat const ElEVATION_CHART_RIGHT_LABEL_STRIKE_RED_WARN = 100.0;
/** Elevation Setting*/
static NSUInteger const redWarnDefaultValue = 30;
static NSUInteger const yellowWarnDefaultValue = 300;

static CGFloat const ELEVATION_CHART_REAL_LINE_DISTANCE = 7;
static CGFloat const ELEVATION_CHART_DSSH_LINE_DISTANCE = 3;

#pragma mark - **************** Altitude Advisor Btn
/** Altitude Advisor button x-axis offset*/
static CGFloat const ElEVATION_CHART_ALTITUDE_ADVISOR_OFFSET = 18.0;
static NSUInteger const ALTITUDE_ADVISOR_BTN_WIDTH = 54;
static NSUInteger const ALTITUDE_ADVISOR_BTN_HEIGHT = 24;
