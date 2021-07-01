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

#import "SAElectricityMeasurementItem+CoreDataProperties.h"

@implementation SAElectricityMeasurementItem (CoreDataProperties)

+ (NSFetchRequest<SAElectricityMeasurementItem *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"SAElectricityMeasurementItem"];
}

@dynamic phase1_fae;
@dynamic phase1_fre;
@dynamic phase1_rae;
@dynamic phase1_rre;
@dynamic phase2_fae;
@dynamic phase2_fre;
@dynamic phase2_rae;
@dynamic phase2_rre;
@dynamic phase3_fae;
@dynamic phase3_fre;
@dynamic phase3_rae;
@dynamic phase3_rre;
@dynamic fae_balanced;
@dynamic rae_balanced;

@end
