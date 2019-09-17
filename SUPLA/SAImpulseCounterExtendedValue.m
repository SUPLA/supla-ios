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

#import "SAImpulseCounterExtendedValue.h"

@implementation SAImpulseCounterExtendedValue {
    TSC_ImpulseCounter_ExtendedValue _icev;
}

-(id)initWithExtendedValue:(SAChannelExtendedValue *)ev {
    if ([super initWithExtendedValue:ev]
        && [self getImpulseCounterExtendedValue:&_icev]) {
        return self;
    }
    return nil;
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

- (NSString *) unit {
    _icev.custom_unit[sizeof(_icev.custom_unit)-1] = 0;
    NSString *unit = [NSString stringWithUTF8String:_icev.custom_unit];
    if (unit.length > 0) {
        return unit;
    }
    
    return nil;
}

- (NSString *) currency {
    return [self decodeCurrency:_icev.currency];
}
@end

@implementation SAChannelExtendedValue (SAExectricityMeterExtendedValue)

- (SAImpulseCounterExtendedValue*)impulseCounter {
    return [[SAImpulseCounterExtendedValue alloc] initWithExtendedValue:self];
}

@end
