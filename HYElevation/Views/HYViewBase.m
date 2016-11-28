//
//  HYViewBase.m
//  HYElevation
//
//  Created by Sunhy on 16/11/23.
//  Copyright © 2016年 Sunhy. All rights reserved.

#import "HYViewBase.h"

@interface HYViewBase ()

@property (nonatomic,assign)CGFloat offsetLeft;
@property (nonatomic,assign)CGFloat offsetTop;
@property (nonatomic,assign)CGFloat offsetRight;
@property (nonatomic,assign)CGFloat offsetBottom;

@end

@implementation HYViewBase

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addObserver];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver];
    }
    return self;
}

- (void)addObserver {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)layoutSubviews{
    CGRect  bounds = self.bounds;
    if ((bounds.size.width != self.chartWidth ||
         bounds.size.height != self.chartHeight))
    {
        [self setChartDimens:bounds.size.width height:bounds.size.height];
        [self notifyDataSetChanged];
    }
}

- (void) deviceOrientationDidChange:(NSNotification *) notification
{
    if([UIDevice currentDevice].orientation!=UIDeviceOrientationUnknown)
    {
        [self notifyDeviceOrientationChanged];
    }
}

- (void)notifyDeviceOrientationChanged
{
    
}

- (void)notifyDataSetChanged
{
    [self setNeedsDisplay];
    
}

- (void)setupChartOffsetWithLeft:(CGFloat)left top:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom
{
    self.offsetLeft = left;
    self.offsetRight = right;
    self.offsetTop = top;
    self.offsetBottom = bottom;
    [self restrainViewPort:left top:top right:right bottom:bottom];
}

- (void)setChartDimens:(CGFloat)width
                height:(CGFloat)height
{
    CGFloat offsetLeft = self.offsetLeft;
    CGFloat offsetTop = self.offsetTop;
    CGFloat offsetRight = self.offsetRight;
    CGFloat offsetBottom = self.offsetBottom;
    self.chartHeight = height;
    self.chartWidth = width;
    [self restrainViewPort:offsetLeft top:offsetTop right:offsetRight bottom:offsetBottom];
}

- (void)restrainViewPort:(CGFloat)offsetLeft
                     top:(CGFloat)offsetTop
                   right:(CGFloat)offsetRight
                  bottom:(CGFloat)offsetBottom
{
    _contentRect.origin.x = offsetLeft;
    _contentRect.origin.y = offsetTop;
    _contentRect.size.width = self.chartWidth - offsetLeft - offsetRight;
    _contentRect.size.height = self.chartHeight - offsetBottom - offsetTop;
}


- (BOOL)isInBoundsX:(CGFloat)x
{
    if ([self isInBoundsLeft:x] && [self isInBoundsRight:x])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isInBoundsY:(CGFloat)y
{
    if ([self isInBoundsTop:y] &&[self isInBoundsBottom:y])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isInBoundsX:(CGFloat)x y:(CGFloat)y
{
    if ([ self isInBoundsX:x] && [self isInBoundsY:y])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isInBoundsLeft:(CGFloat)x
{
    return _contentRect.origin.x <= x ? YES : NO;
}

- (BOOL)isInBoundsRight:(CGFloat)x
{
    CGFloat normalizedX = ((NSInteger)(x * 100.f))/100.f;
    return (_contentRect.origin.x + _contentRect.size.width) >= normalizedX ? YES : NO;
}

- (BOOL)isInBoundsTop:(CGFloat)y
{
    return _contentRect.origin.y <= y ? YES : NO;
}

- (BOOL)isInBoundsBottom:(CGFloat)y
{
    CGFloat normalizedY = ((NSInteger)(y * 100.f))/100.f;
    return (_contentRect.origin.y + _contentRect.size.height) >= normalizedY ? YES : NO;
    
}

- (CGFloat)contentTop
{
    return _contentRect.origin.y;
}

- (CGFloat)contentLeft
{
    return _contentRect.origin.x;
}

- (CGFloat)contentRight
{
    return _contentRect.origin.x + _contentRect.size.width;
}

- (CGFloat)contentBottom
{
    return _contentRect.origin.y + _contentRect.size.height;
}

- (CGFloat)contentWidth
{
    return _contentRect.size.width;
}

- (CGFloat)contentHeight
{
    return _contentRect.size.height;
}

/** rect2 intersection rect1 in X-axis*/
BOOL isXIntersectionWithRect(CGRect rect2, CGRect rect1) {
    if (rect2.origin.x >= rect1.origin.x && rect2.origin.x <= rect1.origin.x + rect1.size.width ) return YES;
    if (rect1.origin.x >= rect2.origin.x && rect1.origin.x <= rect2.origin.x + rect2.size.width ) return YES;
    return NO;
}

@end
