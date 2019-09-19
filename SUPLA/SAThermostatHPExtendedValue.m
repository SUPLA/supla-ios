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

#define PROG_ECO 1
#define PROG_COMFORT 2

@implementation SAThermostatHPExtendedValue
- (BOOL)sheduledComfortProgramForDay:(short)day andHour:(short)hour {
    return [self sheduledValueForDay:day andHour:hour] == PROG_COMFORT;
}

- (int)turboTime {
    return [self valuesWithIndex:4];
}

- (double)waterMax {
    return [self presetThemperatureWithIndex:2];
}

- (double)ecoReductionTemperature {
    return [self presetThemperatureWithIndex:3];
}

- (double)comfortTemp {
    return [self presetThemperatureWithIndex:4];
}

- (double)ecoTemp {
    return [self presetThemperatureWithIndex:5];
}

@end

@implementation SAChannelExtendedValue (SAThermostatHPExtendedValue)

- (SAThermostatHPExtendedValue*)thermostatHP {
    return [[SAThermostatHPExtendedValue alloc] initWithExtendedValue:self];
}
@end
