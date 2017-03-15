//
//  HYViewBase.h
//  HYElevation
//
//  Created by Sunhy on 16/11/23.
//  Copyright © 2016年 Sunhy. All rights reserved.

#import <UIKit/UIKit.h>

@interface HYViewBase : UIView

/** 内容rect*/
@property (nonatomic, assign) CGRect contentRect;
/** 图表高*/
@property (nonatomic, assign) CGFloat chartHeight;
/** 图表宽*/
@property (nonatomic, assign) CGFloat chartWidth;

- (void)setupChartOffsetWithLeft:(CGFloat)left
                             top:(CGFloat)top
                           right:(CGFloat)right
                          bottom:(CGFloat)bottom;

- (void)notifyDataSetChanged;
- (void)notifyDeviceOrientationChanged;

- (BOOL)isInBoundsX:(CGFloat)x;
- (BOOL)isInBoundsY:(CGFloat)y;
- (BOOL)isInBoundsX:(CGFloat)x y:(CGFloat)y;

- (BOOL)isInBoundsLeft:(CGFloat)x;
- (BOOL)isInBoundsRight:(CGFloat)x;
- (BOOL)isInBoundsTop:(CGFloat)y;
- (BOOL)isInBoundsBottom:(CGFloat)y;

/** 内容的最顶坐标*/
- (CGFloat)contentTop;
- (CGFloat)contentLeft;
- (CGFloat)contentRight;
- (CGFloat)contentBottom;
- (CGFloat)contentWidth;
- (CGFloat)contentHeight;

BOOL isXIntersectionWithRect(CGRect rect2, CGRect rect1);

@end
