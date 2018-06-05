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

- (BOOL) setOnlineState:(char)online {
    
    if ( self.online != (online != 0) ) {
        self.online = (online != 0);
        return YES;
    }
    
    return NO;
}

- (NSData *) dataValue {
    return self.value && ((NSData*)self.value).length == SUPLA_CHANNELVALUE_SIZE ? (NSData*)self.value : nil;
}

- (NSData *) dataSubValue {
    return self.sub_value && ((NSData*)self.sub_value).length == SUPLA_CHANNELVALUE_SIZE ? (NSData*)self.sub_value : nil;
}

- (BOOL) setValueWithChannelValue:(TSuplaChannelValue*)value {
    
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

- (int) intValue {
    if ( self.value != nil ) {
        int i = 0;
        [self.dataValue getBytes:&i length:sizeof(int)];
        return i;
    }
    
    return 0;
}

- (double) getTemperatureForFunction:(int)func {
    
    double result = -275;
    
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

@end
