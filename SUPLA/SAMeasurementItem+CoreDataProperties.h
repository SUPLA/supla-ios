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


#import "SAMeasurementItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN
@class AuthProfileItem;
@interface SAMeasurementItem (CoreDataProperties)

+ (NSFetchRequest<SAMeasurementItem *> *)fetchRequest;

@property (nonatomic) int32_t channel_id;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) int16_t year;
@property (nonatomic) int16_t month;
@property (nonatomic) int16_t day;
@property (nonatomic) int16_t weekday;
@property (nonatomic) int16_t hour;
@property (nonatomic) int16_t minute;
@property (nonatomic) int16_t second;
@property (nonatomic, retain) AuthProfileItem *profile;
@end

NS_ASSUME_NONNULL_END
