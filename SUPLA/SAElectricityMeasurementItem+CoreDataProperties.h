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


NS_ASSUME_NONNULL_BEGIN

@interface SAElectricityMeasurementItem (CoreDataProperties)

+ (NSFetchRequest<SAElectricityMeasurementItem *> *)fetchRequest;

@property (nonatomic) double phase1_fae;
@property (nonatomic) double phase1_fre;
@property (nonatomic) double phase1_rae;
@property (nonatomic) double phase1_rre;
@property (nonatomic) double phase2_fae;
@property (nonatomic) double phase2_fre;
@property (nonatomic) double phase2_rae;
@property (nonatomic) double phase2_rre;
@property (nonatomic) double phase3_fae;
@property (nonatomic) double phase3_fre;
@property (nonatomic) double phase3_rae;
@property (nonatomic) double phase3_rre;
@property (nonatomic) double fae_balanced;
@property (nonatomic) double rae_balanced;

@end

NS_ASSUME_NONNULL_END
