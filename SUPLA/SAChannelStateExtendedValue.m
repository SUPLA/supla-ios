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

#import "SAChannelStateExtendedValue.h"
#import "SuplaApp.h"
#import "SUPLA-Swift.h"

@implementation SAChannelStateExtendedValue {
    TChannelState_ExtendedValue _csev;
}

-(id)initWithExtendedValue:(SAChannelExtendedValue *)ev {
    if ([super initWithExtendedValue:ev]
        && [self getChannelStateExtendedValue:&_csev]) {
        return self;
    }
    return nil;
}

-(id)initWithChannelState:(TDSC_ChannelState *)state {
    if ([super init]) {
        if (state) {
            memcpy(&_csev, state, sizeof(TDSC_ChannelState));
        } else {
            memset(&_csev, 0, sizeof(TChannelState_ExtendedValue));
        }
        return self;
    }
    return nil;
}

-(BOOL)getChannelStateExtendedValue:(TChannelState_ExtendedValue*)csev {
    if (csev == NULL) {
        return false;
    }
    
    memset(csev, 0, sizeof(TChannelState_ExtendedValue));
    
    __block BOOL result = NO;
    
    [self forEach:^BOOL(TSuplaChannelExtendedValue * _Nonnull ev) {
        if (ev->type == EV_TYPE_CHANNEL_STATE_V1
              && ev->size == sizeof(TChannelState_ExtendedValue)) {
            memcpy(csev, ev->value, sizeof(TChannelState_ExtendedValue));
            result = YES;
        } else if (self.valueType == EV_TYPE_CHANNEL_AND_TIMER_STATE_V1
                   && ev->size >= sizeof(TChannelAndTimerState_ExtendedValue) -
                       SUPLA_SENDER_NAME_MAXSIZE
                   && ev->size <= sizeof(TChannelAndTimerState_ExtendedValue)) {
            TChannelAndTimerState_ExtendedValue *state = (TChannelAndTimerState_ExtendedValue*)ev->value;
            memcpy(csev, &state->Channel, sizeof(TChannelState_ExtendedValue));
            result = YES;
        }
        
        return !result;
    }];

    return result;
}

-(TDSC_ChannelState)state {
    return _csev;
}

@end

@implementation SAChannelExtendedValue (SAChannelStateExtendedValue)

- (SAChannelStateExtendedValue*)channelState {
    return [[SAChannelStateExtendedValue alloc] initWithExtendedValue:self];
}

@end
