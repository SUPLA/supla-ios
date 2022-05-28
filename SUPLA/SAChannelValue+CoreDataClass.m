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

#import "SAChannelValue+CoreDataClass.h"

@implementation SAChannelValue 

- (void) initWithChannelId:(int)channelId {
    [super initWithChannelId:channelId];
    self.sub_value = [[NSData alloc] init];
    
    TSuplaChannelValue_B v = {};
    [self setValueWithChannelValue:&v];
}

- (BOOL) setOnlineState:(char)online {
    
    if ( self.online != (online != 0) ) {
        self.online = (online != 0);
        return YES;
    }
    
    return NO;
}

- (NSData *) dataValue {
    NSData *result = [super dataValue];
    return result && result.length == SUPLA_CHANNELVALUE_SIZE ? result : nil;
}

- (NSData *) dataSubValue {
    return self.sub_value && ((NSData*)self.sub_value).length == SUPLA_CHANNELVALUE_SIZE ? (NSData*)self.sub_value : nil;
}

- (BOOL) setValueWithChannelValue:(TSuplaChannelValue_B*)value {
    
    BOOL result = NO;
    
    NSData *v =  [NSData dataWithBytes:value->value length:SUPLA_CHANNELVALUE_SIZE];
    NSData *sv = [NSData dataWithBytes:value->sub_value length:SUPLA_CHANNELVALUE_SIZE];
    
    if ( self.value == nil || ![v isEqualToData:[self dataValue]] ) {
        self.value = v;
        result = YES;
    }
    
    if ( self.sub_value == nil || ![sv isEqualToData:[self dataSubValue]] ) {
        self.sub_value = sv;
        result = YES;
    }
    
    if (self.sub_value_type != value->sub_value_type) {
        self.sub_value_type = value->sub_value_type;
        result = YES;
    }
    
    return result;    
}

- (BOOL) isOnline {
    return self.online;
}

- (int) hiValue {
    
    if ( self.value != nil ) {
        char c = 0;
        [self.dataValue getBytes:&c length:1];
        return c > 0 ? 1 : 0;
    }
    
    return 0;
}

- (BOOL) isClosed {
    return [self hiValue] > 0;
}

- (int) hiSubValue {
    
    if ( self.sub_value != nil ) {
        char c[2] = {0, 0};
        [self.dataSubValue getBytes:&c[0] length:2];
        return (c[0] > 0 ? 0x1 : 0) | (c[1] > 0 ? 0x2 : 0);
    }
    
    return 0;
}

- (double) doubleValue {
    
    double result = 0;
    
    if ( self.value != nil ) {
        [self.dataValue getBytes:&result length:sizeof(double)];
    }
    
    return result;
}

- (double) totalForwardActiveEnergy {

    if ( self.value != nil && self.dataValue.length >= sizeof(TElectricityMeter_Value)) {
        TElectricityMeter_Value ev = {};
        [self.dataValue getBytes:&ev length:sizeof(TElectricityMeter_Value)];
        return ev.total_forward_active_energy * 0.01;
    }
    
    return 0.0;
}

- (double) totalForwardActiveEnergyFromSubValue {

    if ( self.value != nil && self.dataSubValue.length >= sizeof(TElectricityMeter_Value)) {
        TElectricityMeter_Value ev = {};
        [self.dataSubValue getBytes:&ev length:sizeof(TElectricityMeter_Value)];
        return ev.total_forward_active_energy * 0.01;
    }
    
    return 0.0;
}

- (double) impulseCounterCalculatedValue {
    if ( self.value != nil && self.dataValue.length >= sizeof(TSC_ImpulseCounter_Value)) {
        TSC_ImpulseCounter_Value icv = {};
        [self.dataValue getBytes:&icv length:sizeof(TSC_ImpulseCounter_Value)];
        return icv.calculated_value * 0.001;
    }
    
    return 0.0;
}

- (double) impulseCounterCalculatedValueFromSubValue {
    if ( self.value != nil && self.dataSubValue.length >= sizeof(TSC_ImpulseCounter_Value)) {
        TSC_ImpulseCounter_Value icv = {};
        [self.dataSubValue getBytes:&icv length:sizeof(TSC_ImpulseCounter_Value)];
        return icv.calculated_value * 0.001;
    }
    
    return 0.0;
}

- (int) intValue {
    if ( self.value != nil ) {
        int i = 0;
        [self.dataValue getBytes:&i length:sizeof(int)];
        return i;
    }
    
    return 0;
}

- (double) getTemperatureForFunction:(int)func {
    
    double result = -273;
    
    switch(func) {
        case SUPLA_CHANNELFNC_THERMOMETER:
            return self.doubleValue;
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            if (self.value != nil) {
                result = self.intValue/1000.00;
            }
    }
    
    return result;
}

- (double) humidityValue {
    
    if (self.value != nil && self.dataValue.length >= sizeof(int)*2) {
        int i[2];
        [self.dataValue getBytes:&i[0] length:sizeof(int)*2];
        return i[1]/1000.00;
    }

    return -1;
}

- (int) getBrightness:(int)idx {
    
    if (self.value != nil && idx >= 0 && idx <= 1)  {
        char b[2] = {0,0};
        [self.dataValue getBytes:&b[0] length:2];
        if (b[idx]>=0 && b[idx] <=100) {
           return b[idx];
        }
    }
    return 0;
}

-(UIColor *)colorValue {
    
    if (self.value != nil) {
        char v[5];
        [self.dataValue getBytes:&v[0] length:5];
        
        if ( (unsigned char) v[4] == 255
            && (unsigned char) v[3] == 255
            && (unsigned char) v[2] == 255 ) {
           return [UIColor whiteColor];
        }
        
        return [UIColor colorWithRed:(unsigned char)v[4]/255.00 green:(unsigned char)v[3]/255.00 blue:(unsigned char)v[2]/255.00 alpha:1];
    }

    return [UIColor clearColor];
}

- (int) brightnessValue {
    
    return [self getBrightness:0];
}

- (int) colorBrightnessValue {
    return [self getBrightness:1];
    
}

- (int) percentValue {
    int p = self.intValue;
    return p < 0 || p > 100 ? -1 : p;
}

- (double) presetTemperature {
    if (self.value != nil) {
        TThermostat_Value v;
        [self.dataValue getBytes:&v length:sizeof(TThermostat_Value)];
        return v.PresetTemperature * 0.01;
    }
    
    return -273;
}

- (double) measuredTemperature {
    if (self.value != nil) {
        TThermostat_Value v;
        [self.dataValue getBytes:&v length:sizeof(TThermostat_Value)];
        return v.MeasuredTemperature * 0.01;
    }
    
    return -273;
}

-(char) secondByte {
    if ( self.value != nil ) {
        char v[2] = {0, 0};
        [self.dataValue getBytes:v length:sizeof(v)];
        return v[1];
    }
    
    return 0;
}
    
-(TDSC_RollerShutterValue) rollerShutterValue {
    TDSC_RollerShutterValue result = {};
    if (self.dataValue.length >= sizeof(TDSC_RollerShutterValue)) {
        [self.dataValue getBytes:&result length:sizeof(TDSC_RollerShutterValue)];
    }
    
    if (result.position < -1 || result.position > 100) {
        result.position = -1;
    }
    
    return result;
}

-(BOOL) isManuallyClosed {
    return ([self secondByte] & SUPLA_VALVE_FLAG_MANUALLY_CLOSED) > 0;
}

-(BOOL) flooding {
    return ([self secondByte] & SUPLA_VALVE_FLAG_FLOODING) > 0;
}

-(BOOL) overcurrentRelayOff {
    return ([self secondByte] & SUPLA_RELAY_FLAG_OVERCURRENT_RELAY_OFF) > 0;
}

-(BOOL) calibrationFailed {
    return (self.rollerShutterValue.flags & RS_VALUE_FLAG_CALIBRATION_FAILED) > 0;
}

-(BOOL) calibrationLost {
    return (self.rollerShutterValue.flags & RS_VALUE_FLAG_CALIBRATION_LOST) > 0;
}

-(BOOL) motorProblem {
    return (self.rollerShutterValue.flags & RS_VALUE_FLAG_MOTOR_PROBLEM) > 0;
}

-(SADigiglassValue *) digiglassValue {
    return [[SADigiglassValue alloc] initWithData:self.dataValue];
}

@end
