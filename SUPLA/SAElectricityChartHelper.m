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

#import "SAElectricityChartHelper.h"
#import "SuplaApp.h"
#import "UIHelper.h"
#import "SUPLA-Swift.h"

@implementation SAElectricityChartHelper

@synthesize totalActiveEnergyPhase1;
@synthesize totalActiveEnergyPhase2;
@synthesize totalActiveEnergyPhase3;
@synthesize productionDataSource;

- (NSArray *)getData {
    NSDate *dateFrom = self.dateFrom;
    NSDate *dateTo = self.dateTo;
    
    if ([self isPieChartType]) {
        dateFrom = nil;
        dateTo = nil;
    }
    
    NSArray *fields;
    
    if ( productionDataSource ) {
        fields = @[@"phase1_rae",@"phase2_rae",@"phase3_rae"];
    } else {
        fields = @[@"phase1_fae",@"phase2_fae",@"phase3_fae"];
    }
        
    return [SAApp.DB getElectricityMeasurementsForChannelId:self.channelId dateFrom:dateFrom dateTo:dateTo groupBy:[self getGroupByForCurrentChartType] groupingDepth:[self getGroupungDepthForCurrentChartType] fields:fields];
}

- (NSNumber *)doubleValueForKey:(NSString *)key item:(NSDictionary *)i {
    NSNumber *result = [i valueForKey:key];
    return result == nil ? [NSNumber numberWithDouble:0.0] : result;
}

-(void) addBarEntryTo:(NSMutableArray*) entries index:(int)idx item:(id)item {
    if (![item isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSArray *values;
            
    if (productionDataSource) {
       values = @[[self doubleValueForKey:@"phase1_rae" item:item],
                [self doubleValueForKey:@"phase2_rae" item:item],
                [self doubleValueForKey:@"phase3_rae" item:item]];
    } else {
        values = @[[self doubleValueForKey:@"phase1_fae" item:item],
            [self doubleValueForKey:@"phase2_fae" item:item],
            [self doubleValueForKey:@"phase3_fae" item:item]];
    }

    [entries addObject:[[BarChartDataEntry alloc] initWithX:idx yValues:values]];
}

- (SABarChartDataSet *) newBarDataSetWithEntries:(NSArray *)entries {
    SABarChartDataSet *result = [super newBarDataSetWithEntries:entries];
    if (result) {
        result.stackLabels = @[NSLocalizedString(@"Phase 1", nil),
                               NSLocalizedString(@"Phase 2", nil),
                               NSLocalizedString(@"Phase 3", nil)];
        [result resetColors];
        result.colors = @[[UIColor phase1Color],
                          [UIColor phase2Color],
                          [UIColor phase3Color]];
    }
    return result;
}

-(void) addPieEntryTo:(NSMutableArray*) entries timestamp:(long)timestamp item:(id)item {
    
    if (![item isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    if (self.chartType == Pie_PhaseRank) {
        [entries addObject:[[PieChartDataEntry alloc] initWithValue:totalActiveEnergyPhase1 label:NSLocalizedString(@"Phase 1", nil)]];
        [entries addObject:[[PieChartDataEntry alloc] initWithValue:totalActiveEnergyPhase2 label:NSLocalizedString(@"Phase 2", nil)]];
        [entries addObject:[[PieChartDataEntry alloc] initWithValue:totalActiveEnergyPhase3 label:NSLocalizedString(@"Phase 3", nil)]];
    } else {
        double sum;
        
        if (productionDataSource) {
            sum = [[self doubleValueForKey:@"phase1_rae" item:item] doubleValue]
            + [[self doubleValueForKey:@"phase2_rae" item:item] doubleValue]
            + [[self doubleValueForKey:@"phase3_rae" item:item] doubleValue];
        } else {
            sum = [[self doubleValueForKey:@"phase1_fae" item:item] doubleValue]
            + [[self doubleValueForKey:@"phase2_fae" item:item] doubleValue]
            + [[self doubleValueForKey:@"phase3_fae" item:item] doubleValue];
        }
        
        NSDateFormatter *dateFormat = [self dateFormatterForCurrentChartType];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        
        [entries addObject:[[PieChartDataEntry alloc] initWithValue:sum label:[dateFormat stringFromDate:date]]];
    }

}

- (NSString *)stringRepresentationOfChartType:(ChartType)ct {
    if (productionDataSource && ct == Pie_PhaseRank) {
        return NSLocalizedString(@"Production according to phases", nil);
    }

    return [super stringRepresentationOfChartType:ct];
}

- (void) prepareBarDataSet:(SABarChartDataSet*)barDataSet {
    [super prepareBarDataSet:barDataSet];
   
    if ([self isComparsionChartType] && productionDataSource) {
        barDataSet.colors = @[[UIColor chartValueNegativeColor],
                              [UIColor chartValuePositiveColor]];
    }
}

-(NSString *)currency{
    return productionDataSource ? nil : super.currency;
}

@end
