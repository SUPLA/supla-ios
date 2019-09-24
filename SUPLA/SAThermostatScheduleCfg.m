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

#import "SAThermostatScheduleCfg.h"

@interface SAThermostatScheduleCfgGroup : NSObject
-(void) getHourValue:(char[24])value;
-(void) setHourValue:(char[24])value;
-(BOOL) hourValueEqualTo:(char[24])value;
@property (nonatomic, assign) SAHourValueType valueType;
@property (nonatomic, assign) int weekDays;
@end

@implementation SAThermostatScheduleCfgGroup {
    char _hourValue[24];
}

@synthesize valueType;
@synthesize weekDays;

-(id) init {
    if (self = [super init]) {
        self.valueType = kTEMPERATURE;
        self.weekDays = 0;
        memset(_hourValue, 0, sizeof(_hourValue));
    }
    return self;
}

-(void) getHourValue:(char[24])value {
    memcpy(value, _hourValue, sizeof(_hourValue));
}

-(void) setHourValue:(char[24])value {
    memcpy(_hourValue, value, sizeof(_hourValue));
}


-(BOOL) hourValueEqualTo:(char[24])value {
    return memcmp(_hourValue, value, sizeof(_hourValue)) == 0;
}

- (void)setValue:(char)value forHour:(short)hour{
    if (hour >=0 && hour <24) {
        _hourValue[hour] = value;
    }
}

- (char)valueForHour:(short)hour {
    return hour >= 0 && hour < 24 ? _hourValue[hour] : 0;
}
@end

@implementation SAThermostatScheduleCfg {
    NSMutableArray *_groups;
}

-(id) init {
    if (self = [super init]) {
        _groups = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setValue:(char)value ofType:(SAHourValueType)type forWeekday:(SAWeekDay)weekday andHour:(short)hour {
    if (hour < 0) {
        hour = 0;
    } else if (hour > 23) {
        hour = 23;
    }
    
    SAThermostatScheduleCfgGroup *group = nil;
    char hourValue[24];
    memset(hourValue, 0, sizeof(hourValue));
    int a;
    
    for(a=0;a<_groups.count;a++) {
        group = [_groups objectAtIndex:a];
        if ((group.weekDays & weekday) > 0) {
            group.weekDays = group.weekDays ^ weekday;
            [group getHourValue:hourValue];
            if (group.weekDays == 0) {
                [_groups removeObject:group];
            }
            break;
        }
    }
    
    hourValue[hour] = value;
    
    for(a=0;a<_groups.count;a++) {
        group = [_groups objectAtIndex:a];
        if ( group.valueType == type
            && [group hourValueEqualTo:hourValue]) {
            group.weekDays = group.weekDays | weekday;
            break;
        }
    }
    
    if (a>=_groups.count) {
        group = [[SAThermostatScheduleCfgGroup alloc] init];
        group.weekDays = weekday;
        [group setHourValue:hourValue];
        group.valueType = type;
        [_groups addObject:group];
    }
}

- (void)setTemperature:(char)temperature forHour:(short)hour weekday:(SAWeekDay)wd {
    [self setValue:temperature ofType:kTEMPERATURE forWeekday:wd andHour:hour];
}

- (void)setProgram:(char)program forHour:(short)hour weekday:(SAWeekDay)wd {
    [self setValue:program ofType:kPROGRAM forWeekday:wd andHour:hour];
}

- (int)weekDaysForGroupIndex:(int)idx {
    if (idx >= 0 && idx < _groups.count) {
        return ((SAThermostatScheduleCfgGroup*)[_groups objectAtIndex:idx]).weekDays;
    }

    return 0;
}

- (SAHourValueType)valueTypeForGroupIndex:(int)idx {
    if (idx >= 0 && idx < _groups.count) {
        return ((SAThermostatScheduleCfgGroup*)[_groups objectAtIndex:idx]).valueType;
    }

    return kTEMPERATURE;
}

- (void) getHourValue:(char*)value forGroupIndex:(int)idx {
    if (idx >= 0 && idx < _groups.count) {
        [[_groups objectAtIndex:idx] getHourValue:value];
        return;
    }
    
    memset(value, 0, 24);
}

- (BOOL) hourValueEqualTo:(char*)value forGroupIndex:(int)idx {
    if (idx >= 0 && idx < _groups.count) {
        return [[_groups objectAtIndex:idx] hourValueEqualTo:value];
    }
    
    return false;
}

-(NSUInteger)groupCount {
    return _groups.count;
}

- (void)clear {
    [_groups removeAllObjects];
}

- (SAWeekDay)weekDayByIndex:(short)idx {
    switch(idx) {
        case 2:  return kMONDAY;
        case 3:  return kTUESDAY;
        case 4:  return kWEDNESDAY;
        case 5:  return kTHURSDAY;
        case 6:  return kFRIDAY;
        case 7:  return kSATURDAY;
        default:  return kSUNDAY;
    }
}

@end
