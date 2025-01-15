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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SAElectricityMeasurementItem+CoreDataClass.h"
#import "SAImpulseCounterMeasurementItem+CoreDataClass.h"
#import "SAThermostatMeasurementItem+CoreDataClass.h"
#import "SATemperatureMeasurementItem+CoreDataClass.h"
#import "SATempHumidityMeasurementItem+CoreDataClass.h"
#import "SAScene+CoreDataClass.h"
#import "proto.h"

typedef NS_ENUM(NSUInteger, GroupingDepth) {
    gdNone,
    gdMinutes,
    gdHours,
    gdDays,
    gdMonths,
    gdYears
};

typedef NS_ENUM(NSUInteger, GroupBy) {
    gbNone,
    gbMinute,
    gbHour,
    gbDay,
    gbWeekday,
    gbMonth,
    gbYear,
};

@class _SALocation;
@class SAChannel;
@class SAChannelValue;
@class SAColorListItem;
@class SAChannelGroup;
@class SAUserIcon;
@class SAChannelBase;
@interface SADatabase :NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)initSaveObserver;
- (void)releaseSaveObserver;
- (void)saveContext;

-(_SALocation*) fetchLocationById:(int)location_id;
-(_SALocation*) newLocation;

-(SAChannel*) fetchChannelById:(int)channel_id;
-(NSUInteger) getChannelCount;
-(SAChannelGroup*) fetchChannelGroupById:(int)remote_id;
-(SAColorListItem *) getColorListItemForRemoteId:(int)remote_id andIndex:(int)idx forGroup:(BOOL)group;
-(void) updateColorListItem:(SAColorListItem *)item;

-(SAThermostatMeasurementItem*) newThermostatMeasurementItem;
-(long) getTimestampOfThermostatMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min;
-(NSUInteger) getThermostatMeasurementItemCountForChannelId:(int)channel_id;
-(void) deleteAllThermostatMeasurementsForChannelId:(int)channel_id;
-(NSArray *) getThermostatMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo;
-(NSFetchedResultsController*) getHomePlusGroupFrcWithGroupId:(int)groupId;
-(BOOL) zwaveBridgeChannelAvailable;
-(NSArray*) zwaveBridgeChannels;

- (void)deleteObject:(NSManagedObject *)object;
@end


