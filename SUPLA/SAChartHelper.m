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
    NSString *_unit;
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
        chartType = Bar_Monthly;
    }
    return self;
}

- (NSArray *)getData {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

-(NSDateFormatter *) dateFormatterForCurrentChartType {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    switch(chartType) {
        case Bar_Hourly:
        case Bar_Comparsion_HourHour:
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH"];
            break;
        case Bar_Daily:
        case Bar_Comparsion_DayDay:
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            break;
        case Bar_Monthly:
        case Bar_Comparsion_MonthMonth:
            [dateFormatter setDateFormat:@"YYYY LLLL"];
            break;
        case Bar_Yearly:
        case Bar_Comparsion_YearYear:
            [dateFormatter setDateFormat:@"YYYY"];
            break;
        default:
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            break;
    }
    
  
    return dateFormatter;
}

- (GroupingDepth) getGroupungDepthForCurrentChartType {
    switch(chartType) {
        case Bar_Hourly:
        case Bar_Comparsion_HourHour:
            return gdHourly;
        case Bar_Daily:
        case Bar_Comparsion_DayDay:
            return gdDaily;
        case Bar_Monthly:
        case Bar_Comparsion_MonthMonth:
            return gdMonthly;
        case Bar_Yearly:
        case Bar_Comparsion_YearYear:
            return gdYearly;
        default:
            return gdMinutely;
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
    ABSTRACT_METHOD_EXCEPTION;
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
    
    if (_unit) {
        if (description.length > 0) {
            description = [NSString stringWithFormat:@"%@ | ", description];
        }
        
        description = [NSString stringWithFormat:@"%@%@", description, _unit];
    }
    
    if (self.combinedChart) {
        [self.combinedChart.chartDescription setText:description];
        self.combinedChart.noDataText = noData;
    }
    
    if (self.pieChart) {
        [self.pieChart.chartDescription setText:description];
        self.pieChart.noDataText = noData;
    }
}

- (BarChartDataSet *) newBarDataSetWithEntries:(NSArray *)entries {
    BarChartDataSet *result = [[BarChartDataSet alloc] initWithEntries:entries label:@""];
    result.drawValuesEnabled = NO;
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
            
            [self addBarEntryTo:barEntries index:a time:time / 600.0 timestamp:time item:item];
        }
    }
    
    CombinedChartData *chartData = [[CombinedChartData alloc] init];
    
    if (barEntries.count > 0) {
        BarChartDataSet *barDataSet = [self newBarDataSetWithEntries:barEntries];
        
        BarChartData *barData = [[BarChartData alloc] initWithDataSet:barDataSet];
        chartData.barData = barData;
    }
    
    [self setMarkerForChart:combinedChart];

    if (chartData.dataSets && chartData.dataSets.count > 0) {
        combinedChart.data = chartData;
    }
    
}

-(void) load {
    [self loadCombinedChart];
}



@end
