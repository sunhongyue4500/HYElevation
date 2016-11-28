//
//  HYElevationView.m
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import "HYElevationView.h"
#import "HYChartDataSet.h"
#import "HYConstant.h"
#import "HYElevationPoint.h"
#import "HYUtils.h"

typedef NS_ENUM(NSUInteger, LineWithAreaIntersectionState) {
    LineWithAreaIntersectionStateAllGreen,
    LineWithAreaIntersectionStateGreenAndYellow,
    LineWithAreaIntersectionStateAllYellow,
    LineWithAreaIntersectionStateYellowAndRed,
    LineWithAreaIntersectionStateAllRed,
    LineWithAreaIntersectionStateGreenAndYellowAndRed,
};

@interface HYElevationView () <UIGestureRecognizerDelegate>

@property (nonatomic,strong)HYChartDataSet * dataSet;

@property (nonatomic,assign)NSInteger countOfShow;

@property (nonatomic,assign)NSInteger  startDrawIndex;

/** 单个比例尺的长度*/
@property (nonatomic,assign)double measureWidth;

@property (nonatomic,strong)UIPanGestureRecognizer * panGesture;
@property (nonatomic,strong)UIPinchGestureRecognizer * pinGesture;
@property (nonatomic,strong)UILongPressGestureRecognizer * longPressGesture;
@property (nonatomic,strong)UITapGestureRecognizer * tapGesture;

@property (nonatomic, strong) UIButton *altitudeAdvisorBtn;

@property (nonatomic,assign)CGFloat lastPinScale;

@property (nonatomic,assign)CGFloat lastPinCount;

@property (nonatomic, assign, readwrite) double highestPointValue;
@property (nonatomic, assign, readwrite) double clearanceValue;

@property (nonatomic, assign, readwrite) int firstStrikeIndex;

@end

@implementation HYElevationView
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        
    }
    return self;
}

- (void)commonInit {
    
    self.candleCoordsScale = 0.f;
    self.measureWidth = 8;
    
    [self addGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.pinGesture];
    [self addGestureRecognizer:self.longPressGesture];
    [self addGestureRecognizer:self.tapGesture];
    
    self.panGesture.delegate = self;
    self.pinGesture.delegate = self;
    self.longPressGesture.delegate = self;
    self.tapGesture.delegate = self;
}

/** show count*/
- (NSInteger)countOfShow{
    return self.contentWidth/(self.candleWidth);
}

- (void)setStartDrawIndex:(NSInteger)startDrawIndex
{
    if (startDrawIndex <= 0) {
        startDrawIndex = 0;
    } else  if (startDrawIndex + self.countOfShow >= self.dataSet.data.count) {
        startDrawIndex = self.dataSet.data.count - self.countOfShow;
    }
    _startDrawIndex = startDrawIndex;
}

- (void)setCandleWidth:(CGFloat)candleWidth {
    if (candleWidth >= self.candleMaxWidth) _candleWidth = self.candleMaxWidth;
    else if (candleWidth <= self.candleMinWidth) _candleWidth = self.candleMinWidth;
    else  _candleWidth = candleWidth;
}

-(void)setupData:(NSArray *)data {
    self.dataSet.data = [NSMutableArray arrayWithArray:data];
    [self notifyDataSetChanged];
}

/** HYChartDataSet的其他属性没有设置*/
- (HYChartDataSet *)dataSet {
    if (!_dataSet) {
        _dataSet = [[HYChartDataSet alloc] init];
        _dataSet.highlightLineColor = kElevationChartClearColor;
        _dataSet.highlightLineWidth = 0.7;
        _dataSet.avgLineWidth = 1.f;
        _dataSet.candleTopBottmLineWidth = 1;
    }
    return _dataSet;
}

- (NSArray *)dataSetData {
    return [NSMutableArray arrayWithArray:self.dataSet.data];
}

- (UIButton *)altitudeAdvisorBtn {
    if (!_altitudeAdvisorBtn) {
        _altitudeAdvisorBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentLeft + ElEVATION_CHART_ALTITUDE_ADVISOR_OFFSET, 0, 54, 24)];
        _altitudeAdvisorBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [_altitudeAdvisorBtn addTarget:self action:@selector(altitudeAdvisorBtnDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
        [_altitudeAdvisorBtn setTitle:@"100m" forState:UIControlStateNormal];
        _altitudeAdvisorBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [_altitudeAdvisorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_altitudeAdvisorBtn];
    }
    return _altitudeAdvisorBtn;
}

- (void)addDataSetWithArray:(NSArray *)array
{
    NSArray * tempArray = [self.dataSet.data mutableCopy];
    [self.dataSet.data removeAllObjects];
    [self.dataSet.data addObjectsFromArray:array];
    [self.dataSet.data addObjectsFromArray:tempArray];
    self.startDrawIndex += array.count;
    [self setCurrentDataMaxAndMin];
    [self setNeedsDisplay];
}

/** 设置最大最小范围*/
- (void)setCurrentDataMaxAndMin
{
    if (self.dataSet.data.count > 0) {
        self.maxElevation = CGFLOAT_MIN;
        self.minElevation = CGFLOAT_MAX;
        //self.maxVolume = CGFLOAT_MIN;
        
        for (NSInteger i = 0; i < self.dataSet.data.count; i++) {
            HYElevationPoint  * entity = [self.dataSet.data objectAtIndex:i];
            self.minElevation = (self.minElevation < entity.elevation ? self.minElevation : entity.elevation);
            self.maxElevation = (self.maxElevation > entity.elevation ? self.maxElevation : entity.elevation);
        }
        if (self.maxElevation - self.minElevation < 0.3) {
            self.maxElevation +=0.5;
            self.minElevation -=0.5;
        }
        self.maxElevation += 300;
    }
}

#pragma mark - **************** Draw
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // 只需在数据源变化后再设置
    [self setCurrentDataMaxAndMin];
    
    CGContextRef optionalContext = UIGraphicsGetCurrentContext();
    
    [self drawGridBackground:optionalContext rect:rect];
    [self drawChartBackground:optionalContext rect:rect];
    // 绘制底部的label背景
    CGRect bottomLabelRect = CGRectMake(rect.origin.x, rect.size.height - self.bottomRectHeight, rect.size.width, self.bottomRectHeight);
    [self drawRect:optionalContext rect:bottomLabelRect color:kMainPanelBackgroundColor];
    
    if (self.dataSet.data.count) {
        [self drawCandle:optionalContext];
    }
    // 更新controller右侧视图
    if ([self.delegate respondsToSelector:@selector(chartReload:)]) {
        [self.delegate chartReload:self];
    }
}

- (void)drawChartBackground:(CGContextRef)context rect:(CGRect)rect{
    
    // 当前视野开始的索引
    NSInteger idex = self.startDrawIndex;
    CGFloat seperateStart = -1;
    
    // 相对于开始碰撞的索引点的前向偏移
    double startXOffset = 0;
    self.firstStrikeIndex = [self getStartIndexAndcollisionXOffset:&startXOffset];
    if (self.firstStrikeIndex < 0) {
        
    } else if (self.firstStrikeIndex <= idex) {
        // 之前的位置碰撞
        seperateStart = 0;
    } else {
        CGFloat startXTemp = (self.candleWidth * (self.firstStrikeIndex - idex) + self.contentLeft);
        seperateStart = startXTemp - startXOffset;
        // 超出视图边界
        if (seperateStart > rect.origin.x + rect.size.width) {
            seperateStart = rect.origin.x + rect.size.width;
        }
    }
    
    if (seperateStart < 0) seperateStart = self.contentWidth;
    // 绘制未碰撞
    [self drawRect:context rect:CGRectMake(self.contentLeft, 0, seperateStart - self.contentLeft, self.contentHeight + self.contentTop) color:kElevationChartBackgroundLeftBackgroundColor];
    // 绘制碰撞
    [self drawRect:context rect:CGRectMake(self.contentLeft + seperateStart - self.contentLeft, 0, self.contentWidth - seperateStart, self.contentHeight + self.contentTop) color:kElevationChartBackgroundRightBackgroundColor];
}

- (void)drawGridBackground:(CGContextRef)context rect:(CGRect)rect
{
    [super drawGridBackground:context rect:rect];
}

- (void)drawCandle:(CGContextRef)context
{
    CGContextSaveGState(context);
    // 开始的索引
    NSInteger idex = self.startDrawIndex;
    // 图表尽可能充满空间
    self.candleCoordsScale = (self.uperChartHeightScale * self.contentHeight)/(self.maxElevation-self.minElevation);
    // 下面的图的比例
    self.volumeCoordsScale = (self.contentHeight - (self.uperChartHeightScale * self.contentHeight)-self.xAxisHeitht)/(self.maxVolume - 0);
    
    // 绘制比例尺
    HYElevationPoint * startEntity = [self.dataSet.data objectAtIndex:0];
    HYElevationPoint * endEntity = [self.dataSet.data objectAtIndex:self.dataSet.data.count - 1];
    double distance = [HYUtils distanceBetween:startEntity.lon lat1:startEntity.lat andlon2:endEntity.lon lat2:endEntity.lat];
    // 一个candleWidth代表多少km
    double kmPerCandleWidth = distance / self.dataSet.data.count;
    // 多长距离画一个 25,50,100....
    double measureScale = [self scaleByDistance:self.countOfShow * kmPerCandleWidth];
    // 多长画一个   self.candleWidth / kmPerCandleWidth 代表屏幕单位距离的km数
    double drawLength = (self.candleWidth / kmPerCandleWidth) * measureScale;
    
    HYElevationPoint * idexEntity = [self.dataSet.data objectAtIndex:idex];
    // 得到idex到起点的距离
    double idexOffset = [HYUtils distanceBetween:startEntity.lon lat1:startEntity.lat andlon2:idexEntity.lon lat2:idexEntity.lat];
    // 得到idex到起点的屏幕偏移
    double screenOffset = (self.candleWidth / kmPerCandleWidth) * idexOffset;
    
    NSString * scaleStr;
    NSDictionary *dicAttr = @{NSFontAttributeName:kElevationChartMeasureScaleFont,NSForegroundColorAttributeName:kElevationChartClearColor};
    NSMutableAttributedString * scaleStrAtt;
    
    int counter = 0;
    // 相当于从起点开始绘制
    while (measureScale * counter < distance) {
        if (counter % 2 == 0) {
            [self drawRect:context rect:CGRectMake(drawLength * counter - screenOffset, 2, drawLength, self.measureWidth) fillColor:kElevationChartMeasureScaleColor  borderColor:kElevationChartMeasureScaleColor isFill:YES];
            scaleStr = [NSString stringWithFormat:@"%.fkm", measureScale * (counter + 1)];
            scaleStrAtt = [[NSMutableAttributedString alloc] initWithString:scaleStr attributes:dicAttr];
            // 绘制比例尺标签 减到起点的偏移，字体宽度
            [self drawLabel:context attributesText:scaleStrAtt rect:CGRectMake(drawLength * counter - screenOffset + drawLength -[scaleStrAtt size].width / 2, 10, [scaleStrAtt size].width, [scaleStrAtt size].height)];
        } else {
            [self drawRect:context rect:CGRectMake(drawLength * counter - screenOffset, 2, drawLength, self.measureWidth) fillColor:kElevationChartMeasureScaleColor  borderColor:kElevationChartMeasureScaleColor isFill:NO];
        }
        counter++;
    }
    
    CGFloat startEntityX = 0.0;
    CGFloat startEntityY = 0.0;
    NSMutableArray *elevationPoints = [NSMutableArray array];
    
    int redWarn = self.altitudeAdvisor - self.redWarning;
    int yellowWarn = self.altitudeAdvisor - self.yellowWarning - self.redWarning;
    double altitudeAdvisorY = ((self.maxElevation - self.altitudeAdvisor) * self.candleCoordsScale) + self.contentTop;
    double redWarnY = ((self.maxElevation - redWarn) * self.candleCoordsScale) + self.contentTop;
    double yellowWarnY = ((self.maxElevation - yellowWarn) * self.candleCoordsScale) + self.contentTop;
    
    // 绘制颜色区
    for (NSInteger i = idex ; i <= idex + self.countOfShow && i < self.dataSet.data.count; i++) {
        HYElevationPoint *entity = [self.dataSet.data objectAtIndex:i];
        // 绘制颜色区域
        startEntityX = (self.candleWidth * (i - idex) + self.contentLeft);
        startEntityY = (self.maxElevation - entity.elevation) * self.candleCoordsScale + self.contentTop;
        [elevationPoints addObject:[NSValue valueWithCGPoint:CGPointMake(startEntityX, startEntityY)]];
    }
    [elevationPoints addObject:[NSValue valueWithCGPoint:CGPointMake(self.contentWidth, self.contentHeight + self.contentTop)]];
    [elevationPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, self.contentHeight + self.contentTop)]];
    
    // 绘制颜色
    [self drawPath:context fillColor:kElevationChartGreenArea points:elevationPoints clipRect:CGRectMake(0, yellowWarnY, self.contentWidth, self.contentHeight + self.contentTop - yellowWarnY)];
    [self drawPath:context fillColor:kElevationChartYellowArea points:elevationPoints clipRect:CGRectMake(0, redWarnY, self.contentWidth, yellowWarnY - redWarnY)];
    [self drawPath:context fillColor:kElevationChartRedArea points:elevationPoints clipRect:CGRectMake(0, 0, self.contentWidth, redWarnY)];
    
    // 绘制底部高程点
    CGRect labelRect = CGRectZero;
    /** 保存上一次绘制的位置*/
    CGRect lastRect = CGRectZero;
    
    // 只绘制视野范围内的高程点
    for (NSInteger i = idex ; i <= idex + self.countOfShow && i < self.dataSet.data.count; i++) {
        HYElevationPoint *entity = [self.dataSet.data objectAtIndex:i];
        
        CGFloat left = (self.candleWidth * (i - idex) + self.contentLeft);
        CGFloat startX = left;
        
        if (entity.elevationPointName) {
            // 绘制竖线
            [self drawline:context startPoint:CGPointMake(startX, self.contentTop) stopPoint:CGPointMake(startX,  (self.uperChartHeightScale * self.contentHeight)+ self.contentTop) color:self.borderColor lineWidth:1];
            NSString * date = entity.elevationPointName;
            NSDictionary * drawAttributes = self.xAxisAttributedDic?:self.defaultAttributedDic;
            NSMutableAttributedString * dateStrAtt = [[NSMutableAttributedString alloc]initWithString:date attributes:drawAttributes];
            CGSize dateStrAttSize = [dateStrAtt size];
            double labelStartX = startX - dateStrAttSize.width / 2;
            double labelEndX = startX + dateStrAttSize.width / 2;
            // 边界检查
            // 左边界
            if (labelStartX < self.contentLeft) {
                labelStartX = 0;
            }
            // 右边界
            if (labelEndX > self.contentRight) {
                labelStartX = self.contentRight - dateStrAttSize.width;
            }
            labelRect = CGRectMake(labelStartX,((self.uperChartHeightScale * self.contentHeight)+ self.contentTop), dateStrAttSize.width, dateStrAttSize.height);
            // 相交
            if (CGRectEqualToRect(lastRect, CGRectZero) || !isXIntersectionWithRect(labelRect, lastRect)) {
                [self drawLabel:context attributesText:dateStrAtt rect:labelRect];
                lastRect = labelRect;
            }
        }
        
        if (i > 0){
            HYElevationPoint * lastEntity = [self.dataSet.data objectAtIndex:i -1];
            CGFloat lastX = startX - self.candleWidth;
            
            CGFloat lastY5 = (self.maxElevation - lastEntity.elevation) * self.candleCoordsScale + self.contentTop;
            CGFloat  y5 = (self.maxElevation - entity.elevation) * self.candleCoordsScale + self.contentTop;
            if (entity.elevation >= 0 && lastEntity.elevation >= 0) {
                [self drawline:context startPoint:CGPointMake(lastX, lastY5) stopPoint:CGPointMake(startX, y5) color:kElevationChartClearColor lineWidth:self.dataSet.avgLineWidth];
            }
        }
        
        // 绘制颜色区域
        startEntityX = (self.candleWidth * (i - idex) + self.contentLeft);
        startEntityY = (self.maxElevation - entity.elevation) * self.candleCoordsScale + self.contentTop;
        [elevationPoints addObject:[NSValue valueWithCGPoint:CGPointMake(startEntityX, startEntityY)]];
    }
    
    // 绘制Altitude Advisor DashLine
    double realDistance = 7;
    double dashDistance = 3;
    double lineWidth = 1;
    //
    [self drawDashline:context startPoint:CGPointMake(self.contentLeft, altitudeAdvisorY) stopPoint:CGPointMake(self.contentLeft + ElEVATION_CHART_ALTITUDE_ADVISOR_OFFSET, altitudeAdvisorY) color:kElevationChartClearColor lineWidth:lineWidth realDistance:realDistance dashDistance:dashDistance horizonFlag:YES];
    
    [self drawDashline:context startPoint:CGPointMake(self.contentLeft + ElEVATION_CHART_ALTITUDE_ADVISOR_OFFSET + self.altitudeAdvisorBtn.frame.size.width, altitudeAdvisorY) stopPoint:CGPointMake(self.contentRight, altitudeAdvisorY) color:kElevationChartClearColor lineWidth:lineWidth realDistance:realDistance dashDistance:dashDistance horizonFlag:YES];
    
    // 绘制长按十字线
    for (NSInteger i = idex ; i< self.dataSet.data.count; i ++) {
        HYElevationPoint *entity = [self.dataSet.data objectAtIndex:i];
        
        CGFloat close = ((self.maxElevation - entity.elevation) * self.candleCoordsScale) + self.contentTop;
        CGFloat left = (self.candleWidth * (i - idex) + self.contentLeft);
        //CGFloat candleWidth = self.candleWidth;
        CGFloat startX = left;
        //十字线
        if (self.highlightLineCurrentEnabled) {
            if (i == self.highlightLineCurrentIndex) {
                
                HYElevationPoint * entity;
                if (i < self.dataSet.data.count) {
                    entity = [self.dataSet.data objectAtIndex:i];
                }
                [self drawHighlighted:context point:CGPointMake(startX, close)idex:idex value:entity color:self.dataSet.highlightLineColor lineWidth:self.dataSet.highlightLineWidth];
                if ([self.delegate respondsToSelector:@selector(chartValueSelected:entry:entryIndex:) ]) {
                    [self.delegate chartValueSelected:self entry:entity entryIndex:i];
                }
            }
        }
    }
    CGContextRestoreGState(context);
}

- (void)getHighlightByTouchPoint:(CGPoint) point
{
    self.highlightLineCurrentIndex = self.startDrawIndex + (NSInteger)((point.x - self.contentLeft)/self.candleWidth);
    [self setNeedsDisplay];
}

/** 依据元素个数调整间距*/
- (void)adjustCandleMinWidth {
    self.candleMinWidth = self.contentWidth / self.dataSet.data.count;
}

/** 会调用两遍*/
- (void)notifyDataSetChanged
{
    [super notifyDataSetChanged];
    [self adjustCandleMinWidth];
    self.candleWidth = self.candleMinWidth;
    
    // 调用layoutSubviews
    [self setNeedsDisplay];
    
    self.altitudeAdvisor = [HYUtils altitudeAdvisor];
    [self setUpAltitudeAdvisorBtn];
    self.startDrawIndex = 0;
    self.highestPointValue = [self highestElevationPointValue];
}

- (void)notifyDeviceOrientationChanged
{
    [super notifyDeviceOrientationChanged];
    self.startDrawIndex = 0;
}


#pragma mark - **************** Gestures
- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGestureAction:)];
    }
    return _panGesture;
}
- (void)handlePanGestureAction:(UIPanGestureRecognizer *)recognizer
{
    if (!self.scrollEnabled) {
        return;
    }
    
    self.highlightLineCurrentEnabled = NO;
    
    CGPoint point = [recognizer translationInView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
    }
    
    CGFloat offset = point.x;
    
    NSLog(@"%ld=======,%.2f,%.2f",(long)self.startDrawIndex,offset,[recognizer velocityInView:self].x);
    
    if (offset > 0) {
        // 向右滑
        NSInteger offsetIndex = offset / 4.0 ;
        NSLog(@"%ld",(long)offsetIndex);
        
        self.startDrawIndex  -= offsetIndex;
        if ( self.startDrawIndex < 2) {
            if ([self.delegate respondsToSelector:@selector(chartKlineScrollLeft:)]) {
                [self.delegate chartKlineScrollLeft:self];
            }
        }
    }else{
        // 向左滑
        NSInteger offsetIndex = (-offset) / 4.0;
        self.startDrawIndex += offsetIndex;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
    }
    [self setNeedsDisplay];
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
}

- (UIPinchGestureRecognizer *)pinGesture
{
    if (!_pinGesture) {
        _pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinGestureAction:)];
    }
    return _pinGesture;
}

- (void)handlePinGestureAction:(UIPinchGestureRecognizer *)recognizer
{
    if (!self.zoomEnabled) {
        return;
    }
    
    self.highlightLineCurrentEnabled = NO;
    
    recognizer.scale= recognizer.scale - self.lastPinScale + 1;
    
    self.candleWidth = recognizer.scale * self.candleWidth;
    
    if(self.candleWidth > self.candleMaxWidth){
        self.candleWidth = self.candleMaxWidth;
    }
    if(self.candleWidth < self.candleMinWidth){
        self.candleWidth = self.candleMinWidth;
    }
    
    //self.startDrawIndex = self.dataSet.data.count - self.countOfShow;
    NSInteger offset = (NSInteger)((self.lastPinCount -self.countOfShow)/2);
    
    if (labs(offset)) {
        NSLog(@"offset %ld",(long)offset);
        self.lastPinCount = self.countOfShow;
        self.startDrawIndex = self.startDrawIndex + offset;
        [self setNeedsDisplay];
    }
    
    NSLog(@"%ld",(long)self.startDrawIndex);
    
    self.lastPinScale = recognizer.scale;
}

- (UILongPressGestureRecognizer *)longPressGesture
{
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGestureAction:)];
        _longPressGesture.minimumPressDuration = 0.5;
    }
    return _longPressGesture;
}

- (void)handleLongPressGestureAction:(UIPanGestureRecognizer *)recognizer
{
    if (!self.highlightLineShowEnabled) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint  point = [recognizer locationInView:self];
        
        if (point.x > self.contentLeft && point.x < self.contentRight && point.y >self.contentTop && point.y<self.contentBottom) {
            self.highlightLineCurrentEnabled = YES;
            [self getHighlightByTouchPoint:point];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint  point = [recognizer locationInView:self];
        
        if (point.x > self.contentLeft && point.x < self.contentRight && point.y >self.contentTop && point.y<self.contentBottom) {
            self.highlightLineCurrentEnabled = YES;
            [self getHighlightByTouchPoint:point];
        }
    }else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestureAction:)];
    }
    return _tapGesture;
}

- (void)handleTapGestureAction:(UITapGestureRecognizer *)recognizer
{
    if (self.highlightLineCurrentEnabled) {
        self.highlightLineCurrentEnabled = NO;
    }
    [self setNeedsDisplay];
}

/**依据当前视野距离，获取比例尺*/
- (double)scaleByDistance:(double)distance {
    if (distance <= 1600 && distance > 1200) {
        return 300;
    } else if (distance <= 1200 && distance > 800) {
        return 200;
    } else if (distance <= 800 && distance > 400) {
        return 100;
    } else if (distance <= 400 && distance > 200) {
        return 50;
    } else if (distance <= 200 && distance > 100) {
        return 25;
    } else if (distance <= 100 && distance > 50) {
        return 10;
    } else if (distance <= 50 && distance > 20) {
        return 5;
    } else if (distance <= 20) {
        return 5;
    } else {
        return 400;
    }
}

- (LineWithAreaIntersectionState)fetchStateAndIntersectionWithYellowLineX1:(double *)x1 Y1:(double *)y1 withRedLineX:(double *)x2 Y2:(double *)y2 WithPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    double xtemp1 = 0;
    double ytemp1 = 0;
    double xtemp2 = 0;
    double ytemp2 = 0;
    
    double minY = (point1.y <= point2.y ? point1.y : point2.y);
    double maxY = (point1.y >= point2.y ? point1.y : point2.y);
    
    int redWarn = self.altitudeAdvisor - self.redWarning;
    int yellowWarn = self.altitudeAdvisor - self.yellowWarning - self.redWarning;
    double redWarnY = ((self.maxElevation - redWarn) * self.candleCoordsScale) + self.contentTop;
    double yellowWarnY = ((self.maxElevation - yellowWarn) * self.candleCoordsScale) + self.contentTop;
    
    BOOL isIntersectionWithYellowLine = [HYUtils getX:&xtemp1 Y:&ytemp1 withPoint1:point1 point2:point2 withLineY:yellowWarnY];
    BOOL isIntersectionWithRedLine = [HYUtils getX:&xtemp2 Y:&ytemp2 withPoint1:point1 point2:point2 withLineY:redWarnY];
    if (isIntersectionWithRedLine && !isIntersectionWithYellowLine) {
        *x1 = -1;
        *y1 = -1;
        *x2 = xtemp2;
        *y2 = ytemp2;
        return LineWithAreaIntersectionStateYellowAndRed;
    }
    else if (!isIntersectionWithRedLine && isIntersectionWithYellowLine) {
        *x1 = xtemp1;
        *y1 = ytemp1;
        *x2 = -1;
        *y2 = -1;
        return LineWithAreaIntersectionStateGreenAndYellow;
    }
    else if (!isIntersectionWithRedLine && !isIntersectionWithYellowLine) {
        if (minY >= yellowWarnY) {
            return LineWithAreaIntersectionStateAllGreen;
        } else if (minY > redWarnY && maxY < yellowWarnY ) {
            return LineWithAreaIntersectionStateAllYellow;
        } else if (maxY <= redWarnY) {
            return LineWithAreaIntersectionStateAllRed;
        }
    }
    *x1 = xtemp1;
    *y1 = ytemp1;
    *x2 = xtemp2;
    *y2 = ytemp2;
    return LineWithAreaIntersectionStateGreenAndYellowAndRed;
}

/**
 获取与Altitude Advisor碰撞的索引
 
 @param collisionXOffset 碰撞的x坐标
 
 @return dataset碰撞的索引, 0表示从第一位置就碰撞， -1表示不会碰撞
 */
- (int)getStartIndexAndcollisionXOffset:(double *)collisionXOffset {
    CGFloat seperateStart = -1;
    // max < altitudeAdvisor?
    if (self.maxElevation < self.altitudeAdvisor) return -1;
    double strikeHeight = self.altitudeAdvisor - self.redWarning;
    double advisorY = ((self.maxElevation - strikeHeight) * self.candleCoordsScale) + self.contentTop;
    double xtemp1 = 0;
    double ytemp1 = 0;
    CGFloat startEntityX = 0;
    CGFloat startEntityY = 0;
    CGFloat endEntityX = 0;
    CGFloat endEntityY = 0;
    for (NSInteger i = 0 ; i < self.dataSet.data.count; i++) {
        HYElevationPoint *entity = [self.dataSet.data objectAtIndex:i];
        startEntityX = (self.candleWidth * i + self.contentLeft);
        startEntityY = (self.maxElevation - entity.elevation) * self.candleCoordsScale + self.contentTop;
        
        if (entity.elevation >= strikeHeight) {
            seperateStart = i;
            // 前一个位置
            if (i == 0) {
                *collisionXOffset = 0;
                return seperateStart;
            }
            else {
                HYElevationPoint *lastEntity = [self.dataSet.data objectAtIndex:i-1];
                endEntityX = (self.candleWidth * (i - 1) + self.contentLeft);
                endEntityY = (self.maxElevation - lastEntity.elevation) * self.candleCoordsScale + self.contentTop;
                BOOL isIntersection = [HYUtils getX:&xtemp1 Y:&ytemp1 withPoint1:CGPointMake(startEntityX, startEntityY) point2:CGPointMake(endEntityX, endEntityY) withLineY:advisorY];
                if (isIntersection) {
                    *collisionXOffset = fabs(startEntityX - xtemp1);
                }
            }
            break;
        }
    }
    return seperateStart;
}

- (void)altitudeAdvisorBtnDragged:(UIButton *)sender withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGFloat boundsExtension = 70.0f;
    CGRect outerBounds = CGRectInset(sender.bounds, -1 * boundsExtension, -1 * boundsExtension);
    BOOL touchOutside = !CGRectContainsPoint(outerBounds, [touch locationInView:sender]);
    if (!touchOutside) {
        UITouch *touch = [[event touchesForView:sender] anyObject];
        // get delta
        CGPoint previousLocation = [touch previousLocationInView:self];
        CGPoint location = [touch locationInView:self];
        CGFloat delta_y = location.y - previousLocation.y;
        // move button
        CGRect oldRect = self.altitudeAdvisorBtn.frame;
        double yTemp = 0;
        if (oldRect.origin.y + delta_y <= 0) {
            yTemp = 0;
        } else if (oldRect.origin.y + delta_y >= self.contentHeight + self.contentTop - oldRect.size.height / 2) {
            yTemp = self.contentHeight + self.contentTop - oldRect.size.height / 2;
        } else {
            yTemp = oldRect.origin.y + delta_y;
        }
        self.altitudeAdvisorBtn.frame = CGRectMake(oldRect.origin.x, yTemp, oldRect.size.width, oldRect.size.height);
        
        // 反算出高程值
        CGRect rect = [sender convertRect:sender.bounds toView:self];
        //((self.maxElevation - self.altitudeAdvisor) * self.candleCoordsScale) + self.contentTop;
        double tempElevation = self.maxElevation - ((rect.origin.y + rect.size.height / 2 - self.contentTop) / self.candleCoordsScale);
        [self.altitudeAdvisorBtn setTitle:[NSString stringWithFormat:@"%.fm", tempElevation] forState:UIControlStateNormal];
        self.altitudeAdvisor = tempElevation;
        // 设置clearance
        self.clearanceValue = self.altitudeAdvisor - self.highestPointValue;
        [self setNeedsDisplay];
    }
}

/** 设置Altitude Advisor btn起始位置*/
- (void)setUpAltitudeAdvisorBtn{
    // 异步
    dispatch_async(dispatch_get_main_queue(), ^{
        double tempY = (self.maxElevation - self.altitudeAdvisor) * self.candleCoordsScale + self.contentTop;
        CGRect oldRect = self.altitudeAdvisorBtn.frame;
        self.altitudeAdvisorBtn.frame = CGRectMake(oldRect.origin.x, tempY - oldRect.size.height / 2, oldRect.size.width, oldRect.size.height);
        [self.altitudeAdvisorBtn setTitle:[NSString stringWithFormat:@"%.fm", self.altitudeAdvisor] forState:UIControlStateNormal];
        // 设置clearance
        self.clearanceValue = self.altitudeAdvisor - self.highestPointValue;
    });
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Disallow recognition of tap gestures in the segmented control.
    if ((touch.view == self.altitudeAdvisorBtn)) {
        return NO;
    }
    return YES;
}

#pragma mark - **************** Other Util
- (double)highestElevationPointValue {
    _highestPointValue = 0;
    for (NSInteger i = 0; i < self.dataSet.data.count; i++) {
        HYElevationPoint  * entity = [self.dataSet.data objectAtIndex:i];
        _highestPointValue = (_highestPointValue > entity.elevation ? _highestPointValue : entity.elevation);
    }
    return _highestPointValue;
}

@end
