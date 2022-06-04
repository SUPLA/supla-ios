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

#import "SAChannelBase+CoreDataClass.h"
#import "proto.h"
#import "SUPLA-Swift.h"

@implementation SAChannelBase

- (BOOL) setChannelLocation:(_SALocation*)location {
    
    if ( self.location != location ) {
        self.location = location;
        return YES;
    }
    
    return NO;
}


- (BOOL) setChannelFunction:(int)function {
    
    if ( self.func != function ) {
        self.func = function;
        return YES;
    }
    
    return NO;
}

- (BOOL) number:(NSNumber*)n1 isEqualToNumber:(id)n2 {
    
    if ( n1 == nil && n2 != nil )
        return NO;
    
    if ( n2 == nil && n1 != nil )
        return NO;
    
    if ( [n1 isKindOfClass:[NSNumber class]] == NO || [n2 isKindOfClass:[NSNumber class]] == NO )
        return NO; // is unknown
    
    if ( n1 != nil && n2 != nil && [n1 isEqualToNumber:n2] == NO )
        return NO;
    
    return YES;
}

- (BOOL) setChannelCaption:(char*)caption {
    
    NSString *_caption = [NSString stringWithUTF8String:caption];
    
    if ( [self.caption isEqualToString:_caption] == NO  ) {
        self.caption = _caption;
        return YES;
    }
    
    return NO;
}

- (BOOL) setItemVisible:(int)visible {
    
    if ( self.visible != visible ) {
        self.visible = visible;
        return YES;
    }
    
    return NO;
}

- (BOOL) setChannelAltIcon:(int)altIcon {
    
    if ( self.alticon != altIcon ) {
        self.alticon = altIcon;
        return YES;
    }
    
    return NO;
}

- (BOOL) setChannelFlags:(int)flags {
    
    if ( self.flags != flags ) {
        self.flags = flags;
        return YES;
    }
    
    return NO;
}

- (BOOL) setLocationId:(int)locationId {
    if ( self.location_id != locationId ) {
        self.location_id = locationId;
        return YES;
    }
    
    return NO;
}

- (BOOL) setRemoteId:(int)remoteId {
    if ( self.remote_id != remoteId ) {
        self.remote_id = remoteId;
        return YES;
    }
    
    return NO;
}

- (BOOL) setUserIconId:(int)userIconId {
    if ( self.usericon_id != userIconId ) {
        self.usericon_id = userIconId;
        return YES;
    }
    
    return NO;
}

+ (int) functionBitToFunctionNumber:(int)bit {
    switch (bit) {
        case SUPLA_BIT_FUNC_CONTROLLINGTHEGATEWAYLOCK:
            return SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK;
        case SUPLA_BIT_FUNC_CONTROLLINGTHEGATE:
            return SUPLA_CHANNELFNC_CONTROLLINGTHEGATE;
        case SUPLA_BIT_FUNC_CONTROLLINGTHEGARAGEDOOR:
            return SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR;
        case SUPLA_BIT_FUNC_CONTROLLINGTHEDOORLOCK:
            return SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK;
        case SUPLA_BIT_FUNC_CONTROLLINGTHEROLLERSHUTTER:
            return SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER;
        case SUPLA_BIT_FUNC_CONTROLLINGTHEROOFWINDOW:
            return SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW;
        case SUPLA_BIT_FUNC_POWERSWITCH:
            return SUPLA_CHANNELFNC_POWERSWITCH;
        case SUPLA_BIT_FUNC_LIGHTSWITCH:
            return SUPLA_CHANNELFNC_LIGHTSWITCH;
        case SUPLA_BIT_FUNC_STAIRCASETIMER:
            return SUPLA_CHANNELFNC_STAIRCASETIMER;
        case SUPLA_BIT_FUNC_THERMOMETER:
            return SUPLA_CHANNELFNC_THERMOMETER;
        case SUPLA_BIT_FUNC_HUMIDITYANDTEMPERATURE:
            return SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE;
        case SUPLA_BIT_FUNC_HUMIDITY:
            return SUPLA_CHANNELFNC_HUMIDITY;
        case SUPLA_BIT_FUNC_WINDSENSOR:
            return SUPLA_CHANNELFNC_WINDSENSOR;
        case SUPLA_BIT_FUNC_PRESSURESENSOR:
            return SUPLA_CHANNELFNC_PRESSURESENSOR;
        case SUPLA_BIT_FUNC_RAINSENSOR:
            return SUPLA_CHANNELFNC_RAINSENSOR;
        case SUPLA_BIT_FUNC_WEIGHTSENSOR:
            return SUPLA_CHANNELFNC_WEIGHTSENSOR;
    }

    return 0;
}

+ (NSString *)getNonEmptyCaptionOfChannel:(SAChannelBase*)channel customFunc:(NSNumber*)func {
    
    if ( channel.caption == nil || [channel.caption isEqualToString:@""] ) {
        int _func = func ? [func intValue] : channel.func;
        switch(_func) {
                case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
                    return NSLocalizedString(@"Gateway opening sensor", nil);
                case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
                    return NSLocalizedString(@"Gateway", nil);
                case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
                    return NSLocalizedString(@"Gate opening sensor", nil);
                case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
                    return NSLocalizedString(@"Gate", nil);
                case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
                    return NSLocalizedString(@"Garage door opening sensor", nil);
                case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
                    return NSLocalizedString(@"Garage door", nil);
                case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
                    return NSLocalizedString(@"Door opening sensor", nil);
                case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
                    return NSLocalizedString(@"Door", nil);
                case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
                    return NSLocalizedString(@"Roller shutter opening sensor", nil);
            case SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW:
                return NSLocalizedString(@"Roof window opening sensor", nil);
                case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
                    return NSLocalizedString(@"Roller shutter", nil);
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
                return NSLocalizedString(@"Roof window", nil);
                case SUPLA_CHANNELFNC_POWERSWITCH:
                    return NSLocalizedString(@"Power switch", nil);
                case SUPLA_CHANNELFNC_LIGHTSWITCH:
                    return NSLocalizedString(@"Lighting switch", nil);
                case SUPLA_CHANNELFNC_STAIRCASETIMER:
                    return NSLocalizedString(@"Staircase timer", nil);
                case SUPLA_CHANNELFNC_THERMOMETER:
                    return NSLocalizedString(@"Thermometer", nil);
                case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
                    return NSLocalizedString(@"Temperature and humidity", nil);
                case SUPLA_CHANNELFNC_HUMIDITY:
                    return NSLocalizedString(@"Humidity", nil);
                case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
                    return NSLocalizedString(@"No liquid sensor", nil);
                case SUPLA_CHANNELFNC_RGBLIGHTING:
                    return NSLocalizedString(@"RGB Lighting", nil);
                case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                    return NSLocalizedString(@"Dimmer and RGB lighting", nil);
                case SUPLA_CHANNELFNC_DIMMER:
                    return NSLocalizedString(@"Dimmer", nil);
                case SUPLA_CHANNELFNC_DISTANCESENSOR:
                    return NSLocalizedString(@"Distance sensor", nil);
                case SUPLA_CHANNELFNC_DEPTHSENSOR:
                    return NSLocalizedString(@"Depth sensor", nil);
                case SUPLA_CHANNELFNC_WINDSENSOR:
                    return NSLocalizedString(@"Wind sensor", nil);
                case SUPLA_CHANNELFNC_WEIGHTSENSOR:
                    return NSLocalizedString(@"Weight sensor", nil);
                case SUPLA_CHANNELFNC_PRESSURESENSOR:
                    return NSLocalizedString(@"Pressure sensor", nil);
                case SUPLA_CHANNELFNC_RAINSENSOR:
                    return NSLocalizedString(@"Rain sensor", nil);
                case SUPLA_CHANNELFNC_MAILSENSOR:
                    return NSLocalizedString(@"Mail sensor", nil);
                case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW:
                    return NSLocalizedString(@"Window opening sensor", nil);
                case SUPLA_CHANNELFNC_ELECTRICITY_METER:
                case SUPLA_CHANNELFNC_IC_ELECTRICITY_METER:
                    return NSLocalizedString(@"Electricity Meter", nil);
                case SUPLA_CHANNELFNC_IC_GAS_METER:
                    return NSLocalizedString(@"Gas Meter", nil);
                case SUPLA_CHANNELFNC_IC_WATER_METER:
                    return NSLocalizedString(@"Water Meter", nil);
                case SUPLA_CHANNELFNC_IC_HEAT_METER:
                    return NSLocalizedString(@"Heat Meter", nil);
                case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
                    return NSLocalizedString(@"Home+ Heater", nil);
                case SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
                case SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
                    return NSLocalizedString(@"Valve", nil);
                case SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
                case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
                    return NSLocalizedString(@"Digiglass", nil);
        }
        
    }
    
    return channel.caption;
}

+ (NSString *)getFunctionName:(int)func {
    switch (func) {
        case SUPLA_CHANNELFNC_NONE:
            return NSLocalizedString(@"No function", nil);
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            return NSLocalizedString(@"Gateway lock operation", nil);
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            return NSLocalizedString(@"Gate operation", nil);
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            return NSLocalizedString(@"Garage door operation", nil);
        case SUPLA_CHANNELFNC_THERMOMETER:
            return NSLocalizedString(@"Thermometer", nil);
        case SUPLA_CHANNELFNC_HUMIDITY:
            return NSLocalizedString(@"Humidity sensor", nil);
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return NSLocalizedString(@"Temperature and humidity sensor", nil);
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
            return NSLocalizedString(@"Gateway opening sensor", nil);
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
            return NSLocalizedString(@"Gate opening sensor", nil);
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
            return NSLocalizedString(@"Garage door opening sensor", nil);
        case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
            return NSLocalizedString(@"No liquid sensor", nil);
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            return NSLocalizedString(@"Door lock operation", nil);
        case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
            return NSLocalizedString(@"Door opening sensor", nil);
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            return NSLocalizedString(@"Roller shutter operation", nil);
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
            return NSLocalizedString(@"Roof window operation", nil);
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
            return NSLocalizedString(@"Roller shutter opening sensor", nil);
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW:
            return NSLocalizedString(@"Roof window opening sensor", nil);
        case SUPLA_CHANNELFNC_POWERSWITCH:
            return NSLocalizedString(@"On/Off switch", nil);
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
            return NSLocalizedString(@"Light switch", nil);
        case SUPLA_CHANNELFNC_DIMMER:
            return NSLocalizedString(@"Dimmer", nil);
        case SUPLA_CHANNELFNC_RGBLIGHTING:
            return NSLocalizedString(@"RGB lighting", nil);
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return NSLocalizedString(@"Dimmer and RGB lighting", nil);
        case SUPLA_CHANNELFNC_DEPTHSENSOR:
            return NSLocalizedString(@"Depth sensor", nil);
        case SUPLA_CHANNELFNC_DISTANCESENSOR:
            return NSLocalizedString(@"Distance sensor", nil);
        case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW:
            return NSLocalizedString(@"Window opening sensor", nil);
        case SUPLA_CHANNELFNC_MAILSENSOR:
            return NSLocalizedString(@"Mail sensor", nil);
        case SUPLA_CHANNELFNC_WINDSENSOR:
            return NSLocalizedString(@"Wind sensor", nil);
        case SUPLA_CHANNELFNC_PRESSURESENSOR:
            return NSLocalizedString(@"Pressure sensor", nil);
        case SUPLA_CHANNELFNC_RAINSENSOR:
            return NSLocalizedString(@"Rain sensor", nil);
        case SUPLA_CHANNELFNC_WEIGHTSENSOR:
            return NSLocalizedString(@"Weight sensor", nil);
        case SUPLA_CHANNELFNC_WEATHER_STATION:
            return NSLocalizedString(@"Weather Station", nil);
        case SUPLA_CHANNELFNC_STAIRCASETIMER:
            return NSLocalizedString(@"Staircase timer", nil);
        case SUPLA_CHANNELFNC_ELECTRICITY_METER:
        case SUPLA_CHANNELFNC_IC_ELECTRICITY_METER:
            return NSLocalizedString(@"Electricity meter", nil);
        case SUPLA_CHANNELFNC_IC_GAS_METER:
            return NSLocalizedString(@"Gas meter", nil);
        case SUPLA_CHANNELFNC_IC_WATER_METER:
            return NSLocalizedString(@"Water meter", nil);
        case SUPLA_CHANNELFNC_IC_HEAT_METER:
            return NSLocalizedString(@"Heat meter", nil);
        case SUPLA_CHANNELFNC_THERMOSTAT:
            return NSLocalizedString(@"Thermostat", nil);
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
            return NSLocalizedString(@"Home+ Heater", nil);
        case SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
        case SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
            return NSLocalizedString(@"Valve", nil);
        case SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
        case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
            return NSLocalizedString(@"Digiglass", nil);

    }

    return nil;
}

- (NSString *)getNonEmptyCaption {
    return [SAChannelBase getNonEmptyCaptionOfChannel:self customFunc:nil];
}

- (BOOL) isOnline {
    return NO;
}

- (int) onlinePercent {
    return 0;
}

- (int) hiValue {
    return 0;
}

- (BOOL) isClosed {
    return FALSE;
}

- (int) hiSubValue {
    return 0;
}

- (double) temperatureValue {
    return -273;
}

- (double) humidityValue {
    return -1;
}

- (double) doubleValue {
    return 0;
}

- (TDSC_RollerShutterValue) rollerShutterValue {
    TDSC_RollerShutterValue result = {};
    result.position = -1;
    return result;
}

- (int) brightnessValue {
    return 0;
}

- (int) colorBrightnessValue {
    return 0;
}

- (UIColor *) colorValue {
    return [UIColor clearColor];
}

- (double) totalForwardActiveEnergy {
    return 0;
}

- (double) impulseCounterCalculatedValue {
    return 0;
}

- (BOOL) isManuallyClosed {
    return false;
}

- (BOOL) flooding {
    return false;
}

- (SADigiglassValue *) digiglassValue {
    return [[SADigiglassValue alloc] init];
}

- (BOOL) overcurrentRelayOff {
    return false;
}

- (BOOL) calibrationFailed{
    return false;
}

- (BOOL) calibrationLost{
    return false;
}

- (BOOL) motorProblem{
    return false;
}

- (int) imgIsActive {
    
    if ( [self isOnline] ) {
        switch(self.func) {
            
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
                return [self hiSubValue];
                
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW:
            case SUPLA_CHANNELFNC_MAILSENSOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW:
            case SUPLA_CHANNELFNC_POWERSWITCH:
            case SUPLA_CHANNELFNC_LIGHTSWITCH:
            case SUPLA_CHANNELFNC_STAIRCASETIMER:
            case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
            case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
                return [self hiValue];

            case SUPLA_CHANNELFNC_DIMMER:
                return self.brightnessValue > 0 ? 1 : 0;
                
            case SUPLA_CHANNELFNC_RGBLIGHTING:
                return self.colorBrightnessValue > 0 ? 1 : 0;
                
            case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING: {
                int result = 0;
                if (self.brightnessValue > 0) {
                    result = 0x1;
                }
                if (self.colorBrightnessValue > 0) {
                    result |= 0x2;
                }
                return result;
            }
            case SUPLA_CHANNELFNC_VALVE_OPENCLOSE: {
                return self.isClosed ? 1 : 0;
            }
            case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
            case SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
                return [self.digiglassValue isAnySectionTransparent] ? 1 : 0;
        }
    }
    
    return 0;
}

- (UIImage*) getIconWithIndex:(short)idx {
    
    if (idx > 0
        && self.func != SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
        return nil;
    }
    
    if (self.usericon != nil) {
        NSObject *data = nil;
        
        switch(self.func) {
            case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            data = idx == 0 ? self.usericon.uimage2 : self.usericon.uimage1;
            break;
            case SUPLA_CHANNELFNC_THERMOMETER:
            data = self.usericon.uimage1;
            break;
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
                if (([self imgIsActive] & 0x1) > 0) {
                    data = self.usericon.uimage2;
                } else if (([self imgIsActive] & 0x2) > 0) {
                    data = self.usericon.uimage3;
                } else {
                    data = self.usericon.uimage1;
                }
            break;
            case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                if (([self imgIsActive] & 0x1) == 0x1
                    && ([self imgIsActive] & 0x2) == 0x2) {
                    data = self.usericon.uimage4;
                } else if (([self imgIsActive] & 0x1) == 0x1) {
                    data = self.usericon.uimage2;
                } else if (([self imgIsActive] & 0x2) == 0x2) {
                    data = self.usericon.uimage3;
                } else {
                    data = self.usericon.uimage1;
                }
                break;
            default:
                data = [self imgIsActive]
                ? self.usericon.uimage2 : self.usericon.uimage1;
            break;
        }
        
        UIImage *img = nil;
        @try {
            if (data != nil && [data isKindOfClass:[NSData class]]) {
                img = [UIImage imageWithData:(NSData*)data];
            }
        } @catch (NSException *exception) {
          img = nil;
        }
        
        if (img != nil) {
            return img;
        }
    }
    
    NSString *n1 = nil;
    NSString *n2 = nil;
    NSString *t1 = nil;
    
    BOOL _50percent = ([self imgIsActive] & 0x2) == 0x2 && ([self imgIsActive] & 0x1) == 0;
    
    switch(self.func) {
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            n1 = @"gateway";
            break;
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE: {
            if (_50percent && self.alticon != 2) {
                return [UIImage imageNamed:self.alticon == 1 ? @"gatealt1-closed-50percent" : @"gate-closed-50percent"];
            }
        }
            // !no break;
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
            switch(self.alticon) {
                case 1:
                    n1 = @"gatealt1";
                    break;
                case 2:
                    n1 = @"barier";
                    break;
                default:
                    n1 = @"gate";
            }
            break;
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            if (_50percent) {
                return [UIImage imageNamed:@"garagedoor-closed-50percent"];
            }
            n1 = @"garagedoor";
            break;
        case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            n1 = @"door";
            break;
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            n1 = @"rollershutter";
            break;
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
            n1 = @"roofwindow";
            break;
        case SUPLA_CHANNELFNC_POWERSWITCH:
            switch(self.alticon) {
                case 1:
                    n2 = @"tv";
                    break;
                case 2:
                    n2 = @"radio";
                    break;
                case 3:
                    n2 = @"pc";
                    break;
                case 4:
                    n2 = @"fan";
                    break;
                default:
                    n2 = @"power";
            }
            break;
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
            switch(self.alticon) {
                case 1:
                    n2 = @"xmastree";
                    break;
                case 2:
                    n2 = @"uv";
                    break;
                default:
                    n2 = @"light";
            }
            break;
        case SUPLA_CHANNELFNC_STAIRCASETIMER:
            switch(self.alticon) {
                case 1:
                    n2 = @"staircasetimer_1";
                    break;
                default:
                    n2 = @"staircasetimer";
            }
            break;
        case SUPLA_CHANNELFNC_THERMOMETER:
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return [UIImage imageNamed:idx == 0 ? @"thermometer" : @"humidity"];
        case SUPLA_CHANNELFNC_HUMIDITY:
            return [UIImage imageNamed:@"humidity"];
        case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
            return [UIImage imageNamed:[self imgIsActive] ? @"liquid" : @"noliquid"];
        case SUPLA_CHANNELFNC_DIMMER:
            n2 = @"dimmer";
            break;
            
        case SUPLA_CHANNELFNC_RGBLIGHTING:
            n2 = @"rgb";
            break;
            
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return [UIImage imageNamed:[NSString stringWithFormat:@"dimmerrgb-%@%@", [self imgIsActive] & 0x1 ? @"on" : @"off", [self imgIsActive] & 0x2 ? @"on" : @"off"]];
            
        case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW:
            n1 = @"window";
            break;
            
        case SUPLA_CHANNELFNC_MAILSENSOR:
            return [UIImage imageNamed:[self imgIsActive] ? @"mail" : @"nomail"];
            
        case SUPLA_CHANNELFNC_ELECTRICITY_METER:
        case SUPLA_CHANNELFNC_IC_ELECTRICITY_METER:
            switch(self.alticon) {
                case 1:
                    return [UIImage imageNamed:@"powerstation"];
            }
            return [UIImage imageNamed:@"electricitymeter"];
            
        case SUPLA_CHANNELFNC_IC_GAS_METER:
            return [UIImage imageNamed:@"gasmeter"];
            
        case SUPLA_CHANNELFNC_IC_WATER_METER:
            return [UIImage imageNamed:@"watermeter"];
        
        case SUPLA_CHANNELFNC_IC_HEAT_METER:
            return [UIImage imageNamed:@"heatmeter"];
            
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
            n2 = @"thermostat_hp_homeplus";
            if (self.alticon > 0 && self.alticon <= 3) {
                n2 = [NSString stringWithFormat:@"%@%i", n2, self.alticon];
            }
            break;
        case SUPLA_CHANNELFNC_DISTANCESENSOR:
           return [UIImage imageNamed:@"distance"];
        case SUPLA_CHANNELFNC_DEPTHSENSOR:
           return [UIImage imageNamed:@"depth"];
        case SUPLA_CHANNELFNC_WINDSENSOR:
           return [UIImage imageNamed:@"wind"];
        case SUPLA_CHANNELFNC_PRESSURESENSOR:
            return [UIImage imageNamed:@"pressure"];
        case SUPLA_CHANNELFNC_WEIGHTSENSOR:
            return [UIImage imageNamed:@"weight"];
        case SUPLA_CHANNELFNC_RAINSENSOR:
            return [UIImage imageNamed:@"rain"];
        case SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
        case SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
            n1 = @"valve";
            break;
        case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
            switch(self.alticon) {
                case 1:
                    t1 = @"digiglass1";
                    break;
                default:
                    t1 = @"digiglass";
            }
            break;
        case SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
            switch(self.alticon) {
                case 1:
                    t1 = [self imgIsActive] ? @"digiglassv1" : @"digiglass1";
                    break;
                default:
                    t1 = [self imgIsActive] ? @"digiglassv" : @"digiglass";
            }
            break;
            
    }
    
    if ( n1 ) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", n1, [self imgIsActive] ? @"closed" : @"open"]];
    }
    
    if ( n2 ) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", n2, [self imgIsActive] ? @"on" : @"off"]];
    }
    
    if ( t1 ) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", t1, [self imgIsActive] ? @"-transparent" : @""]];
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"unknown_channel"]];
}

- (UIImage*) getIcon {
    return [self getIconWithIndex:0];
}

- (NSString *) unit {
    return @"";
}

- (double) presetTemperature {
    return -273;
}

- (double) presetTemperatureMin {
    return -273;
}

- (double) presetTemperatureMax {
    return -273;
}

- (double) measuredTemperature {
   return -273;
}

- (double) measuredTemperatureMin {
   return -273;
}

- (double) measuredTemperatureMax {
   return -273;
}

- (NSAttributedString*) thermostatAttrStringWithMeasuredTempMin:(double)mmin measuredTempMax:(double)mmax presetTempMin:(double)pmin presetTempMax:(double)pmax font:(nullable UIFont*)font {
	TemperaturePresenter *pres = [self temperaturePresenter];
	NSString *unit = pres.unitString;
    NSString *measured = [@"---" stringByAppendingString: unit];
    NSString *preset = [@"/---" stringByAppendingString: unit];
        
    if (self.isOnline) {
        if (mmin > -273) {
            measured = [pres stringRepresentation: mmin];
            if (mmax > -273) {
               measured = [NSString stringWithFormat:@"%@ - %@", measured,
									[pres stringRepresentation: mmax]];
            }
        }
        
        if (pmin > -273) {
            preset = [pres stringRepresentation: pmin];
            if (pmax > -273) {
               preset = [NSString stringWithFormat:@"%@ - %@", preset,
								  [pres stringRepresentation: pmax]];
            }
        }
        
        preset = [@"/" stringByAppendingString: preset];
    }
    
    NSMutableAttributedString *attrTxt = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", measured, preset]];
    
    if (font) {
        [attrTxt addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:font.pointSize * 0.7]
                        range:NSMakeRange(measured.length, preset.length)];
    }

    return attrTxt;
}


- (NSAttributedString*) attrStringValueWithIndex:(int)idx font:(nullable UIFont*)font {
    NSString *result = @"";
    TemperaturePresenter *pres = [self temperaturePresenter];
    NSNumberFormatter *nfmt = [[NSNumberFormatter alloc] init],
        *n2fmt = [[NSNumberFormatter alloc] init];
    nfmt.minimumIntegerDigits = 1;
    nfmt.maximumFractionDigits = 1;
    nfmt.minimumFractionDigits = 1;
    n2fmt.minimumIntegerDigits = 1;
    n2fmt.maximumFractionDigits = 2;
    n2fmt.minimumFractionDigits = 1;
    switch (self.func) {
        case SUPLA_CHANNELFNC_THERMOMETER:
            result = [self isOnline] && self.temperatureValue > -273 ? [pres stringRepresentation: self.temperatureValue] : [@"----" stringByAppendingString: pres.unitString];
            break;
        case SUPLA_CHANNELFNC_HUMIDITY:
            result = [self isOnline] && self.humidityValue > -1 ? [nfmt stringFromNumber: @(self.humidityValue)] : @"----";
            break;
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            if (idx == 1) {
                result = [self isOnline] && self.humidityValue > -1 ? [nfmt stringFromNumber: @(self.humidityValue)] : @"----";
            } else {
                result = [self isOnline] && self.temperatureValue > -273 ? [pres stringRepresentation:  self.temperatureValue] : [@"----" stringByAppendingString: pres.unitString];
            }
            break;
        case SUPLA_CHANNELFNC_DEPTHSENSOR:
        case SUPLA_CHANNELFNC_DISTANCESENSOR:
            result = @"--- m";
            
            if ( [self isOnline] && self.doubleValue >= 0 ) {
                
                double value = [self doubleValue];
                
                if ( fabs(value) >= 1000 ) {
                    result = [NSString stringWithFormat:@"%@ km",
                              [n2fmt stringFromNumber: @(value/1000.00)]];
                } else if ( fabs(value) >= 1 ) {
                    result = [NSString stringWithFormat:@"%@ m",
                              [n2fmt stringFromNumber: @(value)]];
                } else {
                    value *= 100;
                    
                    if ( fabs(value) >= 1 ) {
                        result = [NSString stringWithFormat:@"%@ cm",
                                  [nfmt stringFromNumber: @(value)]];
                    } else {
                        value *= 10;
                        result = [NSString stringWithFormat:@"%i mm", (int)value];
                    }
                }

            }
            break;
        case SUPLA_CHANNELFNC_WINDSENSOR:
            if ([self isOnline] && [self doubleValue] >= 0) {
               result = [NSString stringWithFormat:@"%@ m/s",
                         [nfmt stringFromNumber: @([self doubleValue])]];
            } else {
               result = @"--- m/s";
            }
            break;
        case SUPLA_CHANNELFNC_PRESSURESENSOR:
            if ([self isOnline] && [self doubleValue] >= 0) {
               result = [NSString stringWithFormat:@"%i hPa", (int)[self doubleValue]];
            } else {
               result = @"--- hPa";
            }
            break;
        case SUPLA_CHANNELFNC_RAINSENSOR:
            if ([self isOnline] && [self doubleValue] >= 0) {
                result = [NSString stringWithFormat:@"%@ l/m²", [n2fmt stringFromNumber: @([self doubleValue]/1000.00)]];
            } else {
                result = @"--- l/m²";
            }
            break;
        case SUPLA_CHANNELFNC_WEIGHTSENSOR:
            if ([self isOnline] && [self doubleValue] >= 0) {
                double weight = [self doubleValue];
                if (fabs(weight) >= 2000) {
                    result = [NSString stringWithFormat:@"%@ kg", [n2fmt stringFromNumber:@(weight/1000.00)]];
                } else {
                    result = [NSString stringWithFormat:@"%i g", (int)weight];
                }
            } else {
                result = @"--- kg";
            }
            break;
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
            return [self thermostatAttrStringWithMeasuredTempMin:self.measuredTemperatureMin measuredTempMax:self.measuredTemperatureMax presetTempMin:self.presetTemperatureMin presetTempMax:self.presetTemperatureMax font:font];
        default:
            break;
    }
    
    return [[NSMutableAttributedString alloc] initWithString:result];
}

- (NSAttributedString*) attrStringValue {
    return [self attrStringValueWithIndex:0 font:nil];
}

- (TemperaturePresenter*)temperaturePresenter {
	return [Config new].currentTemperaturePresenter;
}
@end
