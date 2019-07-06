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

@implementation SAChartHelper {
    long _minTimestamp;
    NSNumber *_downloadProgress;
    NSString *_unit;
}

@synthesize channelId;
@synthesize combinedChart;
@synthesize pieChart;

-(id)init {
    if (self = [super init]) {
        _minTimestamp = 0;
    }
    return self;
}

- (NSArray *)getData {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

- (long)getTimestamp:(NSDictionary *)item {
    ABSTRACT_METHOD_EXCEPTION;
    return 0;
}

-(void) addBarEntryTo:(NSArray*) entries index:(int)idx time:(long)time item:(NSDictionary*)item {
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

- (void) loadCombinedChart {
    if (self.pieChart) {
        self.pieChart.hidden = YES;
    }
    
    if (!self.combinedChart) {
        return;
    }
    

    self.combinedChart.hidden = NO;
    self.combinedChart.xAxis.labelCount = 3;
    self.combinedChart.leftAxis.drawLabelsEnabled = NO;
    self.combinedChart.legend.enabled = NO;
    self.combinedChart.data = nil;
    [self.combinedChart clear];

    [self updateDescription];
    
    NSArray *barEntries = [[NSArray alloc] init];
    NSArray *data = [self getData];
    
    if (data && data.count > 0) {
        
        _minTimestamp = [self getTimestamp:[data objectAtIndex:0]];
        
        for(int a=0;a<data.count;a++) {
            NSDictionary *item = [data objectAtIndex:0];
            long time = [self getTimestamp:item] / 600.0;
            [self addBarEntryTo:barEntries index:a time:time item:item];
        }
    }
    
    
    CombinedChartData *chartData = [[CombinedChartData alloc] init];
    
    if (barEntries.count > 0) {
        BarChartDataSet *barDataSet = [self newBarDataSetWithEntries:barEntries];
        [chartData addDataSet:barDataSet];
    }
    
    
    if (chartData.dataSets && chartData.dataSets.count > 0) {
        combinedChart.data = chartData;
    }
    
}

-(void) load {
    [self loadCombinedChart];
}

@end
