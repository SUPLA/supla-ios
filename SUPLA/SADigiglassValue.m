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

#import "SADigiglassValue.h"
#import "proto.h"

@implementation SADigiglassValue {
    TDigiglass_Value _value;
}

- (id)init {
    if (self = [super init]) {
        memset(&_value, 0, sizeof(TDigiglass_Value));
    }
    return self;
}

- (id)initWithData:(nullable NSData *)value {
    if (self = [super init]) {
        memset(&_value, 0, sizeof(TDigiglass_Value));
        if (value && value.length >= sizeof(TDigiglass_Value)) {
            [value getBytes:&_value length:sizeof(TDigiglass_Value)];
        }
    }
    return self;
}

- (int) flags {
    return _value.flags;
}

- (int) sectionCount {
    return _value.sectionCount;
}

- (int) mask {
    return _value.mask;
}

- (BOOL) isTooLongOperationPresent {
    return _value.flags & DIGIGLASS_TOO_LONG_OPERATION_WARNING;
}

- (BOOL) isPlannedRegenerationInProgress {
    return _value.flags & DIGIGLASS_PLANNED_REGENERATION_IN_PROGRESS;
}

- (BOOL) regenerationAfter20hInProgress {
    return _value.flags & DIGIGLASS_REGENERATION_AFTER_20H_IN_PROGRESS;
}

- (BOOL) isSectionTransparent:(short)number {
    if (number < _value.sectionCount) {
        short bit = (short) (1 << number);
        return (_value.mask & bit) > 0;
    }
    return NO;
}

- (BOOL) isAnySectionTransparent {
    short activeBits = (short) (pow(2, _value.sectionCount) - 1);
    return (_value.mask & activeBits) > 0;
}

@end
