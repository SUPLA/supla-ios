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
#import "SAImpulseCounterChartHelper.h"
#import "SuplaApp.h"

@implementation SAImpulseCounterChartHelper

- (NSArray *)getData {
    NSDate *dateFrom = self.dateFrom;
    NSDate *dateTo = self.dateTo;
    
    if ([self isPieChartType]) {
        dateFrom = nil;
        dateTo = nil;
    }
            
    return [SAApp.DB getImpulseCounterMeasurementsForChannelId:self.channelId dateFrom:dateFrom dateTo:dateTo groupBy:[self getGroupByForCurrentChartType] groupingDepth:[self getGroupungDepthForCurrentChartType]];
}

-(void) addBarEntryTo:(NSMutableArray*) entries index:(int)idx item:(id)item {
    if (![item isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [entries addObject:[[BarChartDataEntry alloc] initWithX:idx yValues:@[[self doubleValueForKey:@"calculated_value" item:item]]]];
}

-(void) addPieEntryTo:(NSMutableArray*) entries timestamp:(long)timestamp item:(id)item {
    
    if (![item isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSDateFormatter *dateFormat = [self dateFormatterForCurrentChartType];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    [entries addObject:[[PieChartDataEntry alloc] initWithValue:[[self doubleValueForKey:@"calculated_value" item:item] doubleValue] label:[dateFormat stringFromDate:date]]];
}
@end
