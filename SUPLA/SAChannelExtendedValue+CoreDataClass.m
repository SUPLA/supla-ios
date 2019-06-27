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

#import "SAChannelExtendedValue+CoreDataClass.h"
#import "proto.h"

@implementation SAChannelExtendedValue

- (void) initWithChannelId:(int)channelId {
    [super initWithChannelId:channelId];
    self.type = 0;
}

- (BOOL) setValueWithChannelExtendedValue:(TSuplaChannelExtendedValue*)value {
    
    BOOL result = NO;
    int size = sizeof(value->value);
    
    if (value->size < size) {
        size = value->size;
    }
    
    if (size > 0) {
        self.type = value->type;
        NSData *v =  [NSData dataWithBytes:value->value length:size];
        
        if ( self.type != value->type
            || self.value == nil
            || ![self.value isKindOfClass: NSData.class]
            || ![v isEqualToData:(NSData *)self.value] ) {
            self.value = v;
            self.type = value->type;
            result = YES;
        }
    } else {
        if (self.type != 0) {
           self.type = 0;
           result = YES;
        }
    }
    
    return result;
}

- (int) valueType {
    return self.type;
}

- (BOOL) getElectricityMeterExtendedValue:(TElectricityMeter_ExtendedValue*)emev {
    if (emev != NULL) {
        memset(emev, 0, sizeof(TElectricityMeter_ExtendedValue));
        NSData *data = [super dataValue];
        if (data && data.length == sizeof(TElectricityMeter_ExtendedValue)) {
            [data getBytes:emev length:data.length];
            return YES;
        }
    }
    return NO;
}

- (double) getTotalForwardActiveEnergyForExtendedValue:(TElectricityMeter_ExtendedValue*)emev {
    double totalForwardActiveEnergy = 0;
    for(short a=0;a<3;a++) {
        totalForwardActiveEnergy+=emev->total_forward_active_energy[a]*0.00001;
    }
    
    return totalForwardActiveEnergy;
}

- (double) getTotalForwardActiveEnergy {
     TElectricityMeter_ExtendedValue emev;
    if ([self getElectricityMeterExtendedValue:&emev]) {
        return [self getElectricityMeterExtendedValue:&emev];
    }
    return 0.0;
}

- (BOOL) getImpulseCounterExtendedValue:(TSC_ImpulseCounter_ExtendedValue*)icev {
    if (icev != NULL) {
        memset(icev, 0, sizeof(TSC_ImpulseCounter_ExtendedValue));
        NSData *data = [super dataValue];
        if (data && data.length == sizeof(TSC_ImpulseCounter_ExtendedValue)) {
            [data getBytes:icev length:data.length];
            return YES;
        }
    }
    return NO;
}

- (NSString *) decodeCurrency:(char*)currency {
    short a;
    NSString *result = @"";
    for(a=0;a<3;a++) {
        if (currency[a] == 0) {
            break;
        }
        result = [NSString stringWithFormat:@"%@%c", result, currency[a]];
    }
    
    if (a==3) {
        return result;
    }
    
    return @"";
}

- (NSString *) currency {
    if (self.valueType == EV_TYPE_IMPULSE_COUNTER_DETAILS_V1) {
        TSC_ImpulseCounter_ExtendedValue icev;
        if ( [self getImpulseCounterExtendedValue:&icev] ) {
            return [self decodeCurrency:icev.currency];
        }
    } else if (self.valueType == EV_TYPE_ELECTRICITY_METER_MEASUREMENT_V1) {
        TElectricityMeter_ExtendedValue emev;
        if ([self getElectricityMeterExtendedValue:&emev]) {
            return [self decodeCurrency:emev.currency];
        }
    }
    
    return @"";
}

- (NSString *) unit {
    if (self.valueType == EV_TYPE_IMPULSE_COUNTER_DETAILS_V1) {
        TSC_ImpulseCounter_ExtendedValue icev;
        if ( [self getImpulseCounterExtendedValue:&icev] ) {
            icev.custom_unit[sizeof(icev.custom_unit)-1] = 0;
            NSString *unit = [NSString stringWithFormat:@"%s", icev.custom_unit];
            if (unit.length > 0) {
                return unit;
            }
        }
    }

    return nil;
}

@end
