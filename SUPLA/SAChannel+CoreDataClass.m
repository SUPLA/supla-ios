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

#import "SAChannel+CoreDataClass.h"
#import "_SALocation+CoreDataClass.h"
#import "SAImpulseCounterExtendedValue.h"
#import "Database.h"
#import "SUPLA-Swift.h"

@implementation SAChannel

- (void) initWithRemoteId:(int)remoteId {
    self.caption = @"";
    self.remote_id = remoteId;
    self.func = 0;
    self.visible = 1;
    self.alticon = 0;
    self.protocolversion = 0;
    self.flags = 0;
    self.value = nil;
    self.device_id = 0;
    self.manufacturer_id = 0;
    self.product_id = 0;
    self.type = 0;
    self.ev = nil;
}

- (BOOL) setChannelProtocolVersion:(int)protocolVersion {
    
    if ( self.protocolversion != protocolVersion ) {
        self.protocolversion = protocolVersion;
        return YES;
    }
    
    return NO;
}

- (BOOL) setDeviceId:(int)deviceId {
    if ( self.device_id != deviceId ) {
        self.device_id = deviceId;
        return YES;
    }
    return NO;
}

- (BOOL) setManufacturerId:(int)manufacturerId {
    if ( self.manufacturer_id != manufacturerId ) {
        self.manufacturer_id = manufacturerId;
        return YES;
    }
    return NO;
}

- (BOOL) setProductId:(int)productId {
    if ( self.product_id != productId ) {
        self.product_id = productId;
        return YES;
    }
    return NO;
}

- (BOOL) setChannelType:(int)type {
    if ( self.type != type ) {
        self.type = type;
        return YES;
    }
    return NO;
}

- (SharedCoreSuplaChannelAvailabilityStatus *) status {
    return self.value == nil ? SharedCoreSuplaChannelAvailabilityStatus.offline : self.value.status;
}

- (int) onlinePercent {
    return [self status].online ? 100 : 0;
}

- (int) hiValue {
    return self.value == nil ? [super hiValue] : [self.value hiValue];
}

- (BOOL) isClosed {
    return self.value == nil ? [super isClosed] : [self.value isClosed];
}

- (int) hiSubValue {
    return self.value == nil ? [super hiSubValue] : [self.value hiSubValue];
}

- (double) temperatureValue {
    return self.value == nil ? [super temperatureValue] : [self.value getTemperatureForFunction:self.func];
}

- (double) humidityValue {
    return self.value == nil ? [super humidityValue] : [self.value humidityValue];
}

- (double) doubleValue {
    return self.value == nil ? [super doubleValue] : [self.value doubleValue];
}

- (double) totalForwardActiveEnergy {
    return self.value == nil ? [super totalForwardActiveEnergy] : [self.value totalForwardActiveEnergy];
}

- (double) totalForwardActiveEnergyFromSubValue {
    return self.value == nil ? 0.0 : [self.value totalForwardActiveEnergyFromSubValue];
}

- (double) impulseCounterCalculatedValue {
    return self.value == nil ? [super impulseCounterCalculatedValue] : [self.value impulseCounterCalculatedValue];
}

- (double) impulseCounterCalculatedValueFromSubValue {
    return self.value == nil ? 0.0 : [self.value impulseCounterCalculatedValueFromSubValue];
}

- (int) percentValue {
     return self.value == nil ? [super percentValue] : [self.value percentValue];
}

- (int) brightnessValue {
    return self.value == nil ? [super brightnessValue] : [self.value brightnessValue];
}

- (int) colorBrightnessValue {
    return self.value == nil ? [super colorBrightnessValue] : [self.value colorBrightnessValue];
}

- (UIColor *) colorValue {
    return self.value == nil ? [super colorValue] : [self.value colorValue];
}

- (BOOL) isManuallyClosed {
    return self.value == nil ? [super isManuallyClosed] : [self.value isManuallyClosed];
}

- (BOOL) flooding{
    return self.value == nil ? [super flooding] : [self.value flooding];
}

- (SADigiglassValue *) digiglassValue {
    return self.value == nil ? [super digiglassValue] : [self.value digiglassValue];
}

- (BOOL) overcurrentRelayOff{
    return self.value == nil ? [super overcurrentRelayOff] : [self.value overcurrentRelayOff];
}

- (TDSC_RollerShutterValue) rollerShutterValue {
    return self.value == nil ? [super rollerShutterValue] : [self.value rollerShutterValue];
}

- (BOOL) calibrationFailed{
    return self.value == nil ? [super calibrationFailed] : [self.value calibrationFailed];
}

- (BOOL) calibrationLost{
    return self.value == nil ? [super calibrationLost] : [self.value calibrationLost];
}

- (BOOL) motorProblem{
    return self.value == nil ? [super motorProblem] : [self.value motorProblem];
}

- (NSString *) unit {
    
    NSString *result = nil;
    SAImpulseCounterExtendedValue *icev = nil;
    if ( self.ev != nil
         && (icev = self.ev.impulseCounter) != nil) {
        result = icev.unit;
        if (result != nil) {
            return result;
        }
    }
    
    if ( self.func == SUPLA_CHANNELFNC_ELECTRICITY_METER
         || self.func == SUPLA_CHANNELFNC_IC_ELECTRICITY_METER) {
        return @"kWh";
    }
    
    return super.unit;
}

- (double) presetTemperature {
    return self.value == nil
    || self.func != SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
    ? [super presetTemperature] : [self.value presetTemperature];
}

- (double) presetTemperatureMin {
   return self.presetTemperature;
}

- (double) measuredTemperature {
    return self.value == nil
    || self.func != SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
    ? [super measuredTemperature] : [self.value measuredTemperature];
}

- (double) measuredTemperatureMin {
   return self.measuredTemperature;
}

- (NSAttributedString*) attrStringValueWithIndex:(int)idx font:(nullable UIFont*)font {
    NSNumberFormatter *n2fmt = [[NSNumberFormatter alloc] init];
    n2fmt.maximumFractionDigits = 2;
    n2fmt.minimumIntegerDigits = 1;
    n2fmt.minimumFractionDigits = 2;

    if (self.value) {
        if (self.value.sub_value_type == SUBV_TYPE_IC_MEASUREMENTS) {
            double value = self.impulseCounterCalculatedValueFromSubValue;
            if (value == 0.0) {
                return [[NSMutableAttributedString alloc] initWithString:
                        [NSString stringWithFormat:@"--- %@", self.unit]];
            } else {
                return [[NSMutableAttributedString alloc] initWithString:
                        [NSString stringWithFormat:@"%@ %@", [n2fmt stringFromNumber: @(value)], self.unit]];
            }
        } else if (self.value.sub_value_type == SUBV_TYPE_ELECTRICITY_MEASUREMENTS) {
            double value = self.totalForwardActiveEnergyFromSubValue;
            if (value == 0.0) {
                return [[NSMutableAttributedString alloc] initWithString: @"--- kWh"];
            } else {
                return [[NSMutableAttributedString alloc] initWithString:
                        [NSString stringWithFormat:@"%@ kWh", [n2fmt stringFromNumber:@(value)]]];
            }
        }
    }
    
   if ( self.func == SUPLA_CHANNELFNC_ELECTRICITY_METER
        || self.func == SUPLA_CHANNELFNC_IC_ELECTRICITY_METER
        || self.func == SUPLA_CHANNELFNC_IC_WATER_METER
        || self.func == SUPLA_CHANNELFNC_IC_GAS_METER
        || self.func == SUPLA_CHANNELFNC_IC_HEAT_METER) {
        
        double value = 0.0;
        if ( self.type == SUPLA_CHANNELTYPE_ELECTRICITY_METER ) {
            value = self.totalForwardActiveEnergy;
        } else {
            value = self.impulseCounterCalculatedValue;
        }
        
        if (value == 0.0) {
            return [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"--- %@", self.unit]];
        } else {
            return [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [n2fmt stringFromNumber:@(value)], self.unit]];
        }
    }
    
    return [super attrStringValueWithIndex:idx font:font];
}

- (SAChannelStateExtendedValue *)channelState {
    return self.ev != nil ? self.ev.channelState : nil;
}

- (UIImage *) stateIcon {
    if (self.status.online
        || (self.type == SUPLA_CHANNELTYPE_BRIDGE
            && self.flags & SUPLA_CHANNEL_FLAG_CHANNELSTATE
            && self.flags & SUPLA_CHANNEL_FLAG_OFFLINE_DURING_REGISTRATION)) {
        
        SAChannelStateExtendedValue *channelState = self.ev != nil ? self.ev.channelState : nil;
        
        if (self.flags & SUPLA_CHANNEL_FLAG_CHANNELSTATE
            || channelState != nil) {
                
            if (channelState && channelState.state.defaultIconField != 0) {
                switch (channelState.state.defaultIconField) {
                    case SUPLA_CHANNELSTATE_FIELD_BATTERYPOWERED:
                        if (channelState.state.BatteryPowered) {
                            return [UIImage imageNamed:@"battery"];
                        }
                        break;
                }
            }
            
            return [UIImage iconInfo];
        }
        
    }
    
    return nil;
}

@end
