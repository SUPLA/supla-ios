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

#import "SUPLA-Swift.h"
#import "UIColor+SUPLA.h"

@implementation SAElectricityChartHelper {
    BOOL singlePhase;
}

@synthesize totalActiveEnergyPhase1;
@synthesize totalActiveEnergyPhase2;
@synthesize totalActiveEnergyPhase3;
@synthesize productionDataSource;

- (id<IChartMarker>)getMarker {
    if([self shouldShowManyPhases]) {
        return [SAElectricityMeterChartMarkerView viewFromXibIn: [NSBundle mainBundle]];
    } else {
        return [super getMarker];
    }
}

- (BOOL)shouldShowManyPhases {
    return !([self isBalanceChartType] ||
             [self isComparsionChartType] ||
             [self isPieChartType] ||
             singlePhase);
}

- (void)load {
    [super load];

    SAChannel *chn = [SAApp.DB fetchChannelById: self.channelId];

    singlePhase =
        (chn.flags & SUPLA_CHANNEL_FLAG_PHASE2_UNSUPPORTED) > 0 &&
        (chn.flags & SUPLA_CHANNEL_FLAG_PHASE3_UNSUPPORTED) > 0;

    self.combinedChart.highlightFullBarEnabled = NO;

}

- (NSArray *)getData {
    NSDate *dateFrom = self.dateFrom;
    NSDate *dateTo = self.dateTo;
    
    if ([self isPieChartType]) {
        dateFrom = nil;
        dateTo = nil;
    }
    
    NSArray *fields;
    
    if ( self.isBalanceChartType ) {
        if (self.isVectorBalanceChartType) {
            fields = @[@"fae_balanced", @"rae_balanced"];
        } else {
            fields = @[@"phase1_rae",@"phase2_rae",@"phase3_rae", @"phase1_fae",@"phase2_fae",@"phase3_fae"];
        }
        
    } else if ( productionDataSource ) {
        fields = @[@"phase1_rae",@"phase2_rae",@"phase3_rae"];
    } else {
        fields = @[@"phase1_fae",@"phase2_fae",@"phase3_fae"];
    }
    
    return [SAApp.DB getElectricityMeasurementsForChannelId:self.channelId dateFrom:dateFrom dateTo:dateTo groupBy:[self getGroupByForCurrentChartType] groupingDepth:[self getGroupungDepthForCurrentChartType] fields:fields];
}

-(void) addBarEntryTo:(NSMutableArray*) entries index:(int)idx item:(id)item {
    if (![item isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSArray *values;
    
    if (self.isBalanceChartType) {
        
        double cons = 0;
        double prod = 0;
        
        if (self.isVectorBalanceChartType) {
            cons = [[self doubleValueForKey:@"fae_balanced" item:item] doubleValue];
            prod = [[self doubleValueForKey:@"rae_balanced" item:item] doubleValue];

        } else {
            double cons1 = [[self doubleValueForKey:@"phase1_fae" item:item] doubleValue];
            double cons2 = [[self doubleValueForKey:@"phase2_fae" item:item] doubleValue];
            double cons3 = [[self doubleValueForKey:@"phase3_fae" item:item] doubleValue];
            
            double prod1 = [[self doubleValueForKey:@"phase1_rae" item:item] doubleValue];
            double prod2 = [[self doubleValueForKey:@"phase2_rae" item:item] doubleValue];
            double prod3 = [[self doubleValueForKey:@"phase3_rae" item:item] doubleValue];
            
            cons = cons1 + cons2 + cons3;
            prod = prod1 + prod2 + prod3;

        }
        
        double cons_diff = prod > cons ? cons : prod;
        double prod_diff = cons > prod ? prod : cons;
        
        values = @[[NSNumber numberWithDouble:prod_diff * -1],
        [NSNumber numberWithDouble:(prod - prod_diff) * -1],
        [NSNumber numberWithDouble:cons - cons_diff],
        [NSNumber numberWithDouble:cons_diff]];
        
    } else {
        if (productionDataSource) {
            values = @[[self doubleValueForKey:@"phase1_rae" item:item],
                       [self doubleValueForKey:@"phase2_rae" item:item],
                       [self doubleValueForKey:@"phase3_rae" item:item]];
        } else {
            values = @[[self doubleValueForKey:@"phase1_fae" item:item],
                       [self doubleValueForKey:@"phase2_fae" item:item],
                       [self doubleValueForKey:@"phase3_fae" item:item]];
        }
    }
    
    
    [entries addObject:[[BarChartDataEntry alloc] initWithX:idx yValues:values]];
}

- (SABarChartDataSet *) newBarDataSetWithEntries:(NSArray *)entries {
    SABarChartDataSet *result = [super newBarDataSetWithEntries:entries];
    if (result) {
        [result resetColors];
        
        if (self.isBalanceChartType) {
            result.stackLabels = @[@"",@"",@""];
            
            result.colors = @[[UIColor grayColor],
                              [UIColor chartValueNegativeColor],
                              [UIColor chartValuePositiveColor],
                              [UIColor grayColor]];
        } else {
            result.stackLabels = @[NSLocalizedString(@"Phase 1", nil),
                                   NSLocalizedString(@"Phase 2", nil),
                                   NSLocalizedString(@"Phase 3", nil)];
            
            result.colors = @[[UIColor phase1Color],
                              [UIColor phase2Color],
                              [UIColor phase3Color]];
        }
        
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
    
    
    if ((self.isComparsionChartType && productionDataSource)) {
        barDataSet.colors = @[[UIColor chartValueNegativeColor],
                              [UIColor chartValuePositiveColor]];
    }
}

-(NSString *)currency{
    return productionDataSource ? nil : super.currency;
}

@end
