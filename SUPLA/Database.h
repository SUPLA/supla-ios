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
#import "proto.h"

typedef NS_ENUM(NSUInteger, GroupingDepth) {
    gdNone,
    gdMinutely,
    gdHourly,
    gdDaily,
    gdMonthly,
    gdYearly
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
@interface SADatabase :NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)initSaveObserver;
- (void)releaseSaveObserver;
- (void)saveContext;

-(_SALocation*) fetchLocationById:(int)location_id;
-(_SALocation*) newLocation;
-(BOOL) updateLocation:(TSC_SuplaLocation *)location;

-(SAChannel*) fetchChannelById:(int)channel_id;
-(SAChannelValue*) fetchChannelValueByChannelId:(int)channel_id;
-(BOOL) updateChannel:(TSC_SuplaChannel_C *)channel;
-(BOOL) updateChannelValue:(TSC_SuplaChannelValue *)channel_value;
-(BOOL) updateChannelExtendedValue:(TSC_SuplaChannelExtendedValue *)channel_value;
-(NSFetchedResultsController*) getChannelFrc;
-(BOOL) setChannelsOffline;
-(BOOL) setAllOfChannelVisible:(int)visible whereVisibilityIs:(int)wvi;
-(NSUInteger) getChannelCount;
-(BOOL) setAllOfChannelGroupVisible:(int)visible whereVisibilityIs:(int)wvi;
-(BOOL) setAllOfChannelGroupRelationVisible:(int)visible whereVisibilityIs:(int)wvi;
-(SAChannelGroup*) fetchChannelGroupById:(int)remote_id;
-(BOOL) updateChannelGroup:(TSC_SuplaChannelGroup_B *)channel_group;
-(BOOL) updateChannelGroupRelation:(TSC_SuplaChannelGroupRelation *)cgroup_relation;
- (NSArray*) updateChannelGroups;
-(NSFetchedResultsController*) getChannelGroupFrc;
-(SAColorListItem *) getColorListItemForRemoteId:(int)remote_id andIndex:(int)idx forGroup:(BOOL)group;
-(void) updateColorListItem:(SAColorListItem *)item;
-(SAElectricityMeasurementItem*) newElectricityMeasurementItemWithManagedObjectContext:(BOOL)moc;
-(SAElectricityMeasurementItem*) fetchOlderThanDate:(NSDate*)date uncalculatedElectricityMeasurementItemWithChannel:(int)channel_id;
-(NSUInteger) getElectricityMeasurementItemCount;
-(long) getTimestampOfElectricityMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min;
-(void) deleteAllElectricityMeasurementsForChannelId:(int)channel_id;
-(void) deleteUncalculatedElectricityMeasurementsForChannelId:(int)channel_id;
-(NSUInteger) getElectricityMeasurementItemCountWithoutComplementForChannelId:(int)channel_id;
-(BOOL) electricityMeterMeasurementsStartsWithTheCurrentMonthForChannelId:(int)channel_id;
-(double) sumForwardedActiveEnergyForChannelId:(int)channel_id monthLimitOffset:(int) offset;
-(NSArray *) getElectricityMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo groupBy:(GroupBy)gb groupingDepth:(GroupingDepth)gd;
-(NSArray *) iconsToDownload;
-(SAUserIcon*) fetchUserIconById:(int)remote_id;
@end


