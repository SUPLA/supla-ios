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

@implementation SAElectricityChartHelper

- (NSArray *)getData {
    return [SAApp.DB getElectricityMeasurementsForChannelId:self.channelId dateFrom:self.dateFrom dateTo:self.dateTo groupingDepth:[self getGroupungDepthForCurrentChartType]];
}

- (NSNumber *)doubleValueForKey:(NSString *)key item:(NSDictionary *)i {
    NSNumber *result = [i valueForKey:key];
    return result == nil ? [NSNumber numberWithDouble:0.0] : result;
}

-(void) addBarEntryTo:(NSMutableArray*) entries index:(int)idx item:(id)item {
    if (![item isKindOfClass:[NSDictionary class]]) {
        return;
    }

    NSArray *values = @[[self doubleValueForKey:@"phase1_fae" item:item],
                        [self doubleValueForKey:@"phase2_fae" item:item],
                        [self doubleValueForKey:@"phase3_fae" item:item]];
    
    [entries addObject:[[BarChartDataEntry alloc] initWithX:idx yValues:values]];
    
}

- (BarChartDataSet *) newBarDataSetWithEntries:(NSArray *)entries {
    BarChartDataSet *result = [super newBarDataSetWithEntries:entries];
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

@end
