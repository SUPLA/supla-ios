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

#import "SAChannelGroup+CoreDataClass.h"
#import "SAChannelValue+CoreDataClass.h"
#import "UIColor+SUPLA.h"
#include "proto.h"

@implementation SAChannelGroup {

    int BufferOnLineCount;
    int16_t BufferOnLine;
    int BufferCounter;
    NSMutableArray *BufferTotalValue;
}

- (void) resetBuffer {
    BufferTotalValue = [[NSMutableArray alloc] init];
    BufferOnLine = 0;
    BufferOnLineCount = 0;
    BufferCounter = 0;
}

- (void) addValueToBuffer:(SAChannelValue*)value {
    if ( BufferTotalValue == nil ) {
        BufferTotalValue = [[NSMutableArray alloc] init];
    }
    
    switch(self.func) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
        case SUPLA_CHANNELFNC_POWERSWITCH:
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
        case SUPLA_CHANNELFNC_STAIRCASETIMER:
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
        case SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
        case SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
            break;
        default:
            return;
    }
    
    BufferCounter++;
    if ([value isOnline]) {
        BufferOnLineCount++;
    }
    
    BufferOnLine = BufferOnLineCount * 100 / BufferCounter;
    
    if (![value isOnline]) {
        return;
    }
    
    switch(self.func) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            [BufferTotalValue addObject:[NSNumber numberWithBool: value.hiSubValue & 0x1]];
            break;

        case SUPLA_CHANNELFNC_POWERSWITCH:
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
        case SUPLA_CHANNELFNC_STAIRCASETIMER:
        case SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
            [BufferTotalValue addObject:[NSNumber numberWithBool: value.hiValue]];
            break;
        case SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
            [BufferTotalValue addObject:[NSNumber numberWithInt: value.percentValue]];
            break;
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW: {
            NSArray *obj = [NSArray arrayWithObjects:[NSNumber numberWithInt: value.rollerShutterValue.position],
                            [NSNumber numberWithBool: value.hiSubValue & 0x1], nil];
            [BufferTotalValue addObject:obj];
        }
            break;
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING: {
            NSArray *obj = [NSArray arrayWithObjects:[UIColor transformToDictionary:value.colorValue],
                            [NSNumber numberWithInt: value.colorBrightnessValue],
                            [NSNumber numberWithInt: value.brightnessValue], nil];
            [BufferTotalValue addObject:obj];
        }
            break;
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS: {
            NSArray *obj = [NSArray arrayWithObjects:[NSNumber numberWithBool: value.hiValue],
                            [NSNumber numberWithDouble: value.measuredTemperature],
                            [NSNumber numberWithDouble: value.presetTemperature], nil];
            [BufferTotalValue addObject:obj];
        }
            break;
        default:
            return;
    }
}

- (BOOL) diffWithBuffer {
    if ( BufferTotalValue == nil ) {
        BufferTotalValue = [[NSMutableArray alloc] init];
    }
    
    return BufferOnLine != self.online
    || self.total_value == nil
    || ![BufferTotalValue isEqualToArray:(NSArray*)self.total_value];
}

- (void) assignBuffer {
    self.online = BufferOnLine;
    self.total_value = [NSArray arrayWithArray:BufferTotalValue];
    [self resetBuffer];
}

- (BOOL) isOnline {
    return self.online > 0;
}

- (int) onlinePercent {
    return self.online;
}

- (NSNumber *) getNumberFromObject:(NSObject*)obj atArrIndex:(int)idx {
    if ( [obj isKindOfClass:[NSArray class]]) {
        NSArray *arr = (NSArray*)obj;
        if (arr.count > idx
            && [[arr objectAtIndex:idx] isKindOfClass:[NSNumber class]]) {
            return (NSNumber*)[arr objectAtIndex:idx];
        }
    }
    return [NSNumber numberWithInt:0];
}

- (int) getIntFromObject:(NSObject*)obj atArrIndex:(int)idx {
    return [[self getNumberFromObject:obj atArrIndex:idx] intValue];
}

- (int) activePercentForIndex:(int)idx {
    if (self.total_value == nil || ![self.total_value isKindOfClass:[NSArray class]]) {
        return 0;
    }
    
    int count = 0, sum = 0;
    NSArray *v = (NSArray*)self.total_value;
    
    for(int a=0;a<v.count;a++) {
        switch(self.func) {
            case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            case SUPLA_CHANNELFNC_POWERSWITCH:
            case SUPLA_CHANNELFNC_LIGHTSWITCH:
            case SUPLA_CHANNELFNC_STAIRCASETIMER:
            case SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
                if ( [[v objectAtIndex:a] isKindOfClass:[NSNumber class]]
                    && [[v objectAtIndex:a] boolValue]) {
                    sum++;
                }
                count++;
                break;
            case SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
                if ( [[v objectAtIndex:a] isKindOfClass:[NSNumber class]]
                    && [[v objectAtIndex:a] intValue] >= 100) {
                    sum++;
                }
                break;
            case SUPLA_CHANNELFNC_DIMMER:
                if ([self getIntFromObject:[v objectAtIndex:a] atArrIndex:2] > 0 ) {
                    sum++;
                }
                count++;
                break;
            case SUPLA_CHANNELFNC_RGBLIGHTING:
                if ([self getIntFromObject:[v objectAtIndex:a] atArrIndex:1] > 0 ) {
                    sum++;
                }
                count++;
                break;
            case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                if ((idx == 0 || idx == 1)
                    && [self getIntFromObject:[v objectAtIndex:a] atArrIndex:1] > 0 ) {
                    sum++;
                }
                
                if ((idx == 0 || idx == 2)
                    && [self getIntFromObject:[v objectAtIndex:a] atArrIndex:2] > 0 ) {
                    sum++;
                }
                if (idx) {
                    count++;
                } else {
                   count+=2;
                }
                break;
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
                if ([self getIntFromObject:[v objectAtIndex:a] atArrIndex:0] >= 100     // percent
                    || [self getIntFromObject:[v objectAtIndex:a] atArrIndex:1] > 0) {  // sensor
                    sum++;
                }
                count++;
                break;
            case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
                if ([self getIntFromObject:[v objectAtIndex:a] atArrIndex:0] == YES) {
                    sum++;
                }
                count++;
                break;
        }
    }

    return count == 0 ? 0 : sum * 100 / count;
}

- (int) activePercent {
    return [self activePercentForIndex:0];
}

- (int) imgIsActive {
    
    if (self.func == SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING) {
        int active = 0;
        if ([self activePercentForIndex:2] >= 100) {
            active = 0x1;
        }
        if ([self activePercentForIndex:1] >= 100) {
            active |= 0x2;
        }
        
        return active;
    }
    
    return self.activePercent >= 100;
}

- (NSMutableArray*) positions {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if ((self.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER
         || self.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW)
        && self.total_value != nil) {
        NSArray *ar = (NSArray*)self.total_value;
        for(int a=0;a<ar.count;a++) {
            int pos = [self getIntFromObject:[ar objectAtIndex:a] atArrIndex:0];
            int sensor = [self getIntFromObject:[ar objectAtIndex:a] atArrIndex:1];
            
            if (pos < 100 && sensor == 1) {
                pos = 100;
            }
            
            [result addObject:[NSNumber numberWithInt:pos]];
        }
    }
    
    
    return result;
}

- (NSMutableArray*) rgbValue:(int)idx {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if (self.total_value != nil) {
        NSArray *ar = (NSArray*)self.total_value;
        int a;
        if (idx == 0) {
            id obj1, obj2;
            for(a=0;a<ar.count;a++) {
                obj1 = [ar objectAtIndex:a];
                if ([obj1 isKindOfClass:[NSArray class]]) {
                    obj2 = [((NSArray*)obj1) objectAtIndex:0];
                    UIColor *color = [UIColor transformToColor:obj2];
                    if (color) {
                        [result addObject:color];
                    }
                }
            }
        } else {
            for(a=0;a<ar.count;a++) {
                [result addObject:[self getNumberFromObject:[ar objectAtIndex:a] atArrIndex:idx]];
            }
        }

    }
    
    return result;
}

- (NSMutableArray*) colors {
    switch (self.func) {
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return [self rgbValue:0];
    }
    return [[NSMutableArray alloc] init];
}

- (NSMutableArray*) colorBrightness {
    switch (self.func) {
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return [self rgbValue:1];
    }
    return [[NSMutableArray alloc] init];
}

- (NSMutableArray*) brightness {
    switch (self.func) {
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return [self rgbValue:2];
    }
    return [[NSMutableArray alloc] init];
}

- (double)measuredTemperature:(BOOL)measured min:(BOOL)min {
    
    double result = -273;
    
    if (self.total_value != nil) {
        NSArray *arr1 = (NSArray*)self.total_value;
        if (arr1 != nil && [arr1 isKindOfClass:[NSArray class]]) {
            for(int a=0;a<arr1.count;a++) {
                NSArray *arr2 = [arr1 objectAtIndex:a];

                if (arr2 != nil
                    && [arr2 isKindOfClass:[NSArray class]]
                    && arr2.count >= 3) {
                    NSNumber *n = [arr2 objectAtIndex:measured ? 1 : 2];
                    if (n != nil && [n isKindOfClass:[NSNumber class]]) {
                        double t = [n doubleValue];
            
                        if (min) {
                            if ( (t < result || result <= -273) && t > -273) {
                                result = t;
                            }
                        } else if (t > result) {
                            result = t;
                        }
                    }
                }
            }
        }
    }
    
    return result;
}

- (double) measuredTemperatureMin {
    return [self measuredTemperature:YES min:YES];
}

- (double) measuredTemperatureMax {
    return [self measuredTemperature:YES min:NO];
}

- (double) presetTemperatureMin {
    return [self measuredTemperature:NO min:YES];
}

- (double) presetTemperatureMax {
    return [self measuredTemperature:NO min:NO];
}

@end
