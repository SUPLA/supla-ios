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
        case SUPLA_CHANNELFNC_POWERSWITCH:
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
        case SUPLA_CHANNELFNC_STAIRCASETIMER:
            break;
        default:
            return;
    }
    
    BufferCounter++;
    if ([value isOnline]) {
        BufferOnLineCount++;
    }
    
    switch(self.func) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            [BufferTotalValue addObject:[NSNumber numberWithBool: value.hiSubValue]];
            break;

        case SUPLA_CHANNELFNC_POWERSWITCH:
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
        case SUPLA_CHANNELFNC_STAIRCASETIMER:
            [BufferTotalValue addObject:[NSNumber numberWithBool: value.hiValue]];
            break;
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER: {
            NSArray *obj = [NSArray arrayWithObjects:[NSNumber numberWithInt: value.percentValue],
                            [NSNumber numberWithBool: value.hiSubValue], nil];
            [BufferTotalValue addObject:obj];
        }
            break;
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING: {
            NSArray *obj = [NSArray arrayWithObjects:value.colorValue,
                            [NSNumber numberWithInt: value.colorBrightnessValue],
                            [NSNumber numberWithInt: value.brightnessValue], nil];
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
@end
