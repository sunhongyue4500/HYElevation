//
//  HYElevationChartViewController.m
//  HYElevation
//
//  Created by Sunhy on 16/11/27.
//  Copyright © 2016年 Sunhy. All rights reserved.
//

#import "HYElevationChartViewController.h"
#import "HYChartDataSet.h"
#import "HYElevationView.h"
#import "ElevationFetcher.h"
#import "HYElevationPoint.h"
#import "HYUtils.h"
#import "HYConstant.h"

@interface HYElevationChartViewController () <HYChartViewDelegate>

/** Elevation Fetcher*/
@property (nonatomic, strong) ElevationFetcher *elevationFetcher;
/** Elevation DataSet*/
@property (nonatomic, strong) HYChartDataSet *dataset;
/** Elevation Graph View*/
@property (weak, nonatomic) IBOutlet HYElevationView *elevationLineView;

@property (weak, nonatomic) IBOutlet UILabel *highestPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *highestPointValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *clearanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *clearanceValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstStrikeLable;
@property (weak, nonatomic) IBOutlet UILabel *firstStrikeValueLable;

@end

@implementation HYElevationChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.elevationLineView setupChartOffsetWithLeft:0 top:10 right:0 bottom:16];
    self.elevationLineView.gridBackgroundColor = [UIColor whiteColor];
    self.elevationLineView.borderColor = [UIColor colorWithRed:203/255.0 green:215/255.0 blue:224/255.0 alpha:1.0];
    self.elevationLineView.borderWidth = .5;
    self.elevationLineView.bottomRectHeight = 16;
    
    self.elevationLineView.candleWidth = 8;
    self.elevationLineView.candleMaxWidth = 30;
    
    self.elevationLineView.uperChartHeightScale = 1;
    
    self.elevationLineView.xAxisHeitht = 25;
    self.elevationLineView.xAxisAttributedDic = @{NSFontAttributeName:[UIFont systemFontOfSize:10],
                                                  NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    self.elevationLineView.delegate = self;
    self.elevationLineView.highlightLineShowEnabled = YES;
    self.elevationLineView.zoomEnabled = YES;
    self.elevationLineView.scrollEnabled = YES;
    
    self.elevationLineView.redWarning = redWarnDefaultValue;
    self.elevationLineView.yellowWarning = yellowWarnDefaultValue;
    
    // Set DataSource
    NSArray *array = [ElevationFetcher fetchTestElevationPointsData];
    [self setDataset:self.dataset];
    [self setChartData:array];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.elevationLineView.highlightLineCurrentIndex = -1;
    self.elevationLineView.altitudeAdvisor = -1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.elevationLineView.altitudeAdvisor <= 1000) {
        self.elevationLineView.altitudeAdvisor = [HYUtils altitudeAdvisor];
    }
}

#pragma mark - **************** Delegate
-(void)chartValueSelected:(HYViewBase *)chartView entry:(id)entry entryIndex:(NSInteger)entryIndex
{
    //HYElevationPoint *point = (HYElevationPoint *)entry;
    //HYElevationPoint *startPoint = (HYElevationPoint *)[[self.elevationLineView dataSetData] objectAtIndex:0];
}

- (void)chartValueNothingSelected:(HYViewBase *)chartView {
    
}

- (void)chartKlineScrollLeft:(HYViewBase *)chartView {
    
}

- (void)chartReload:(HYViewBase *)chartView {
    [self configRightLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - **************** DataSource
- (void)setChartData:(NSArray *)chartData {
    if (chartData) {
        [self.elevationLineView setupData:chartData];
    }
}

#pragma mark - **************** getter
- (ElevationFetcher *)elevationFetcher {
    if (!_elevationFetcher) {
        _elevationFetcher = [[ElevationFetcher alloc] init];
    }
    return _elevationFetcher;
}

- (HYChartDataSet *)dataset {
    if (!_dataset) {
        _dataset = [[HYChartDataSet alloc] init];
    }
    return _dataset;
}

/** config right label*/
- (void)configRightLabel {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.highestPointValueLabel.text = [NSString stringWithFormat:@"%.fm", self.elevationLineView.highestPointValue];
        self.clearanceValueLabel.text = [NSString stringWithFormat:@"%.fm", self.elevationLineView.clearanceValue];
        double distance = -1;
        if (self.elevationLineView.dataSetData.count != 0) {
            HYElevationPoint *point1 = [self.elevationLineView.dataSetData objectAtIndex:0];
            if (self.elevationLineView.firstStrikeIndex - 1 < 0) {
                distance = 0;
            } else {
                HYElevationPoint *point2 = [self.elevationLineView.dataSetData objectAtIndex:self.elevationLineView.firstStrikeIndex];
                distance = [HYUtils distanceBetween:point1.lon lat1:point1.lat andlon2:point2.lon lat2:point2.lat];
            }
        }
        if (distance == -1 || self.elevationLineView.altitudeAdvisor > self.elevationLineView.highestPointValue) {
            self.firstStrikeValueLable.text = [NSString stringWithFormat:@"none"];
            self.firstStrikeLable.textColor = kElevationChartLabelDefaultColor;
            self.firstStrikeValueLable.textColor = kElevationChartLabelDefaultColor;
        } else {
            self.firstStrikeValueLable.text = [NSString stringWithFormat:@"%.fkm", distance];
            if (distance > ElEVATION_CHART_RIGHT_LABEL_STRIKE_RED_WARN) {
                self.firstStrikeLable.textColor = kElevationChartLabelYellow;
                self.firstStrikeValueLable.textColor = kElevationChartLabelYellow;
            } else {
                self.firstStrikeLable.textColor = kElevationChartLabelRed;
                self.firstStrikeValueLable.textColor = kElevationChartLabelRed;
            }
        }
        // set label color
        if (self.elevationLineView.clearanceValue <= self.elevationLineView.redWarning) {
            self.clearanceLabel.textColor = kElevationChartLabelRed;
            self.clearanceValueLabel.textColor = kElevationChartLabelRed;
        } else if (self.elevationLineView.clearanceValue > self.elevationLineView.redWarning && self.elevationLineView.clearanceValue <= self.elevationLineView.yellowWarning) {
            self.clearanceLabel.textColor = kElevationChartLabelYellow;
            self.clearanceValueLabel.textColor = kElevationChartLabelYellow;
        } else {
            self.clearanceLabel.textColor = kElevationChartLabelDefaultColor;
            self.clearanceValueLabel.textColor = kElevationChartLabelDefaultColor;
        }
    });
}

@end
