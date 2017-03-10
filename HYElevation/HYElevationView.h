//
//  HYElevationView.h
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import "HYChartViewBase.h"

@class  HYChartDataSet;
@interface HYElevationView : HYChartViewBase

/** 矩形块的默认宽度, 理解为比例尺*/
@property (nonatomic, assign) CGFloat candleWidth;
/** 矩形块的最大宽度*/
@property (nonatomic, assign) CGFloat candleMaxWidth;
/** 矩形块的最小宽度*/
@property (nonatomic, assign) CGFloat candleMinWidth;
/** 底部矩形框的高度*/
@property (nonatomic, assign) CGFloat bottomRectHeight;
/** edit模式下设置的高度*/
@property (nonatomic, assign) CGFloat altitudeAdvisor;
/** altitude advisor 黄色色报警间距)(m)*/
@property (nonatomic, assign) NSUInteger yellowWarning;
/** altitude advisor 红色报警间距(m)*/
@property (nonatomic, assign) NSUInteger redWarning;
/** 最高点的值*/
@property (nonatomic, assign, readonly) CGFloat highestPointValue;
/** 间隙*/
@property (nonatomic, assign, readonly) CGFloat clearanceValue;
/** 第一次碰撞的索引，考虑飞行安全，应使用firstStrikeIndex - 1*/
@property (nonatomic, assign, readonly) NSInteger firstStrikeIndex;

- (void)adjustCandleMinWidth;
- (void)setupData:(NSArray *)data;
- (NSArray *)dataSetData;

@end
