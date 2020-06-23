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

#import "SAElectricityMeasurementItem+CoreDataClass.h"

@implementation SAElectricityMeasurementItem

- (double) doubleForKey:(NSString*)key withObject:(NSDictionary*)object {
    NSString *str = [object valueForKey:key];
    return str == nil || [str isKindOfClass:[NSNull class]] ? 0.0 : [str longLongValue] * 0.00001;
}

- (void) assignJSONObject:(NSDictionary *)object {
    [super assignJSONObject:object];
    self.phase1_fae = [self doubleForKey:@"phase1_fae" withObject:object];
    self.phase2_fae = [self doubleForKey:@"phase2_fae" withObject:object];
    self.phase3_fae = [self doubleForKey:@"phase3_fae" withObject:object];
    self.phase1_rae = [self doubleForKey:@"phase1_rae" withObject:object];
    self.phase2_rae = [self doubleForKey:@"phase2_rae" withObject:object];
    self.phase3_rae = [self doubleForKey:@"phase3_rae" withObject:object];
    self.phase1_fre = [self doubleForKey:@"phase1_fre" withObject:object];
    self.phase2_fre = [self doubleForKey:@"phase2_fre" withObject:object];
    self.phase3_fre = [self doubleForKey:@"phase3_fre" withObject:object];
    self.phase1_rre = [self doubleForKey:@"phase1_rre" withObject:object];
    self.phase2_rre = [self doubleForKey:@"phase2_rre" withObject:object];
    self.phase3_rre = [self doubleForKey:@"phase3_rre" withObject:object];
    self.fae_balanced = [self doubleForKey:@"fae_balanced" withObject:object];
    self.rae_balanced = [self doubleForKey:@"rae_balanced" withObject:object];
    
    //NSLog(@"fae=%f rae=%f", self.fae_balanced, self.rae_balanced);
}

- (void) assignMeasurementItem:(SAMeasurementItem*)source {
    [super assignMeasurementItem:source];
    if ([source isKindOfClass:[SAElectricityMeasurementItem class]]) {
        SAElectricityMeasurementItem *src = (SAElectricityMeasurementItem*)source;
        self.phase1_fae = src.phase1_fae;
        self.phase2_fae = src.phase2_fae;
        self.phase3_fae = src.phase3_fae;
        self.phase1_rae = src.phase1_rae;
        self.phase2_rae = src.phase2_rae;
        self.phase3_rae = src.phase3_rae;
        self.phase1_fre = src.phase1_fre;
        self.phase2_fre = src.phase2_fre;
        self.phase3_fre = src.phase3_fre;
        self.phase1_rre = src.phase1_rre;
        self.phase2_rre = src.phase2_rre;
        self.phase3_rre = src.phase3_rre;
        self.fae_balanced = src.fae_balanced;
        self.rae_balanced = src.rae_balanced;
    }
    
}

- (void) calculateWithSource:(SAMeasurementItem*)source {
    if ([source isKindOfClass:[SAElectricityMeasurementItem class]]) {
        SAElectricityMeasurementItem *src = (SAElectricityMeasurementItem*)source;
        self.phase1_fae = self.phase1_fae - src.phase1_fae;
        self.phase2_fae = self.phase2_fae - src.phase2_fae;
        self.phase3_fae = self.phase3_fae - src.phase3_fae;
        self.phase1_rae = self.phase1_rae - src.phase1_rae;
        self.phase2_rae = self.phase2_rae - src.phase2_rae;
        self.phase3_rae = self.phase3_rae - src.phase3_rae;
        self.phase1_fre = self.phase1_fre - src.phase1_fre;
        self.phase2_fre = self.phase2_fre - src.phase2_fre;
        self.phase3_fre = self.phase3_fre - src.phase3_fre;
        self.phase1_rre = self.phase1_rre - src.phase1_rre;
        self.phase2_rre = self.phase2_rre - src.phase2_rre;
        self.phase3_rre = self.phase3_rre - src.phase3_rre;
        self.fae_balanced = self.fae_balanced - src.fae_balanced;
        self.rae_balanced = self.rae_balanced - src.rae_balanced;
        
        self.calculated = YES;
    }
}

- (void) divideBy:(double)n {
    
    self.phase1_fae = self.phase1_fae / n;
    self.phase2_fae = self.phase2_fae / n;
    self.phase3_fae = self.phase3_fae / n;
    self.phase1_rae = self.phase1_rae / n;
    self.phase2_rae = self.phase2_rae / n;
    self.phase3_rae = self.phase3_rae / n;
    self.phase1_fre = self.phase1_fre / n;
    self.phase2_fre = self.phase2_fre / n;
    self.phase3_fre = self.phase3_fre / n;
    self.phase1_rre = self.phase1_rre / n;
    self.phase2_rre = self.phase2_rre / n;
    self.phase3_rre = self.phase3_rre / n;
    self.fae_balanced = self.fae_balanced / n;
    self.rae_balanced = self.rae_balanced / n;
    
    self.divided = YES;
}
@end
