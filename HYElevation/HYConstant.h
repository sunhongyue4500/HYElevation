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

static const double EARTH_RADIUS = 6378.137;

#pragma mark - **************** Elevation
static int const ElEVATION_SAMPLE_COUNT = 200;
static int const RULER_ELEVATION_SAMPLE_COUNT = 200;
static int const ElEVATION_UNAVAILABLE_VALUE = 10000;
static int const AREACHARTVIEW_MIN_WIDTH = 768;
/** Altitude Advisor button偏移*/
static float const ElEVATION_CHART_ALTITUDE_ADVISOR_OFFSET = 18.0;
/** first strike 变红阈值 km*/
static float const ElEVATION_CHART_RIGHT_LABEL_STRIKE_RED_WARN = 100.0;

/** Elevation Setting*/
static int const redWarnDefaultValue = 30;
static int const yellowWarnDefaultValue = 300;
static float const elevationSettingViewWidth = 240;
static float const elevationSettingViewHeight = 300;

#pragma mark - **************** Elevation Rectangle
/** 高程Rectangle 边宽度*/
static float const ElEVATION_RECTANGLE_WIDTH = 40.0;
