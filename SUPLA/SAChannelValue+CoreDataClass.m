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

- (BOOL) setOnline:(char)online {
    
    if ( self.online != (online != 0) ) {
        self.online = (online != 0);
        return YES;
    }
    
    return NO;
}


- (BOOL) setValue:(TSuplaChannelValue*)value {
    
    id old_val = self.value;
    id old_sub_val = self.sub_value;
    
    switch([self.func intValue]) {
            
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
        case SUPLA_CHANNELFNC_POWERSWITCH:
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
            
            self.value = [NSNumber numberWithBool:value->value[0] == 1];
            self.sub_value = [NSNumber numberWithBool:value->sub_value[0] == 1];
            
            break;
            
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
            
            self.value = [NSNumber numberWithInt:value->value[0]];
            self.sub_value = [NSNumber numberWithBool:value->sub_value[0] == 1];
            
            break;
            
        case SUPLA_CHANNELFNC_THERMOMETER:
        case SUPLA_CHANNELFNC_DEPTHSENSOR:
        case SUPLA_CHANNELFNC_DISTANCESENSOR:
        {
            double v;
            memcpy(&v, value->value, sizeof(double));
            self.value = [NSNumber numberWithDouble:v];
            self.sub_value = nil;
            break;
        }
            
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
        {
            double t,h;
            int v;
            
            memcpy(&v, value->value, 4);
            t = v/1000.00;
            
            memcpy(&v, &value->value[4], 4);
            h = v/1000.00;
            
            self.value = [NSArray arrayWithObjects:[NSNumber numberWithDouble:t], [NSNumber numberWithDouble:h], nil];
            self.sub_value = nil;
            break;
        }
            
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
        case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
        case SUPLA_CHANNELFNC_MAILSENSOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW:
            self.value = [NSNumber numberWithBool:value->value[0] == 1];
            self.sub_value = nil;
            break;
            
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
        {
            int brightness = value->value[0];
            
            if ( brightness > 100 || brightness < 0 )
                brightness = 0;
            
            int colorBrightness = value->value[1];
            
            if ( colorBrightness > 100 || colorBrightness < 0 )
                colorBrightness = 0;
            
            UIColor *color = [UIColor colorWithRed:(unsigned char)value->value[4]/255.00 green:(unsigned char)value->value[3]/255.00 blue:(unsigned char)value->value[2]/255.00 alpha:1];
            
            if ( (unsigned char) value->value[4] == 255
                && (unsigned char) value->value[3] == 255
                && (unsigned char) value->value[2] == 255 ) color = [UIColor whiteColor];
            
            
            self.value = [NSArray arrayWithObjects:[NSNumber numberWithInt:brightness], [NSNumber numberWithInt:colorBrightness], color, nil];
        }
            break;
    }
    
    if ( [self number:(NSNumber*)self.value isEqualToNumber:old_val] == NO
        || [self number:(NSNumber*)self.sub_value isEqualToNumber:old_sub_val] == NO ) {
        return YES;
    }
    
    return NO;
    
}

@end
