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

#import "SAIncrementalMeterChartHelper.h"
#import "SuplaApp.h"
#import "SUPLA-Swift.h"
#import "UIColor+SUPLA.h"

@implementation SAIncrementalMeterChartHelper {
    NSMutableArray *_xAxisStrings;
}

@synthesize currency;
@synthesize pricePerUnit;

- (id<IChartMarker>) getMarker {
    return [SAIncrementalMeterChartMarkerView viewFromXibIn:[NSBundle mainBundle]];
}

-(void) addBarEntryTo:(NSMutableArray*) entries index:(int)idx item:(id)item {
    ABSTRACT_METHOD_EXCEPTION;
}

-(void) addBarEntryTo:(NSMutableArray*) entries index:(int)idx time:(double)time timestamp:(long)timestamp item:(id)item {
    NSDateFormatter *dateFormat = [self dateFormatterForCurrentChartType];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    [_xAxisStrings addObject: [dateFormat stringFromDate:date]];
    [self addBarEntryTo:entries index:idx item:item];
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    int idx = (int)value;
    
    if (idx >=0 && idx < _xAxisStrings.count) {
        return [_xAxisStrings objectAtIndex:idx];
    }
    return @"";
}

- (void) load {
    _xAxisStrings = [[NSMutableArray alloc] init];
    [super load];
}

- (void) prepareBarDataSet:(SABarChartDataSet*)barDataSet {
    
    if ([self isComparsionChartType]) {
        barDataSet.colorDependsOnTheValue = YES;
        [barDataSet resetColors];
        barDataSet.colors = @[[UIColor chartValuePositiveColor],
                              [UIColor chartValueNegativeColor]];
    }
}
@end
