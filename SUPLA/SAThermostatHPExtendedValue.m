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

#import "SAThermostatHPExtendedValue.h"

@implementation SAThermostatHPExtendedValue {
    double _waterMax;
    BOOL _online;
    double _ecoReductionTemperature;
    double _comfortTemp;
    double _ecoTemp;
    int _flags1;
    int _flags2;
    short _turboTime;
    int errors;
}

-(bool)assignThermostatValue:(TThermostat_ExtendedValue*)value {
    if (value) {
        
    }
    return false;
}

-(bool)assignExtendedValue:(SAChannelExtendedValue*)ev {
    if (ev != nil) {
        TThermostat_ExtendedValue thev;
        if ([ev getThermostatExtendedValue:&thev]) {
            return [self assignThermostatValue:&thev];
        }
    }
    return false;
}

-(bool)assignChannel:(SAChannel*)channel {
     return [self assignExtendedValue:channel.ev];
}

@end
