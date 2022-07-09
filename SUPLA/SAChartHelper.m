/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import "SAChartHelper.h"
#import "SuplaApp.h"
#import "SUPLA-Swift.h"

@implementation SAChartHelper {
    long _minTimestamp;
    NSNumber *_downloadProgress;
}

@synthesize channelId;
@synthesize combinedChart;
@synthesize pieChart;
@synthesize unit;
@synthesize chartType;
@synthesize dateFrom;
@synthesize dateTo;

-(id)init {
    if (self = [super init]) {
        _minTimestamp = 0;
        chartType = Bar_Months;
    }
    return self;
}

- (NSNumber *)doubleValueForKey:(NSString *)key item:(NSDictionary *)i {
    NSNumber *result = [i valueForKey:key];
    return result == nil ? [NSNumber numberWithDouble:0.0] : result;
}

- (NSArray *)getData {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

-(BOOL)isComparsionChartType {
    switch (chartType) {
        case Bar_Comparsion_MinMin:
        case Bar_Comparsion_HourHour:
        case Bar_Comparsion_DayDay:
        case Bar_Comparsion_MonthMonth:
        case Bar_Comparsion_YearYear:
            return YES;
        default:
            return NO;
    }
}

-(BOOL)isPieChartType {
    switch (chartType) {
        case Pie_HourRank:
        case Pie_WeekdayRank:
        case Pie_MonthRank:
        case Pie_PhaseRank:
            return YES;
        default:
            return NO;
    }
}

-(BOOL)isBalanceChartType {
    switch (chartType) {
        case Bar_AritmeticBalance_Minutes:
        case Bar_AritmeticBalance_Hours:
        case Bar_AritmeticBalance_Days:
        case Bar_AritmeticBalance_Months:
        case Bar_AritmeticBalance_Years:
        case Bar_VectorBalance_Minutes:
        case Bar_VectorBalance_Hours:
        case Bar_VectorBalance_Days:
        case Bar_VectorBalance_Months:
        case Bar_VectorBalance_Years:
            return YES;
        default:
            return NO;
    }
}

-(BOOL)isVectorBalanceChartType {
    switch (chartType) {
        case Bar_VectorBalance_Minutes:
        case Bar_VectorBalance_Hours:
        case Bar_VectorBalance_Days:
        case Bar_VectorBalance_Months:
        case Bar_VectorBalance_Years:
            return YES;
        default:
            return NO;
    }
}

-(NSDateFormatter *) dateFormatterForCurrentChartType {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    switch(chartType) {
        case Bar_Hours:
        case Bar_Comparsion_HourHour:
        case Bar_AritmeticBalance_Hours:
        case Bar_VectorBalance_Hours:
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH"];
            break;
        case Bar_Days:
        case Bar_Comparsion_DayDay:
        case Bar_AritmeticBalance_Days:
        case Bar_VectorBalance_Days:
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            break;
        case Bar_Months:
        case Bar_Comparsion_MonthMonth:
        case Bar_AritmeticBalance_Months:
            [dateFormatter setDateFormat:@"YYYY LLLL"];
            break;
        case Bar_Years:
        case Bar_Comparsion_YearYear:
        case Bar_VectorBalance_Months:
            [dateFormatter setDateFormat:@"YYYY"];
            break;
        case Pie_HourRank:
            [dateFormatter setDateFormat:@"HH"];
            break;
        case Pie_WeekdayRank:
            [dateFormatter setDateFormat:@"EEE"];
            break;
        case Pie_MonthRank:
            [dateFormatter setDateFormat:@"LLL"];
            break;
        default:
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            break;
    }
    
  
    return dateFormatter;
}

- (GroupingDepth) getGroupungDepthForCurrentChartType {
    switch(chartType) {
        case Bar_Minutes:
        case Bar_Comparsion_MinMin:
        case Bar_AritmeticBalance_Minutes:
        case Bar_VectorBalance_Minutes:
            return gdMinutes;
        case Bar_Hours:
        case Bar_Comparsion_HourHour:
        case Bar_AritmeticBalance_Hours:
        case Bar_VectorBalance_Hours:
            return gdHours;
        case Bar_Days:
        case Bar_Comparsion_DayDay:
        case Bar_AritmeticBalance_Days:
        case Bar_VectorBalance_Days:
            return gdDays;
        case Bar_Months:
        case Bar_Comparsion_MonthMonth:
        case Bar_AritmeticBalance_Months:
        case Bar_VectorBalance_Months:
            return gdMonths;
        case Bar_Years:
        case Bar_Comparsion_YearYear:
        case Bar_AritmeticBalance_Years:
        case Bar_VectorBalance_Years:
            return gdYears;
        default:
            return gdNone;
    }
}

- (GroupBy) getGroupByForCurrentChartType {
    switch(chartType) {
        case Pie_HourRank:
            return gbHour;
        case Pie_WeekdayRank:
            return gbWeekday;
        case Pie_MonthRank:
            return gbMonth;
        default:
            return gbNone;
    }
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    return @"";
}

- (long)getTimestamp:(id)item {
    if ([item isKindOfClass:[NSDictionary class]]) {
        id date = [item valueForKey:@"date"];
        if ( [date isKindOfClass:[NSDate class]] ) {
            return [date timeIntervalSince1970];
        } else if ( [date isKindOfClass:[NSNumber class]] ) {
            return [date longValue];
        }
        return 0;
    }
    if ([item isKindOfClass:[SAMeasurementItem class]]) {
        return [((SAMeasurementItem *)item).date timeIntervalSince1970];
    }
    return 0;
}

-(void) addBarEntryTo:(NSMutableArray*) entries index:(int)idx time:(double)time timestamp:(long)timestamp item:(id)item {
}

-(void) addPieEntryTo:(NSMutableArray*) entries timestamp:(long)timestamp item:(id)item {
}

-(void) addLineEntryTo:(NSMutableArray*) entries index:(int)idx time:(double)time timestamp:(long)timestamp item:(id)item {
}

- (void) updateDescription {

    NSString *description = @"";
    NSString *noData = NSLocalizedString(@"No chart data available.", nil);
    
    if (_downloadProgress != nil) {
        description = NSLocalizedString(@"Retrieving data from the server...", nil);
        if ([_downloadProgress doubleValue] > 0) {
            description = [NSString stringWithFormat:@"%@ %0.2f%%", description, [_downloadProgress doubleValue]];
        }
        
        noData = description;
        description = [NSString stringWithFormat:@"%@ ", description];
    }
    
    if (unit) {
        if (description.length > 0) {
            description = [NSString stringWithFormat:@"%@ | ", description];
        }
        
        description = [NSString stringWithFormat:@"%@%@", description, unit];
    }
    
    if (self.combinedChart) {
        [self.combinedChart.chartDescription setText:description];
        self.combinedChart.noDataText = noData;
        [self.combinedChart setNeedsDisplay];
    }
    
    if (self.pieChart) {
        [self.pieChart.chartDescription setText:description];
        self.pieChart.noDataText = noData;
        [self.pieChart setNeedsDisplay];
    }
}

- (SABarChartDataSet *) newBarDataSetWithEntries:(NSArray *)entries {
    SABarChartDataSet *result = [[SABarChartDataSet alloc] initWithEntries:entries label:@""];
    result.drawValuesEnabled = NO;
    return result;
}

- (LineChartDataSet *) newLineDataSetWithEntries:(NSArray *)entries {
    LineChartDataSet *result = [[LineChartDataSet alloc] initWithEntries:entries label:@""];
    result.drawValuesEnabled = NO;
    result.drawCirclesEnabled = NO;
    result.drawFilledEnabled = YES;
    [result setMode: LineChartModeHorizontalBezier];
    [result setCubicIntensity:0.05];
    return result;
}

- (id<IChartMarker>)getMarker {
    return nil;
}

- (void) setMarkerForChart:(ChartViewBase *)chart {
    id marker = [self getMarker];
    [chart setMarker:marker];
    if (marker != nil && [marker isKindOfClass:[SAChartMarkerView class]]) {
        ((SAChartMarkerView*)marker).chartView = chart;
        ((SAChartMarkerView*)marker).chartHelper = self;
    }
    [chart setDrawMarkers:marker != nil];
}

- (void) prepareBarDataSet:(SABarChartDataSet*)barDataSet {}

- (void) prepareLineDataSet:(LineChartDataSet*)lineDataSet {}

- (void) loadCombinedChart {
    if (self.pieChart) {
        self.pieChart.hidden = YES;
    }
    
    if (!self.combinedChart) {
        return;
    }
    
    self.combinedChart.hidden = NO;
    [self.combinedChart.xAxis setValueFormatter:self];
    self.combinedChart.xAxis.labelCount = 3;
    self.combinedChart.leftAxis.drawLabelsEnabled = NO;
    self.combinedChart.legend.enabled = NO;
    self.combinedChart.data = nil;
    [self.combinedChart clear];

    [self updateDescription];
    
    NSMutableArray *barEntries = [[NSMutableArray alloc] init];
    NSMutableArray *lineEntries = [[NSMutableArray alloc] init];
    NSArray *data = [self getData];
  

    if (data && data.count > 0) {
        for(int a=0;a<data.count;a++) {
            id item = [data objectAtIndex:a];
            if (![item isKindOfClass:[NSDictionary class]]
                && ![item isKindOfClass:[SAMeasurementItem class]]) {
                break;
            }
            
            long time = [self getTimestamp:item];
    
            if (a == 0) {
                _minTimestamp = time;
            }
            
            double dtime = (time-_minTimestamp) / 600.0;
            
            [self addBarEntryTo:barEntries index:a time:dtime timestamp:time item:item];
            [self addLineEntryTo:lineEntries index:a time:dtime timestamp:time item:item];
        }
    }
    
    
    
    CombinedChartData *chartData = [[CombinedChartData alloc] init];
    
    if (barEntries.count > 0 && [self isComparsionChartType]) {
        for(NSUInteger a=barEntries.count-1;a>0;a--) {
            BarChartDataEntry *e1 = [barEntries objectAtIndex:a];
            BarChartDataEntry *e2 = [barEntries objectAtIndex:a-1];
            e1.yValues = @[[NSNumber numberWithDouble:e1.y-e2.y]];
        }
        
        [barEntries removeObjectAtIndex:0];
    }
    
    if (barEntries.count > 0) {
        SABarChartDataSet *barDataSet = [self newBarDataSetWithEntries:barEntries];
        [self prepareBarDataSet: barDataSet];
        
        BarChartData *barData = [[BarChartData alloc] initWithDataSet:barDataSet];
        chartData.barData = barData;
    }
 
    if (lineEntries.count > 0) {
        LineChartDataSet *lineDataSet = [self newLineDataSetWithEntries:lineEntries];
        [self prepareLineDataSet: lineDataSet];
        
        LineChartData *lineData = [[LineChartData alloc] initWithDataSet:lineDataSet];
        chartData.lineData = lineData;
    }
     
    
    [self setMarkerForChart:combinedChart];

    if (chartData.dataSets && chartData.dataSets.count > 0) {
        combinedChart.data = chartData;
    }
    
}

- (void) loadPieChart {
    
    if (combinedChart != nil) {
        combinedChart.hidden = YES;
    }
    
    if (pieChart == nil) {
        return;
    }
    
    pieChart.hidden = NO;
    pieChart.data = nil;
    [self.pieChart clear];
    
    
    [self updateDescription];
    
    NSMutableArray *pieEntries = [[NSMutableArray alloc] init];
    NSArray *data = [self getData];
    
    if (data && data.count > 0) {
        NSUInteger n = chartType == Pie_PhaseRank ? 1 : data.count;
        for(int a=0;a<n;a++) {
            id item = [data objectAtIndex:a];
            if (![item isKindOfClass:[NSDictionary class]]
                && ![item isKindOfClass:[SAMeasurementItem class]]) {
                break;
            }
            
            
            [self addPieEntryTo:pieEntries timestamp:[self getTimestamp:item] item:item];
        }
    }

    [pieEntries sortUsingComparator:^NSComparisonResult(id a, id b) {
        double d1 = ((PieChartDataEntry*)a).value;
        double d2 = ((PieChartDataEntry*)b).value;
                     
        if (d1 == d2) {
            return NSOrderedSame;
        }
        
        if (d1 > d2) {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
    }];
    
    [self setMarkerForChart:pieChart];

    if (pieEntries.count) {
        PieChartDataSet *pieDataSet = [[PieChartDataSet alloc] initWithEntries:pieEntries label:@""];
        pieDataSet.colors = [ChartColorTemplates material];
        
        PieChartData *chartData = [[PieChartData alloc] initWithDataSets:@[pieDataSet]];
        pieChart.data = chartData;
    }

}

- (NSString *)stringRepresentationOfChartType:(ChartType)ct {
    switch(ct) {
        case Bar_Minutes:
            return NSLocalizedString(@"Minutes", nil);
        case Bar_Hours:
            return NSLocalizedString(@"Hours", nil);
        case Bar_Days:
            return NSLocalizedString(@"Days", nil);
        case Bar_Months:
            return NSLocalizedString(@"Months", nil);
        case Bar_Years:
            return NSLocalizedString(@"Years", nil);
        case Bar_Comparsion_MinMin:
            return NSLocalizedString(@"Minute to minute comparison", nil);
        case Bar_Comparsion_HourHour:
            return NSLocalizedString(@"Hour to hour comparison", nil);
        case Bar_Comparsion_DayDay:
            return NSLocalizedString(@"Day to day comparison", nil);
        case Bar_Comparsion_MonthMonth:
            return NSLocalizedString(@"Month to month comparison", nil);
        case Bar_Comparsion_YearYear:
            return NSLocalizedString(@"Year to year comparison", nil);
        case Pie_HourRank:
            return NSLocalizedString(@"Ranking of hours", nil);
        case Pie_WeekdayRank:
            return NSLocalizedString(@"Ranking of weekdays", nil);
        case Pie_MonthRank:
            return  NSLocalizedString(@"Ranking of months", nil);
        case Pie_PhaseRank:
            return NSLocalizedString(@"Consumption according to phases", nil);
        case Bar_AritmeticBalance_Minutes:
            return NSLocalizedString(@"Arithmetic balance - Minutes", nil);
        case Bar_AritmeticBalance_Hours:
            return NSLocalizedString(@"Arithmetic balance - Hours", nil);
        case Bar_AritmeticBalance_Days:
            return NSLocalizedString(@"Arithmetic balance - Days", nil);
        case Bar_AritmeticBalance_Months:
            return NSLocalizedString(@"Arithmetic balance - Months", nil);
        case Bar_AritmeticBalance_Years:
            return NSLocalizedString(@"Arithmetic balance - Years", nil);
        case Bar_VectorBalance_Minutes:
            return NSLocalizedString(@"Vector balance - Minutes", nil);
        case Bar_VectorBalance_Hours:
            return NSLocalizedString(@"Vector balance - Hours", nil);
        case Bar_VectorBalance_Days:
            return NSLocalizedString(@"Vector balance - Days", nil);
        case Bar_VectorBalance_Months:
            return NSLocalizedString(@"Vector balance - Months", nil);
        case Bar_VectorBalance_Years:
            return NSLocalizedString(@"Vector balance - Years", nil);
    }
    
    return @"";
}

-(void) load {
    if ([self isPieChartType]) {
        [self loadPieChart];
    } else {
       [self loadCombinedChart];
    }
    
}

-(void) animate {
    if (combinedChart != nil
        && !combinedChart.hidden) {
        [combinedChart animateWithYAxisDuration:1];
    } else if (pieChart != nil && !pieChart.hidden) {
        [pieChart spinWithDuration:0.5 fromAngle:0 toAngle:-360.0 easingOption:ChartEasingOptionEaseInQuad];
    }
}

-(void)setDownloadProgress:(NSNumber *)downloadProgress {
    _downloadProgress = downloadProgress;
    [self updateDescription];
}

-(NSNumber *)downloadProgress {
    return _downloadProgress;
}

- (void) moveToXRange1:(double)xRange1 XRange2:(double) xRange2 {
    [self.combinedChart setVisibleXRangeMaximum:xRange1];
    [self.combinedChart moveViewToX:[self.combinedChart chartXMax]];
    [self.combinedChart setVisibleXRangeMaximum:xRange2];
}

- (void) moveToEnd {
    [self moveToXRange1:20 XRange2:1000];
}

- (long) minTimestamp {
    return _minTimestamp;
}

@end
