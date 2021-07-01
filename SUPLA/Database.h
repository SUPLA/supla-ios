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
-(NSArray*) fetchVisibleLocations;
-(_SALocation*) newLocation;
-(BOOL) updateLocation:(TSC_SuplaLocation *)location;

-(SAChannel*) fetchChannelById:(int)channel_id;
-(SAChannelValue*) fetchChannelValueByChannelId:(int)channel_id;
-(BOOL) updateChannel:(TSC_SuplaChannel_D *)channel;
-(BOOL) updateChannelValue:(TSC_SuplaChannelValue_B *)channel_value;
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
-(long) getTimestampOfElectricityMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min;
-(void) deleteAllElectricityMeasurementsForChannelId:(int)channel_id;
-(NSUInteger) getElectricityMeasurementItemCountWithoutComplementForChannelId:(int)channel_id;
-(BOOL) electricityMeterMeasurementsStartsWithTheCurrentMonthForChannelId:(int)channel_id;
- (double) sumActiveEnergyForChannelId:(int)channel_id monthLimitOffset:(int) offset forwarded:(BOOL)fwd;
-(NSArray *) getElectricityMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo groupBy:(GroupBy)gb groupingDepth:(GroupingDepth)gd fields:(NSArray*)fields;
-(long) getTimestampOfImpulseCounterMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min;
-(SAImpulseCounterMeasurementItem*) newImpulseCounterMeasurementItemWithManagedObjectContext:(BOOL)moc;
-(void) deleteAllImpulseCounterMeasurementsForChannelId:(int)channel_id;
-(NSUInteger) getImpulseCounterMeasurementItemCountWithoutComplementForChannelId:(int)channel_id;
-(BOOL) impulseCounterMeasurementsStartsWithTheCurrentMonthForChannelId:(int)channel_id;
-(double) calculatedValueSumForChannelId:(int)channel_id monthLimitOffset:(int)offset;
-(NSArray *) getImpulseCounterMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo groupBy:(GroupBy)gb groupingDepth:(GroupingDepth)gd;

-(SATemperatureMeasurementItem*) newTemperatureMeasurementItem;
-(long) getTimestampOfTemperatureMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min;
-(NSUInteger) getTemperatureMeasurementItemCountForChannelId:(int)channel_id;
-(void) deleteAllTemperatureMeasurementsForChannelId:(int)channel_id;
-(NSArray *) getTemperatureMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo;

-(SATempHumidityMeasurementItem*) newTempHumidityMeasurementItem;
-(long) getTimestampOfTempHumidityMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min;
-(NSUInteger) getTempHumidityMeasurementItemCountForChannelId:(int)channel_id;
-(void) deleteAllTempHumidityMeasurementsForChannelId:(int)channel_id;
-(NSArray *) getTempHumidityMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo;

-(SAThermostatMeasurementItem*) newThermostatMeasurementItem;
-(long) getTimestampOfThermostatMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min;
-(NSUInteger) getThermostatMeasurementItemCountForChannelId:(int)channel_id;
-(void) deleteAllThermostatMeasurementsForChannelId:(int)channel_id;
-(NSArray *) getThermostatMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo;
-(NSFetchedResultsController*) getHomePlusGroupFrcWithGroupId:(int)groupId;
-(BOOL) updateChannelUserIcons;
-(NSArray *) iconsToDownload;
-(SAUserIcon*) fetchUserIconById:(int)remote_id createNewObject:(BOOL)create;
-(void) deleteAllUserIcons;
-(BOOL) zwaveBridgeChannelAvailable;
-(NSArray*) zwaveBridgeChannels;

-(void) moveChannel:(SAChannelBase*)src toPositionOfChannel:(SAChannelBase*)dst;
-(void) moveChannelGroup:(SAChannelBase*)src toPositionOfChannelGroup:(SAChannelBase*)dst;
- (void)deleteObject:(NSManagedObject *)object;
@end


