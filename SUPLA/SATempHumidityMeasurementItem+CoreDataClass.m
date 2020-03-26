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

#import "SATempHumidityMeasurementItem+CoreDataClass.h"

@implementation SATempHumidityMeasurementItem
- (void) assignJSONObject:(NSDictionary *)object {
    [super assignJSONObject:object];

    self.temperature = [self temperatureForKey:@"temperature" withObject:object];
    self.humidity = [self humidityForKey:@"humidity" withObject:object];
}


-(NSDecimalNumber*)humidityForKey:(NSString*)key withObject:(NSDictionary*)object {
   NSString *str = [object valueForKey:key];
    if (str != nil && ![str isKindOfClass:[NSNull class]]) {
        double humidity = [str doubleValue];
        if (humidity > -1) {
            return [[NSDecimalNumber alloc] initWithDouble:humidity];
        }
    }
    return nil;
}
@end
