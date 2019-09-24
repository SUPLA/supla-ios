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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    kSUNDAY = 0x1,
    kMONDAY = 0x2,
    kTUESDAY = 0x4,
    kWEDNESDAY = 0x8,
    kTHURSDAY = 0x10,
    kFRIDAY = 0x20,
    kSATURDAY = 0x40,
} SAWeekDay;

typedef enum {
    kTEMPERATURE= 0,
    kPROGRAM = 1,
} SAHourValueType;

@interface SAThermostatScheduleCfg : NSObject
- (void)setTemperature:(char)temperature forHour:(short)hour weekday:(SAWeekDay)wd;
- (void)setProgram:(char)program forHour:(short)hour weekday:(SAWeekDay)wd;
- (int)weekDaysForGroupIndex:(int)idx;
- (SAHourValueType)valueTypeForGroupIndex:(int)idx;
- (void) getHourValue:(char* _Nonnull)value forGroupIndex:(int)idx;
- (BOOL) hourValueEqualTo:(char* _Nonnull)value forGroupIndex:(int)idx;
- (void)clear;
- (SAWeekDay)weekDayByIndex:(short)idx;
   
@property (readonly) NSUInteger groupCount;
@end

NS_ASSUME_NONNULL_END
