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

#import "SAIncrementalMeasurementItem+CoreDataClass.h"
#import "SuplaApp.h"

@implementation SAIncrementalMeasurementItem
@synthesize calculated;

- (void) calculateWithSource:(SAMeasurementItem*)source {
    ABSTRACT_METHOD_EXCEPTION;
}

- (void) divideBy:(double)n {
    ABSTRACT_METHOD_EXCEPTION;
}

- (void) assignMeasurementItem:(SAMeasurementItem*)source {
    [super assignMeasurementItem:source];
    if ([source isKindOfClass:[SAIncrementalMeasurementItem class]]) {
        SAIncrementalMeasurementItem *src = (SAIncrementalMeasurementItem*)source;
        self.calculated = src.calculated;
        self.divided = src.divided;
        self.complement = src.complement;
    }
}

- (double) calculateValue: (double) current and: (double) previous {
    double diff = current - previous;
    if (diff >= 0) {
        return diff;
    } else if (fabs(diff) <= previous * 0.1) {
        return 0;
    } else {
        return current;
    }
}

- (int64_t) calculateValueInt: (int64_t) current and: (int64_t) previous {
    double diff = current - previous;
    if (diff >= 0) {
        return diff;
    } else if (fabs(diff) <= previous * 0.1) {
        return 0;
    } else {
        return current;
    }
}

@end
