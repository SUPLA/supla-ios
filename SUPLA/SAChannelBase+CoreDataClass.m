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
#include "proto.h"

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

- (NSString *)getChannelCaption {
    
    if ( [self.caption isEqualToString:@""] ) {
        
        switch(self.func) {
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
                case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
                    return NSLocalizedString(@"Roller shutter", nil);
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
        }
        
    }
    
    return self.caption;
    
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

- (int) percentValue {
    return -1;
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

- (int) imgIsActive {
    
    if ( [self isOnline] ) {
        switch(self.func) {
            
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
                return [self hiSubValue];
                
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
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
    
    switch(self.func) {
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            n1 = @"gateway";
            break;
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE: {
            BOOL _50percent = ([self imgIsActive] & 0x2) == 0x2 && ([self imgIsActive] & 0x1) == 0;
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
    }
    
    if ( n1 ) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", n1, [self imgIsActive] ? @"closed" : @"open"]];
    }
    
    if ( n2 ) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", n2, [self imgIsActive] ? @"on" : @"off"]];
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
    NSString *measured = @"---\u00B0";
    NSString *preset = @"/---\u00B0";
        
    if (self.isOnline) {
        if (mmin > -273) {
            measured = [NSString stringWithFormat:@"%0.2f\u00B0", mmin];
            if (mmax > -273) {
               measured = [NSString stringWithFormat:@"%@ - %0.2f\u00B0", measured, mmax];
            }
        }
        
        if (pmin > -273) {
            preset = [NSString stringWithFormat:@"/%0.2f\u00B0", pmin];
            if (pmax > -273) {
               preset = [NSString stringWithFormat:@"%@ - %0.2f\u00B0", preset, pmax];
            }
        }
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
    
    switch (self.func) {
        case SUPLA_CHANNELFNC_THERMOMETER:
            result = [self isOnline] && self.temperatureValue > -273 ? [NSString stringWithFormat:@"%0.1f°", self.temperatureValue] : @"----°";
            break;
        case SUPLA_CHANNELFNC_HUMIDITY:
            result = [self isOnline] && self.humidityValue > -1 ? [NSString stringWithFormat:@"%0.1f", self.humidityValue] : @"----";
            break;
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            if (idx == 1) {
                result = [self isOnline] && self.humidityValue > -1 ? [NSString stringWithFormat:@"%0.1f", self.humidityValue] : @"----";
            } else {
                result = [self isOnline] && self.temperatureValue > -273 ? [NSString stringWithFormat:@"%0.1f°", self.temperatureValue] : @"----°";
            }
            break;
        case SUPLA_CHANNELFNC_DEPTHSENSOR:
        case SUPLA_CHANNELFNC_DISTANCESENSOR:
            result = @"--- m";
            
            if ( [self isOnline] && self.doubleValue >= 0 ) {
                
                double value = [self doubleValue];
                
                if ( fabs(value) >= 1000 ) {
                    result = [NSString stringWithFormat:@"%0.2f km", value/1000.00];
                } else if ( fabs(value) >= 1 ) {
                    result = [NSString stringWithFormat:@"%0.2f m", value];
                } else {
                    value *= 100;
                    
                    if ( fabs(value) >= 1 ) {
                        result = [NSString stringWithFormat:@"%0.1f cm", value];
                    } else {
                        value *= 10;
                        result = [NSString stringWithFormat:@"%i mm", (int)value];
                    }
                }

            }
            break;
        case SUPLA_CHANNELFNC_WINDSENSOR:
            if ([self isOnline] && [self doubleValue] >= 0) {
               result = [NSString stringWithFormat:@"%0.1f m/s", [self doubleValue]];
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
                result = [NSString stringWithFormat:@"%0.2f l/m²", [self doubleValue]/1000.00];
            } else {
                result = @"--- l/m²";
            }
            break;
        case SUPLA_CHANNELFNC_WEIGHTSENSOR:
            if ([self isOnline] && [self doubleValue] >= 0) {
                double weight = [self doubleValue];
                if (fabs(weight) >= 2000) {
                    result = [NSString stringWithFormat:@"%0.2f kg", weight/1000.00];
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
@end
