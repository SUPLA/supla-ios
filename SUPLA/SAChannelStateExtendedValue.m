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

-(BOOL)getChannelStateExtendedValue:(TChannelState_ExtendedValue*)csev {
    if (csev != NULL
        && self.valueType == EV_TYPE_CHANNEL_STATE_V1) {
        memset(csev, 0, sizeof(TChannelState_ExtendedValue));
        NSData *data = self.dataValue;
        if (data && data.length == sizeof(TChannelState_ExtendedValue)) {
            [data getBytes:csev length:data.length];
            return YES;
        }
    }
    return NO;
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
