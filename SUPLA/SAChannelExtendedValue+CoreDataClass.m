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
@end
