//
//  HYChartDataSet.h
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HYChartDataSet : NSObject

@property (nonatomic,strong)NSMutableArray * data;
@property (nonatomic,assign)CGFloat highlightLineWidth;
@property (nonatomic,strong)UIColor  * highlightLineColor;
@property (nonatomic,assign)CGFloat  avgLineWidth;
@property (nonatomic,assign)CGFloat candleTopBottmLineWidth;

@end
