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

#import "SuplaChannelConfigIntegrator.h"
#import "SUPLA-Swift.h"

@implementation SuplaChannelConfigIntegrator

+ (void) setProgramWith: (UInt8) programId withMode: (UInt8) mode withHeatTemp: (short) heatTemp withCoolTemp: (short) coolTemp inConfig: (TSCS_ChannelConfig*) config {
    TChannelConfig_WeeklySchedule* weeklyConfig = (TChannelConfig_WeeklySchedule*) config->Config;
    
    weeklyConfig->Program[programId].Mode = mode;
    weeklyConfig->Program[programId].SetpointTemperatureHeat = heatTemp;
    weeklyConfig->Program[programId].SetpointTemperatureCool = coolTemp;
}

+ (TWeeklyScheduleProgram) getProgramWith: (int) programId fromConfig: (TChannelConfig_WeeklySchedule) config {
    return config.Program[programId];
}

+ (void) setQuarterProgram: (UInt8) program forIndex: (int) index inConfig: (TSCS_ChannelConfig*) config {
    TChannelConfig_WeeklySchedule* weeklyConfig = (TChannelConfig_WeeklySchedule*) config->Config;
    if (index >=0 && index < sizeof(weeklyConfig->Quarters)) {
        weeklyConfig->Quarters[index] |= program;
    }
}

+ (UInt8) getQuarterProgramFor: (int) index inConfig: (TChannelConfig_WeeklySchedule) config {
    if (index >=0 && index < sizeof(config.Quarters)) {
        return config.Quarters[index];
    }
    
    return 0;
}

+ (TChannelConfig_WeeklySchedule) extractWeeklyConfigFrom: (TSCS_ChannelConfig) config {
    return *((TChannelConfig_WeeklySchedule*) config.Config);
}


+ (TChannelConfig_HVAC) extractHvacConfigFrom: (TSCS_ChannelConfig) config {
    return *((TChannelConfig_HVAC*) config.Config);
}


+ (int16_t) extractTemperatureFrom: (THVACTemperatureCfg) config forIndex: (int) index {
    return config.Temperature[index];
}

+ (int) suplaWeeklyScheduleValuesSize: (TChannelConfig_WeeklySchedule) config {
    return sizeof(config.Quarters);
}

@end
