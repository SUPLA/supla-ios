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
#import "supla-client.h"

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
    if (icev == NULL) {
        return NO;
    }
    
    __block BOOL result = NO;
    
    [self forEach:^BOOL(TSuplaChannelExtendedValue * _Nonnull ev) {
        result = srpc_evtool_v1_extended2icextended(ev, icev);
        return !result;
    }];

    return result;
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

- (double) totalCost {
    return _icev.total_cost * 0.01;
}

- (double) pricePerUnit {
    return _icev.price_per_unit * 0.0001;
}

- (double) calculatedValue {
    return _icev.calculated_value * 0.001;
}

- (unsigned long long) counter {
    return _icev.counter;
}

- (int)impulsesPerUnit {
    return _icev.impulses_per_unit;
}
@end

@implementation SAChannelExtendedValue (SAExectricityMeterExtendedValue)

- (SAImpulseCounterExtendedValue*)impulseCounter {
    return [[SAImpulseCounterExtendedValue alloc] initWithExtendedValue:self];
}

@end
