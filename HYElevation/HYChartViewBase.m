//
//  HYChartViewBase.m
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import "HYChartViewBase.h"

@implementation HYChartViewBase

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)drawGridBackground:(CGContextRef)context rect:(CGRect)rect {
    UIColor * backgroundColor = self.gridBackgroundColor?:[UIColor whiteColor];
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    // draw border
    CGContextSetLineWidth(context, self.borderWidth);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextStrokeRect(context, CGRectMake(self.contentLeft, self.contentTop, self.contentWidth, self.contentHeight));
}

- (void)drawHighlighted:(CGContextRef)context point:(CGPoint)point circleColor:(UIColor *)circleColor lineColor:(UIColor *)lineColor lineWidth:(CGFloat)lineWidth {
    [self drawDashline:context startPoint:CGPointMake(point.x, self.contentBottom) stopPoint:CGPointMake(point.x, self.contentTop) color:lineColor lineWidth:0.8 realDistance:7 dashDistance:3 horizonFlag:NO];
    CGFloat radius = 5.0;
    [self drawCirclePoint:context point:CGPointMake(point.x - (radius / 2.0), point.y - (radius / 2.0)) radius:radius color:circleColor];
}

- (void)drawLabel:(CGContextRef)context attributesText:(NSAttributedString *)attributesText rect:(CGRect)rect {
    [attributesText drawInRect:rect];
}

- (void)drawRect:(CGContextRef)context rect:(CGRect)rect color:(UIColor*)color {
    if ((rect.origin.x + rect.size.width) > self.contentRight) {
        return;
    }
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
}

- (void)drawRect:(CGContextRef)context rect:(CGRect)rect fillColor:(UIColor*)fillColor borderColor:(UIColor*)borederColor isFill:(BOOL)flag {
    CGContextSetStrokeColorWithColor(context, borederColor.CGColor);
    CGContextStrokeRectWithWidth(context, rect, 0.8);
    if (flag) {
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        CGContextFillRect(context, rect);
    }
}

- (void)drawPath:(CGContextRef)context fillColor:(UIColor*)fillColor points:(NSArray *)array {
    if (!array || array.count < 2) return;
    CGPoint startPoint = [array[0] CGPointValue];
    CGPoint endPoint = [array[array.count-1] CGPointValue];
    if (startPoint.x != endPoint.x || startPoint.y != endPoint.y) return;
    
    CGPoint currentPoint;
    
    CGContextBeginPath(context);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    for (NSUInteger i=1; i<array.count; i++) {
        currentPoint = [array[i] CGPointValue];
        CGContextAddLineToPoint(context, currentPoint.x,currentPoint.y);
    }
    CGContextFillPath(context);
}

- (void)drawPath:(CGContextRef)context fillColor:(UIColor*)fillColor points:(NSArray *)array clipRect:(CGRect)rect {
    if (!array || array.count < 2) return;
    CGPoint startPoint = [array[0] CGPointValue];
    
    CGPoint currentPoint;
    
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    
    // Clip Path
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    for (NSUInteger i=1; i<array.count; i++) {
        currentPoint = [array[i] CGPointValue];
        CGContextAddLineToPoint(context, currentPoint.x,currentPoint.y);
    }
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}



-(void)drawCirclePoint:(CGContextRef)context point:(CGPoint)point radius:(CGFloat)radius color:(UIColor*)color{
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(point.x, point.y, radius, radius));
}

- (void)drawline:(CGContextRef)context startPoint:(CGPoint)startPoint stopPoint:(CGPoint)stopPoint color:(UIColor *)color lineWidth:(CGFloat)lineWitdth {
    if (startPoint.x < self.contentLeft ||stopPoint.x >self.contentRight || startPoint.y <self.contentTop || stopPoint.y < self.contentTop) {
        return;
    }
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, lineWitdth);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, stopPoint.x,stopPoint.y);
    CGContextStrokePath(context);
}

- (void)drawDashline:(CGContextRef)context startPoint:(CGPoint)startPoint stopPoint:(CGPoint)stopPoint color:(UIColor *)color lineWidth:(CGFloat)lineWitdth realDistance:(CGFloat)realDistance dashDistance:(CGFloat)dashDistance horizonFlag:(BOOL)flag {
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, lineWitdth);
    NSInteger asend;
    CGFloat darwCount;
    if (flag) {
        darwCount = (stopPoint.x - startPoint.x) / (realDistance + dashDistance);
        asend = (stopPoint.x >= startPoint.x ? 1 : -1);
        for (NSUInteger i = 0; i <= round(fabs(darwCount)); i++) {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, startPoint.x + (realDistance + dashDistance) * i * asend, startPoint.y);
            CGContextAddLineToPoint(context, startPoint.x + ((realDistance + dashDistance) * i + realDistance) * asend, startPoint.y);
            CGContextStrokePath(context);
        }
    } else {
        darwCount = (stopPoint.y - startPoint.y) / (realDistance + dashDistance);
        asend = (stopPoint.y >= startPoint.y ? 1 : -1);
        for (NSUInteger i = 0; i <= round(fabs(darwCount)); i++) {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, startPoint.x, startPoint.y + (realDistance + dashDistance) * i * asend);
            CGContextAddLineToPoint(context, startPoint.x, startPoint.y + ((realDistance + dashDistance) * i + realDistance) * asend) ;
            CGContextStrokePath(context);
        }
    }
}

- (void)drawRectAndLabel:(CGContextRef)context rect:(CGRect)rect fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor attributesText:(NSAttributedString *)attributesText {
    [self drawRect:context rect:rect fillColor:fillColor borderColor:borderColor isFill:YES];
    [self drawLabel:context attributesText:attributesText rect:rect];
}

- (NSDictionary *)defaultAttributedDic
{
    if (!_defaultAttributedDic) {
        _defaultAttributedDic = @{NSFontAttributeName:[UIFont systemFontOfSize:10],NSBackgroundColorAttributeName:[UIColor clearColor]};
    }
    return _defaultAttributedDic;
}

@end
