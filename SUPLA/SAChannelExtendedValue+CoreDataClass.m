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
#import "supla-client.h"

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

- (NSDate*) getTimerEndDate: (int32_t) type size: (int32_t) size value: (char[]) value {
    TTimerState_ExtendedValue timerState = {};
    if (type == EV_TYPE_CHANNEL_AND_TIMER_STATE_V1) {
        if (size >= sizeof(TChannelAndTimerState_ExtendedValue) - SUPLA_SENDER_NAME_MAXSIZE
            && size <= sizeof(TChannelAndTimerState_ExtendedValue)) {
            TChannelAndTimerState_ExtendedValue *state = (TChannelAndTimerState_ExtendedValue*) value;
            memcpy(&timerState, &state->Timer, size - sizeof(TChannelState_ExtendedValue));
            
            return [[NSDate alloc] initWithTimeIntervalSince1970: timerState.CountdownEndsAt];
        }
    } else if (type == EV_TYPE_TIMER_STATE_V1) {
        memcpy(&timerState, value, size);
        
        return [[NSDate alloc] initWithTimeIntervalSince1970: timerState.CountdownEndsAt];
    }
    return nil;
}

- (NSDate*) getTimerEndDate {
    NSData* data = [self dataValue];
    TSuplaChannelExtendedValue multi_ev = {};
    if (data && data.length <= SUPLA_CHANNELEXTENDEDVALUE_SIZE) {
        [data getBytes:multi_ev.value length:data.length];
        multi_ev.size = (unsigned int) data.length;
        multi_ev.type = self.valueType;
        
        if (self.valueType != EV_TYPE_MULTI_VALUE) {
            return [self getTimerEndDate:multi_ev.type size:multi_ev.size value:multi_ev.value];
        }
        
        int index = 0;
        TSuplaChannelExtendedValue single_ev = {};
        
        while (srpc_evtool_value_get(&multi_ev, index, &single_ev)) {
            TTimerState_ExtendedValue timerState = {};
            
            NSDate* timerEndDate = [self getTimerEndDate:single_ev.type size:single_ev.size value:single_ev.value];
            if (timerEndDate != nil) {
                return timerEndDate;
            }
        }
    }
    
    return nil;
}

- (BOOL) setValueSwift:(TSuplaChannelExtendedValue)value {
    
    BOOL result = NO;
    int size = sizeof(value.value);
    
    if (value.size < size) {
        size = value.size;
    }
    
    if (size > 0) {
        NSDate* oldTimerEndDate = [self getTimerEndDate];
        
        self.type = value.type;
        NSData *v =  [NSData dataWithBytes:value.value length:size];
        
        if ( self.type != value.type
            || self.value == nil
            || ![self.value isKindOfClass: NSData.class]
            || ![v isEqualToData:(NSData *)self.value] ) {
            self.value = v;
            self.type = value.type;
            
            NSDate* timerEndDate = [self getTimerEndDate];
            if (timerEndDate != nil) {
                NSDate* currentDate = [[NSDate alloc] init];
                if (self.timerStartTime == nil) {
                    self.timerStartTime = currentDate;
                } else if (currentDate.timeIntervalSince1970 > timerEndDate.timeIntervalSince1970) {
                    self.timerStartTime = nil;
                } else if(timerEndDate != oldTimerEndDate) {
                    self.timerStartTime = currentDate;
                }
            } else {
                self.timerStartTime = nil;
            }
            
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
@end
