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

#import "SAMeasurementItem+CoreDataClass.h"

@implementation SAMeasurementItem
- (void) assignJSONObject:(NSDictionary *)object {
    [self setDateAndDateParts: [NSDate dateWithTimeIntervalSince1970:[[object valueForKey:@"date_timestamp"] longLongValue]]];
}

- (void) assignMeasurementItem:(SAMeasurementItem*)source {
    self.channel_id = source.channel_id;
    [self setDateAndDateParts:source.date];
}
-(void)setDateAndDateParts:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                    | NSCalendarUnitMonth
                                    | NSCalendarUnitDay
                                    | NSCalendarUnitWeekday
                                    | NSCalendarUnitHour
                                    | NSCalendarUnitMinute
                                    | NSCalendarUnitSecond fromDate:date];

    
    // Unfortunately, date components can not have the "Transient"
    // property because they can not be grouped or filtered by this type of attribute.
    // Maybe someone will have a better idea.
    self.year = components.year;
    self.month = components.month;
    self.day = components.day;
    self.weekday = components.weekday;
    self.hour = components.hour;
    self.minute = components.minute;
    self.second = components.second;
    
    self.date = date;
}

- (BOOL) boolValueForKey:(NSString*)key withObject:(NSDictionary*)object {
    NSString *str = [object valueForKey:key];
     
    return str != nil
    && ![str isKindOfClass:[NSNull class]]
    && ([str boolValue] || [str intValue] > 0);
}

- (double) doubleForKey:(NSString*)key withObject:(NSDictionary*)object {
    NSString *str = [object valueForKey:key];
    return str == nil || [str isKindOfClass:[NSNull class]] ? 0.0 : [str doubleValue];
}

- (long long) longLongForKey:(NSString*)key withObject:(NSDictionary*)object {
    NSString *str = [object valueForKey:key];
    return str == nil || [str isKindOfClass:[NSNull class]] ? 0 : [str longLongValue];
}

-(NSDecimalNumber*)temperatureForKey:(NSString*)key withObject:(NSDictionary*)object {
   NSString *str = [object valueForKey:key];
    if (str != nil && ![str isKindOfClass:[NSNull class]]) {
        double temperature = [str doubleValue];
        if (temperature > -273) {
            return [[NSDecimalNumber alloc] initWithDouble:temperature];
        }
    }
    return nil;
}

@end
