//
//  HYChartViewBase.h
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYViewBase.h"

@protocol HYChartViewDelegate <NSObject>

@optional
- (void)chartValueSelected:(HYViewBase *)chartView entry:(id)entry entryIndex:(NSInteger)entryIndex;
- (void)chartValueNothingSelected:(HYViewBase *)chartView;

- (void)chartKlineScrollLeft:(HYViewBase *)chartView;

/** chart changed*/
- (void)chartChanged:(HYViewBase *)chartView;

@end

@interface HYChartViewBase : HYViewBase

/** bottom footer height*/
@property (nonatomic,assign) CGFloat xAxisHeitht;

@property (nonatomic,strong) UIColor *gridBackgroundColor;
@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,assign) CGFloat borderWidth;


@property (nonatomic,assign)CGFloat maxElevation;
@property (nonatomic,assign)CGFloat minElevation;
@property (nonatomic,assign)CGFloat maxVolume;
@property (nonatomic,assign)CGFloat candleCoordsScale;

@property (nonatomic,assign)NSInteger highlightLineCurrentIndex;
@property (nonatomic,assign)CGPoint highlightLineCurrentPoint;
@property (nonatomic,assign)BOOL highlightLineCurrentEnabled;

@property (nonatomic,strong)NSDictionary *leftYAxisAttributedDic;
@property (nonatomic,strong)NSDictionary *xAxisAttributedDic;
@property (nonatomic,strong)NSDictionary *highlightAttributedDic;
@property (nonatomic,strong)NSDictionary *defaultAttributedDic;

@property (nonatomic,assign)BOOL highlightLineShowEnabled;
@property (nonatomic,assign)BOOL scrollEnabled;
@property (nonatomic,assign)BOOL zoomEnabled;

@property (nonatomic,assign)BOOL leftYAxisIsInChart;
@property (nonatomic,assign)BOOL rightYAxisDrawEnabled;

@property (nonatomic, weak) id<HYChartViewDelegate>  delegate;


@property (nonatomic,assign)BOOL isETF;


- (void)drawline:(CGContextRef)context
      startPoint:(CGPoint)startPoint
       stopPoint:(CGPoint)stopPoint
           color:(UIColor *)color
       lineWidth:(CGFloat)lineWitdth;

/** draw dash line*/
- (void)drawDashline:(CGContextRef)context
          startPoint:(CGPoint)startPoint
           stopPoint:(CGPoint)stopPoint
               color:(UIColor *)color
           lineWidth:(CGFloat)lineWitdth
        realDistance:(CGFloat)realDistance
        dashDistance:(CGFloat)dashDistance
         horizonFlag:(BOOL)flag;

/** draw circle point*/
-(void)drawCirclePoint:(CGContextRef)context
                point:(CGPoint)point
               radius:(CGFloat)radius
                color:(UIColor*)color;

- (void)drawHighlighted:(CGContextRef)context
                  point:(CGPoint)point
            circleColor:(UIColor *)circleColor
              lineColor:(UIColor *)lineColor
              lineWidth:(CGFloat)lineWidth;

- (void)drawLabel:(CGContextRef)context
   attributesText:(NSAttributedString *)attributesText
             rect:(CGRect)rect;

- (void)drawRect:(CGContextRef)context
            rect:(CGRect)rect
           color:(UIColor*)color;

- (void)drawRect:(CGContextRef)context
            rect:(CGRect)rect
       fillColor:(UIColor*)fillColor
     borderColor:(UIColor*)borederColor
          isFill:(BOOL)flag;

- (void)drawRectAndLabel:(CGContextRef)context
                    rect:(CGRect)rect
               fillColor:(UIColor*)fillColor
             borderColor:(UIColor*)borderColor
          attributesText:(NSAttributedString *)attributesText;

- (void)drawPath:(CGContextRef)context
       fillColor:(UIColor*)fillColor
          points:(NSArray *)array;

- (void)drawPath:(CGContextRef)context
       fillColor:(UIColor*)fillColor
          points:(NSArray *)array
        clipRect:(CGRect)rect;

- (void)drawGridBackground:(CGContextRef)context
                      rect:(CGRect)rect;



@end
