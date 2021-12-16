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

#import "SATemperatureChartHelper.h"
#import "SuplaApp.h"

#import "SUPLA-Swift.h"
#import "UIColor+SUPLA.h"

@implementation SATemperatureChartHelper {
    TemperaturePresenter *_presenter;
}

-(id)init {
    if (self = [super init]) {
        self.chartType = Bar_Minutes;
        _presenter = [Config new].currentTemperaturePresenter;
    }
    return self;
}

- (id<IChartMarker>) getMarker {
    return [SAChartMarkerView viewFromXibIn:[NSBundle mainBundle]];
}

- (NSArray *)getData {
    return [SAApp.DB getTemperatureMeasurementsForChannelId:self.channelId dateFrom:self.dateFrom dateTo:self.dateTo];
}

-(void) addLineEntryTo:(NSMutableArray*) entries index:(int)idx time:(double)time timestamp:(long)timestamp item:(id)item {
    if (![item isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [entries addObject:[[ChartDataEntry alloc] initWithX:time y:[[self convertedDoubleValueForKey:@"temperature" item:item] doubleValue]]];
}

- (NSNumber*)convertedDoubleValueForKey: (NSString *)key item: (NSDictionary *)d {
    return [NSNumber numberWithDouble:
            [_presenter converted: [self doubleValueForKey:key
                                                      item:d].floatValue]];
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    NSDateFormatter *dateFormat = [self dateFormatterForCurrentChartType];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.minTimestamp+value*600];
      
    return [dateFormat stringFromDate:date];
}

- (void) prepareLineDataSet:(LineChartDataSet*)lineDataSet {
    lineDataSet.fillColor = [UIColor chartTemperatureFillColor];
    lineDataSet.colors = @[[UIColor chartTemperatureLineColor]];
}
@end
