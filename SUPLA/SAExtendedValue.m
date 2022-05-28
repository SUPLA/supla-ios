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

#import "SAExtendedValue.h"
#import "SAChannelExtendedValue+CoreDataClass.h"
#import "supla-client.h"

@implementation SAExtendedValue

@synthesize ev;

-(id)initWithExtendedValue:(SAChannelExtendedValue *)ev {
    if (self = [self init]) {
        self.ev = ev;
    }
    
    return self;
}

- (NSData *) dataValue {
    return ev ? ev.dataValue : nil;
}

- (int) valueType {
    return ev ? ev.valueType : 0;
}

- (void) forEach: (BOOL (^)(TSuplaChannelExtendedValue *ev))method {
    if (!method) {
        return;
    }
    
    TSuplaChannelExtendedValue multi_ev = {};
    
    NSData *data = self.dataValue;
    if (data && data.length <= SUPLA_CHANNELEXTENDEDVALUE_SIZE) {
        [data getBytes:multi_ev.value length:data.length];
        multi_ev.size = (unsigned int)data.length;
        multi_ev.type = self.valueType;
        
        int index = 0;
        TSuplaChannelExtendedValue single_ev = {};

        while (srpc_evtool_value_get(&multi_ev, index, &single_ev)) {
          index++;
          if (!method(&single_ev)) {
            break;
          }
        }
    }
}

@end
