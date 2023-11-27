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

#import "SuplaConfigIntegrator.h"
#import "SUPLA-Swift.h"

@implementation SuplaConfigIntegrator

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

+ (TSCS_ChannelConfig) mockHvacConfig {
    TSCS_ChannelConfig config = {};
    
    TChannelConfig_HVAC* hvac = (TChannelConfig_HVAC*) config.Config;
    hvac->MainThermometerChannelId = 123;
    hvac->AuxThermometerChannelId = 234;
    hvac->AuxThermometerType = SUPLA_HVAC_AUX_THERMOMETER_TYPE_WATER;
    hvac->AntiFreezeAndOverheatProtectionEnabled = 1;
    hvac->AvailableAlgorithms = SUPLA_HVAC_ALGORITHM_ON_OFF_SETPOINT_MIDDLE | SUPLA_HVAC_ALGORITHM_ON_OFF_SETPOINT_AT_MOST;
    hvac->UsedAlgorithm = SUPLA_HVAC_ALGORITHM_ON_OFF_SETPOINT_AT_MOST;
    hvac->MinOnTimeS = 16;
    hvac->MinOffTimeS = 24;
    hvac->OutputValueOnError = 0;
    hvac->Subfunction = SUPLA_HVAC_SUBFUNCTION_HEAT;
    
    hvac->Temperatures.Index = 0x3FFFF;
    hvac->Temperatures.Temperature[0] = 100;
    hvac->Temperatures.Temperature[1] = 200;
    hvac->Temperatures.Temperature[2] = 300;
    hvac->Temperatures.Temperature[3] = 400;
    hvac->Temperatures.Temperature[4] = 500;
    hvac->Temperatures.Temperature[5] = 600;
    hvac->Temperatures.Temperature[6] = 700;
    hvac->Temperatures.Temperature[7] = 800;
    hvac->Temperatures.Temperature[8] = 900;
    hvac->Temperatures.Temperature[9] = 1000;
    hvac->Temperatures.Temperature[10] = 1100;
    hvac->Temperatures.Temperature[11] = 1200;
    hvac->Temperatures.Temperature[12] = 1300;
    hvac->Temperatures.Temperature[13] = 1400;
    hvac->Temperatures.Temperature[14] = 1500;
    hvac->Temperatures.Temperature[15] = 1600;
    hvac->Temperatures.Temperature[16] = 1700;
    hvac->Temperatures.Temperature[17] = 1800;
    hvac->Temperatures.Temperature[18] = 1900;
    hvac->Temperatures.Temperature[19] = 2000;
    hvac->Temperatures.Temperature[20] = 2100;
    hvac->Temperatures.Temperature[21] = 2200;
    hvac->Temperatures.Temperature[22] = 2300;
    hvac->Temperatures.Temperature[23] = 2400;
    
    return config;
}

+ (TSCS_ChannelConfig) mockWeeklyScheduleConfig {
    TSCS_ChannelConfig config = {};
    TChannelConfig_WeeklySchedule* weekly = (TChannelConfig_WeeklySchedule*) config.Config;
    
    for (int i = 0; i<SUPLA_WEEKLY_SCHEDULE_PROGRAMS_MAX_SIZE; i++) {
        weekly->Program[i].Mode = i < 2 ? SUPLA_HVAC_MODE_NOT_SET : SUPLA_HVAC_MODE_DRY;
        weekly->Program[i].SetpointTemperatureCool = (i + 1) * 100;
        weekly->Program[i].SetpointTemperatureHeat = (i + 1) * 200;
    }
    
    for (int i = 0; i < SUPLA_WEEKLY_SCHEDULE_VALUES_SIZE/2; i++) {
        if (i < 48) {
            weekly->Quarters[i] = 0x11;
        } else if (i < 96) {
            weekly->Quarters[i] = 0x22;
        } else if (i < 144) {
            weekly->Quarters[i] = 0x33;
        } else if (i < 192) {
            weekly->Quarters[i] = 0x44;
        } else {
            weekly->Quarters[i] = 0;
        }
    }
    
    return config;
}

+ (TSCS_DeviceConfig) mockDeviceConfigWithUserInterfaceField: (BOOL) disableUserInterfaceField {
    TSCS_DeviceConfig config = {};
    
    config.DeviceId = 123456;
    config.EndOfDataFlag = 1;
    config.AvailableFields = SUPLA_DEVICE_CONFIG_FIELD_STATUS_LED | SUPLA_DEVICE_CONFIG_FIELD_SCREEN_BRIGHTNESS | SUPLA_DEVICE_CONFIG_FIELD_BUTTON_VOLUME | SUPLA_DEVICE_CONFIG_FIELD_DISABLE_USER_INTERFACE | SUPLA_DEVICE_CONFIG_FIELD_AUTOMATIC_TIME_SYNC | SUPLA_DEVICE_CONFIG_FIELD_HOME_SCREEN_OFF_DELAY | SUPLA_DEVICE_CONFIG_FIELD_HOME_SCREEN_CONTENT;
    config.Fields = SUPLA_DEVICE_CONFIG_FIELD_STATUS_LED | SUPLA_DEVICE_CONFIG_FIELD_SCREEN_BRIGHTNESS | SUPLA_DEVICE_CONFIG_FIELD_BUTTON_VOLUME | SUPLA_DEVICE_CONFIG_FIELD_AUTOMATIC_TIME_SYNC | SUPLA_DEVICE_CONFIG_FIELD_HOME_SCREEN_OFF_DELAY | SUPLA_DEVICE_CONFIG_FIELD_HOME_SCREEN_CONTENT;
    if (disableUserInterfaceField) {
        config.Fields |= SUPLA_DEVICE_CONFIG_FIELD_DISABLE_USER_INTERFACE;
    }
    
    TDeviceConfig_StatusLed statusLed = {};
    statusLed.StatusLedType = 1;
    
    TDeviceConfig_ScreenBrightness screenBrightness = {};
    screenBrightness.AdjustmentForAutomatic = 10;
    screenBrightness.Automatic = 1;
    screenBrightness.ScreenBrightness = 50;
    
    TDeviceConfig_ButtonVolume buttonVolume = {};
    buttonVolume.Volume = 80;
    
    TDeviceConfig_DisableUserInterface disableUserInterface = {};
    disableUserInterface.DisableUserInterface = 2;
    disableUserInterface.minAllowedTemperatureSetpointFromLocalUI = 1200;
    disableUserInterface.maxAllowedTemperatureSetpointFromLocalUI = 2500;
    
    TDeviceConfig_AutomaticTimeSync automaticTimeSync = {};
    automaticTimeSync.AutomaticTimeSync = 1;
    
    TDeviceConfig_HomeScreenOffDelay homeScreenOffDelay = {};
    homeScreenOffDelay.HomeScreenOffDelayS = 10;
    
    TDeviceConfig_HomeScreenContent homeScreenContent = {};
    homeScreenContent.ContentAvailable = SUPLA_DEVCFG_HOME_SCREEN_CONTENT_NONE | SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TEMPERATURE | SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TEMPERATURE_AND_HUMIDITY | SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TIME | SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TIME_DATE | SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TEMPERATURE_TIME | SUPLA_DEVCFG_HOME_SCREEN_CONTENT_MAIN_AND_AUX_TEMPERATURE;
    homeScreenContent.HomeScreenContent = SUPLA_DEVCFG_HOME_SCREEN_CONTENT_TEMPERATURE_AND_HUMIDITY;
    
    int size = 0;
    memcpy(config.Config, &statusLed, sizeof(TDeviceConfig_StatusLed));
    size += sizeof(TDeviceConfig_StatusLed);
    
    memcpy(config.Config + size, &screenBrightness, sizeof(TDeviceConfig_ScreenBrightness));
    size += sizeof(TDeviceConfig_ScreenBrightness);
    
    memcpy(config.Config + size, &buttonVolume, sizeof(TDeviceConfig_ButtonVolume));
    size += sizeof(TDeviceConfig_ButtonVolume);
    
    if (disableUserInterfaceField) {
        memcpy(config.Config + size, &disableUserInterface, sizeof(TDeviceConfig_DisableUserInterface));
        size += sizeof(TDeviceConfig_DisableUserInterface);
    }
    
    memcpy(config.Config + size, &automaticTimeSync, sizeof(TDeviceConfig_AutomaticTimeSync));
    size += sizeof(TDeviceConfig_AutomaticTimeSync);
    
    memcpy(config.Config + size, &homeScreenOffDelay, sizeof(TDeviceConfig_HomeScreenOffDelay));
    size += sizeof(TDeviceConfig_HomeScreenOffDelay);
    
    memcpy(config.Config + size, &homeScreenContent, sizeof(TDeviceConfig_HomeScreenContent));
    size += sizeof(TDeviceConfig_HomeScreenContent);
    
    config.ConfigSize = size;
    
    return config;
}

@end
