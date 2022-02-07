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
#import "SAThermostatExtendedValue.h"
#import "supla-client.h"

@implementation SAThermostatExtendedValue {
    TThermostat_ExtendedValue _thev;
}

-(id)initWithExtendedValue:(SAChannelExtendedValue *)ev {
    if ([super initWithExtendedValue:ev]
        && [self getThermostatExtendedValue:&_thev]) {
        return self;
    }
    return nil;
}

- (BOOL) getThermostatExtendedValue:(TThermostat_ExtendedValue*)thev {
    if (thev == NULL) {
        return NO;
    }
    
    __block BOOL result = NO;
    
    [self forEach:^BOOL(TSuplaChannelExtendedValue * _Nonnull ev) {
        result = srpc_evtool_v1_extended2thermostatextended(ev, thev);
        return !result;
    }];

    return result;
}

- (BOOL) isFieldSet:(unsigned char)field {
    return (_thev.Fields & field) != 0 ? YES : NO;
}

- (double) measuredThemperatureWithIndex:(short)idx {
    return idx >= 0
    && idx <= 10
    && [self isFieldSet:THERMOSTAT_FIELD_MeasuredTemperatures]
    ? _thev.MeasuredTemperature[idx] * 0.01 : 0;
}

- (double) presetThemperatureWithIndex:(short)idx {
    return idx >= 0
    && idx <= 10
    && [self isFieldSet:THERMOSTAT_FIELD_PresetTemperatures]
    ? _thev.PresetTemperature[idx] * 0.01 : 0;
}

- (int) flagsWithIndex:(short)idx {
    return idx >= 0
    && idx <= 8
    && [self isFieldSet:THERMOSTAT_FIELD_Flags]
    ? _thev.Flags[idx] : 0;
}

- (int) valuesWithIndex:(short)idx {
    return idx >= 0
    && idx <= 8
    && [self isFieldSet:THERMOSTAT_FIELD_Values]
    ? _thev.Values[idx] : 0;
}

- (TThermostat_Time) time {

    if ([self isFieldSet:THERMOSTAT_FIELD_Time]) {
       return _thev.Time;
    };
    
    TThermostat_Time time;
    memset(&time, 0, sizeof(TThermostat_Time));
    return time;
}

- (short)hour {
    return [self isFieldSet:THERMOSTAT_FIELD_Time] ? _thev.Time.hour : -1;
}

- (short)minute {
    return [self isFieldSet:THERMOSTAT_FIELD_Time] ? _thev.Time.min : -1;
}

- (short)second {
    return [self isFieldSet:THERMOSTAT_FIELD_Time] ? _thev.Time.sec : -1;
}

- (short)dayOfWeek {
    return [self isFieldSet:THERMOSTAT_FIELD_Time] ? _thev.Time.dayOfWeek : -1;
}

- (unsigned char)sheduleValueType {
    return [self isFieldSet:THERMOSTAT_FIELD_Schedule] ? _thev.Schedule.ValueType : -1;
}

- (BOOL) isSheludeProgramValueType {
    return ([self sheduleValueType] & THERMOSTAT_SCHEDULE_HOURVALUE_TYPE_PROGRAM) > 0 ? YES : NO;
}

- (char)sheduledValueForDay:(short)day andHour:(short)hour  {
    return [self isFieldSet:THERMOSTAT_FIELD_Schedule]
    && day >= 1
    && day <= 7
    && hour >= 0
    && hour < 24 ? _thev.Schedule.HourValue[day-1][hour] : 0;
}

@end
