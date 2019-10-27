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

#import "SAImpulseCounterMeasurementItem+CoreDataClass.h"

@implementation SAImpulseCounterMeasurementItem

- (void) assignJSONObject:(NSDictionary *)object {
    [super assignJSONObject:object];
    self.counter = [self longLongForKey:@"counter" withObject:object];
    self.calculated_value = [self doubleForKey:@"calculated_value" withObject:object];
}

- (void) assignMeasurementItem:(SAMeasurementItem*)source {
    [super assignMeasurementItem:source];
    if ([source isKindOfClass:[SAImpulseCounterMeasurementItem class]]) {
        SAImpulseCounterMeasurementItem *src = (SAImpulseCounterMeasurementItem*)source;
        self.counter = src.counter;
        self.calculated_value = src.calculated_value;
    }
    
}

- (void) calculateWithSource:(SAMeasurementItem*)source {
    if ([source isKindOfClass:[SAImpulseCounterMeasurementItem class]]) {
        SAImpulseCounterMeasurementItem *src = (SAImpulseCounterMeasurementItem*)source;
        self.counter  = self.counter  - src.counter;
        self.calculated_value = self.calculated_value - src.calculated_value;
        
        self.calculated = YES;
    }
}

- (void) divideBy:(double)n {
    
    self.counter = self.counter / n;
    self.calculated_value = self.calculated_value / n;
    
    self.divided = YES;
}

@end
