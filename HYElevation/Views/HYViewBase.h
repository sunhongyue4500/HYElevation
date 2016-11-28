//
//  HYViewBase.h
//  HYElevation
//
//  Created by Sunhy on 16/11/23.
//  Copyright © 2016年 Sunhy. All rights reserved.

#import <UIKit/UIKit.h>

@interface HYViewBase : UIView

@property (nonatomic,assign) CGRect contentRect;
@property (nonatomic,assign) CGFloat chartHeight;
@property (nonatomic,assign) CGFloat chartWidth;

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

BOOL isXIntersectionWithRect(CGRect rect2, CGRect rect1);

- (CGFloat)contentTop;
- (CGFloat)contentLeft;
- (CGFloat)contentRight;
- (CGFloat)contentBottom;
- (CGFloat)contentWidth;
- (CGFloat)contentHeight;


@end
