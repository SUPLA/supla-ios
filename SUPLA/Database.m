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

#import <CoreData/CoreData.h>

#import "Database.h"
#import "SuplaApp.h"
#import "_SALocation+CoreDataClass.h"
#import "SAChannel+CoreDataClass.h"
#import "SAChannelGroupRelation+CoreDataClass.h"
#import "SAColorListItem+CoreDataClass.h"
#import "SAUserIcon+CoreDataClass.h"
#import "SUPLA-Swift.h"

@interface SADatabase ()
@property (readonly, nonatomic) AuthProfileItem *currentProfile;
@end

@implementation SADatabase {
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectContext *_managedObjectContext;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SUPLA" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (void)removeIfExists:(NSString *)dbFileName {
    NSURL *storeURL = [[SAApp applicationDocumentsDirectory] URLByAppendingPathComponent:dbFileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[storeURL path]]) {
        NSError *error = nil;
        [fileManager removeItemAtURL:storeURL error:&error];
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    /*
     Database version should not be incremented anymore. We now perform in-place
     data migration.
     */
    int DBv = 14;
    BOOL shouldMigrateProfile = NO;
    
    [self removeIfExists:@"SUPLA_DB.sqlite"];
    
    for(int a=0;a<DBv;a++) {
        [self removeIfExists:[NSString stringWithFormat:@"SUPLA_DB%i.sqlite", a]];
    }
    
    NSError *error = nil;
    NSDictionary *opts = nil;
    NSURL *storeURL = [[SAApp applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"SUPLA_DB%i.sqlite", DBv]];
    
    // Create the coordinator and store
again:
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil URL:storeURL
                                                         options:opts error:&error]) {
        /* If we are facing a store incompatibility issue, try to migrate the
           store automatically */
        if([error.domain isEqualToString: NSCocoaErrorDomain] &&
           error.code == NSPersistentStoreIncompatibleVersionHashError &&
           opts == nil) {
            opts = @{ NSMigratePersistentStoresAutomaticallyOption: @YES,
                      NSInferMappingModelAutomaticallyOption: @YES };
            shouldMigrateProfile = YES;
            goto again;
        }
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if(shouldMigrateProfile) {
        ProfileMigrator *migrator = [[ProfileMigrator alloc] init];
        NSError *err = nil;
        NSManagedObjectContext *migrationCtx = [[NSManagedObjectContext alloc] init];
        [migrationCtx setPersistentStoreCoordinator:_persistentStoreCoordinator];
        if(![migrator migrateProfileFromUserDefaults: migrationCtx
                                               error: &err]) {
            NSLog(@"exception during data migration attempt: %@", err);
            shouldMigrateProfile = NO;
            [self removeIfExists: storeURL.path];
            goto again;
        }
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    [_managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    return _managedObjectContext;
}


- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
 
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)initSaveObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)releaseSaveObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)managedObjectContextDidSaveNotification:(NSNotification *)n {
    
    if ( _managedObjectContext
        && _managedObjectContext != n.object ) {
        [_managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:n waitUntilDone:NO];
    };
    
}

-(NSArray *) fetchByPredicate:(NSPredicate *)predicate entityName:(NSString*)en limit:(int)l sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = predicate;
  
    fetchRequest.sortDescriptors = sortDescriptors;
    
    if ( l > 0 ) {
        [fetchRequest setFetchLimit:l];
    }
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:en inManagedObjectContext: self.managedObjectContext]];
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        return r;
    }
    
    return nil;
};

-(NSArray *) fetchByPredicate:(NSPredicate *)predicate entityName:(NSString*)en limit:(int)l {
    return [self fetchByPredicate:predicate entityName:en limit:l sortDescriptors:nil];
}

-(id) fetchItemByPredicate:(NSPredicate *)predicate entityName:(NSString*)en sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors {
    
    NSArray *r = [self fetchByPredicate:predicate entityName:en limit:1 sortDescriptors:sortDescriptors];
    if ( r != nil && r.count > 0 ) {
        return [r objectAtIndex:0];
    }
    
    return nil;
};

-(id) fetchItemByPredicate:(NSPredicate *)predicate entityName:(NSString*)en {
    return [self fetchItemByPredicate:predicate entityName:en sortDescriptors:nil];
}

-(NSUInteger) getCountByPredicate:(NSPredicate *)predicate entityName:(NSString *)en {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = predicate;
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:en inManagedObjectContext: self.managedObjectContext]];
    [fetchRequest setIncludesSubentities:NO];
    
    NSError *fetchError = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&fetchError];
    
    if(count == NSNotFound || fetchError != nil ) {
        count = 0;
    }
    
    return count;
}

- (NSDictionary *) sumValesOfEntitiesWithProperties:(NSArray *)props predicate:(NSPredicate *)predicate entityName:(NSString *)en {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = predicate;
    fetchRequest.propertiesToFetch = props;
    [fetchRequest setResultType:NSDictionaryResultType];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:en inManagedObjectContext: self.managedObjectContext]];
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        return [r objectAtIndex:0];
    }
    
    return nil;
}

- (NSDate *) lastSecondInMonthWithOffset:(int)offset {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                    | NSCalendarUnitMonth
                                    | NSCalendarUnitDay
                                    | NSCalendarUnitHour
                                    | NSCalendarUnitMinute
                                    | NSCalendarUnitSecond fromDate:[NSDate date]];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    [components setDay:1];
    NSDate *date = [calendar dateFromComponents:components];
    
    components = [[NSDateComponents alloc] init];
    [components setMonth:1+offset];
    date = [calendar dateByAddingComponents:components toDate:date options:0];
    
    components = [[NSDateComponents alloc] init];
    [components setSecond:-1];
    date = [calendar dateByAddingComponents:components toDate:date options:0];
    
    return date;
}

#pragma mark Locations
-(_SALocation*) fetchLocationById:(int)location_id {
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"location_id = %i", location_id] entityName:@"SALocation"];
};

-(NSArray*) fetchVisibleLocations {
   return [self fetchByPredicate:[NSPredicate predicateWithFormat:@"visible > 0"] entityName:@"SALocation" limit:0 sortDescriptors:nil];
}

-(_SALocation*) newLocation {

    _SALocation *Location = [[_SALocation alloc] initWithEntity:[NSEntityDescription entityForName:@"SALocation" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    Location.location_id = [NSNumber numberWithInt:0];
    Location.caption = @"";
    [Location setLocationVisible:0];
    [self.managedObjectContext insertObject:Location];
   
    
    return Location;
}

-(BOOL) updateLocation:(TSC_SuplaLocation *)location {
    
    BOOL save = NO;
    
    _SALocation *Location = [self fetchLocationById:location->Id];
    if ( Location == nil ) {
        Location = [self newLocation];
        Location.location_id = [NSNumber numberWithInt:location->Id];
        save = YES;
    }
    
    if ( [Location setLocationCaption:location->Caption] ) {
        save = YES;
    }
    
    if ( [Location setLocationVisible:1] ) {
        save = YES;
    }
    
    if ( save == YES ) {
        [self saveContext];
    }
    
    return save;
}

#pragma mark Channels

-(SAChannel*) fetchChannelById:(int)channel_id {
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"remote_id = %i AND profile.isActive = true", channel_id] entityName:@"SAChannel"];
};

-(SAChannelValue*) fetchChannelValueByChannelId:(int)channel_id {
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i AND profile.isActive = true", channel_id] entityName:@"SAChannelValue"];
};

-(SAChannelExtendedValue*) fetchChannelExtendedValueByChannelId:(int)channel_id {
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i AND profile.isActive = true", channel_id] entityName:@"SAChannelExtendedValue"];
};

-(SAChannel*) newChannel {
    
    SAChannel *Channel = [[SAChannel alloc] initWithEntity:[NSEntityDescription entityForName:@"SAChannel" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    [Channel initWithRemoteId:0];
    Channel.profile = self.currentProfile;
    [self.managedObjectContext insertObject:Channel];
    
    return Channel;
}

-(SAChannelValue*) newChannelValueForChannelId:(int)channel_id {
    
    SAChannelValue *Value = [[SAChannelValue alloc] initWithEntity:[NSEntityDescription entityForName:@"SAChannelValue" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    [Value initWithChannelId:channel_id];
    [self.managedObjectContext insertObject:Value];
    
    return Value;
}

-(SAChannelExtendedValue*) newChannelExtendedValueForChannelId:(int)channel_id {
    
    SAChannelExtendedValue *Value = [[SAChannelExtendedValue alloc]
                                     initWithEntity:[NSEntityDescription entityForName:@"SAChannelExtendedValue"
                                                                inManagedObjectContext:self.managedObjectContext]
                                     insertIntoManagedObjectContext:self.managedObjectContext];
    
    [Value initWithChannelId:channel_id];
    [self.managedObjectContext insertObject:Value];
    
    return Value;
}

-(BOOL) updateChannel:(TSC_SuplaChannel_D *)channel {
    
    BOOL save = NO;
    
    _SALocation *Location = [self fetchLocationById:channel->LocationID];
    
    if ( Location == nil )
        return NO;
    
    SAChannel *Channel = [self fetchChannelById:channel->Id];
    
    if ( Channel == nil ) {
        
        Channel = [self newChannel];
        Channel.remote_id = channel->Id;
        save = YES;
    }
    

    if ( [Channel setChannelLocation:Location] ) {
        save = YES;
    }

    if ( [Channel setChannelFunction:channel->Func] ) {
        save = YES;
    }
    
    if ( [Channel setChannelCaption:channel->Caption] ) {
        save = YES;
    }
    
    if ( [Channel setItemVisible:1] ) {
        save = YES;
    }
    
    if ( [Channel setChannelAltIcon:channel->AltIcon] ) {
        save = YES;
    }
    
    if ( [Channel setLocationId:channel->LocationID] ) {
        save = YES;
    }
    
    if ( [Channel setRemoteId:channel->Id] ) {
        save = YES;
    }
    
    if ( [Channel setUserIconId:channel->UserIcon] ) {
        save = YES;
    }
    
    if ( [Channel setChannelProtocolVersion:channel->ProtocolVersion] ) {
        save = YES;
    }
    
    if ( [Channel setDeviceId:channel->DeviceID] ) {
        save = YES;
    }
    
    if ( [Channel setManufacturerId:channel->ManufacturerID] ) {
        save = YES;
    }
    
    if ( [Channel setProductId:channel->ProductID] ) {
        save = YES;
    }
    
    if ( [Channel setChannelType:channel->Type] ) {
        save = YES;
    }
    
    if ( [Channel setChannelFlags:channel->Flags] ) {
        save = YES;
    }
    
    if ( save ) {
        [self saveContext];
    }
    
    return save;
}

-(BOOL) updateChannelValue:(TSC_SuplaChannelValue_B *)channel_value {
 
    BOOL save = NO;

    SAChannelValue *Value= [self fetchChannelValueByChannelId:channel_value->Id];
    
    if ( Value == nil ) {
        
        Value = [self newChannelValueForChannelId:channel_value->Id];
        save = YES;
    }
    
    if ( [Value setValueWithChannelValue:&channel_value->value] ) {
         save = YES;
    }
    
    if ( [Value setOnlineState:channel_value->online]) {
        save = YES;
    }

    NSArray *r = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"remote_id = %i AND (value = nil OR value <> %@)", channel_value->Id, Value] entityName:@"SAChannel" limit:0];
    
    if ( r != nil ) {
        for(int a=0;a<r.count;a++) {
            ((SAChannel*)[r objectAtIndex:a]).value = Value;
            save = YES;
        }
    }
    
    r = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i AND (value = nil OR value <> %@)", channel_value->Id, Value] entityName:@"SAChannelGroupRelation" limit:0];
    
    if ( r != nil ) {
        for(int a=0;a<r.count;a++) {
            ((SAChannelGroupRelation*)[r objectAtIndex:a]).value = Value;
            save = YES;
        }
    }
    
    if ( save ) {
        [self saveContext];
    }
    
    return save;
}

-(BOOL) updateChannelExtendedValue:(TSC_SuplaChannelExtendedValue *)channel_value {
    
    BOOL save = NO;
    
    SAChannelExtendedValue *Value= [self fetchChannelExtendedValueByChannelId:channel_value->Id];
    
    if ( Value == nil ) {
        Value = [self newChannelExtendedValueForChannelId:channel_value->Id];
        save = YES;
    }
    
    if ( [Value setValueWithChannelExtendedValue:&channel_value->value] ) {
        save = YES;
    }
    
    NSArray *r = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"remote_id = %i AND (ev = nil OR ev <> %@)", channel_value->Id, Value] entityName:@"SAChannel" limit:0];
    
    if ( r != nil ) {
        for(int a=0;a<r.count;a++) {
            ((SAChannel*)[r objectAtIndex:a]).ev = Value;
            save = YES;
        }
    }
    
    if ( save ) {
        [self saveContext];
    }
    
    return save;
}

-(NSFetchRequest*) getChannelBaseFetchRequestForEntityName:(NSString*)entity locationId:(int)locationId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"func > 0 AND visible > 0 AND (%i = 0 OR location.location_id = %i)", locationId, locationId];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext: self.managedObjectContext]];
    
    SEL localeAwareCompare = @selector(localizedCaseInsensitiveCompare:);
    NSArray *sortDescriptors = @[
								 [[NSSortDescriptor alloc] initWithKey:@"location.sortOrder" ascending:YES],
								 [[NSSortDescriptor alloc] initWithKey:@"location.caption" ascending:YES
															  selector: localeAwareCompare],
                                [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES],
                                [[NSSortDescriptor alloc] initWithKey:@"func" ascending:NO],
                                [[NSSortDescriptor alloc] initWithKey:@"caption" ascending:NO
								selector: localeAwareCompare]
                                ];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return fetchRequest;
}

-(NSFetchedResultsController*) getChannelBaseFrcForEntityName:(NSString*)entity {
    NSFetchRequest *fetchRequest = [self getChannelBaseFetchRequestForEntityName:entity locationId:0];

    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"location.sortOrderCaption" cacheName:nil];
    NSError *error;
    [frc performFetch:&error];
    if ( error ) {
        NSLog(@"%@", error);
    }
    
    return frc;
}

-(NSFetchedResultsController*) getChannelFrc {
    return [self getChannelBaseFrcForEntityName:@"SAChannel"];
}

-(BOOL) setChannelsOffline {
    // TODO: rewrite

         BOOL save = NO;
        /*
    NSArray *r = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"online = YES"] entityName:@"SAChannel" limit:0];

    
    if ( r != nil ) {
        for(int a=0;a<r.count;a++) {
            if ( [[r objectAtIndex:a] setChannelOnline:0] ) {
                save = YES;
            }
        }
    }
    
    if ( save ) {
        [self saveContext];
    }
         */
    
    return save;
}

-(BOOL) setAllItemsVisible:(int)visible whereVisibilityIs:(int)wvi entityName:(NSString*)ename {
    
    NSArray *r = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"visible = %i", wvi] entityName:ename limit:0];
    BOOL save = NO;
    
    if ( r != nil ) {
        for(int a=0;a<r.count;a++) {
            if ( [[r objectAtIndex:a] setItemVisible:visible] ) {
                save = YES;
            }
        }
    }
    
    if ( save ) {
        [self saveContext];
    }
    
    return save;
    
}

-(BOOL) setAllOfChannelVisible:(int)visible whereVisibilityIs:(int)wvi {
    return [self setAllItemsVisible:visible whereVisibilityIs:wvi entityName:@"SAChannel"];
}

-(NSUInteger) getChannelCount {
    return [self getCountByPredicate:[NSPredicate predicateWithFormat:@"func > 0 AND visible > 0"] entityName:@"SAChannel"];
}

#pragma mark Channel Groups

-(BOOL) setAllOfChannelGroupVisible:(int)visible whereVisibilityIs:(int)wvi {
    return [self setAllItemsVisible:visible whereVisibilityIs:wvi entityName:@"SAChannelGroup"];
}

-(BOOL) setAllOfChannelGroupRelationVisible:(int)visible whereVisibilityIs:(int)wvi {
    return [self setAllItemsVisible:visible whereVisibilityIs:wvi entityName:@"SAChannelGroupRelation"];
}

-(SAChannelGroup*) fetchChannelGroupById:(int)remote_id {
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"remote_id = %i", remote_id] entityName:@"SAChannelGroup"];
};

-(SAChannelGroup*) newChannelGroup {
    
    SAChannelGroup *CGroup = [[SAChannelGroup alloc] initWithEntity:[NSEntityDescription entityForName:@"SAChannelGroup" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    CGroup.caption = @"";
    CGroup.remote_id = 0;
    CGroup.func = 0;
    CGroup.visible = 1;
    CGroup.alticon = 0;
    CGroup.flags = 0;
    CGroup.online = 0;
    CGroup.total_value = nil;
    
    [self.managedObjectContext insertObject:CGroup];
    
    return CGroup;
}

-(BOOL) updateChannelGroup:(TSC_SuplaChannelGroup_B *)channel_group {
    
    BOOL save = NO;
    
    _SALocation *Location = [self fetchLocationById:channel_group->LocationID];
    
    if ( Location == nil )
        return NO;
    
    SAChannelGroup *CGroup = [self fetchChannelGroupById:channel_group->Id];
    
    if ( CGroup == nil ) {
        CGroup = [self newChannelGroup];
        CGroup.remote_id = channel_group->Id;
        save = YES;
    }
    
    
    if ( [CGroup setChannelLocation:Location] ) {
        save = YES;
    }
    
    if ( [CGroup setChannelFunction:channel_group->Func] ) {
        save = YES;
    }
    
    if ( [CGroup setChannelCaption:channel_group->Caption] ) {
        save = YES;
    }
    
    if ( [CGroup setItemVisible:1] ) {
        save = YES;
    }
    
    if ( [CGroup setChannelAltIcon:channel_group->AltIcon] ) {
        save = YES;
    }
    
    if ( [CGroup setLocationId:channel_group->LocationID] ) {
        save = YES;
    }
    
    if ( [CGroup setRemoteId:channel_group->Id] ) {
        save = YES;
    }
    
    if ( [CGroup setUserIconId:channel_group->UserIcon] ) {
        save = YES;
    }
    
    if ( [CGroup setChannelFlags:channel_group->Flags] ) {
        save = YES;
    }
    
    if ( save ) {
        [self saveContext];
    }
    
    return save;
}

-(SAChannelGroupRelation*) newChannelGroupRelation {
    
    SAChannelGroupRelation *CGroupRel = [[SAChannelGroupRelation alloc] initWithEntity:[NSEntityDescription entityForName:@"SAChannelGroupRelation" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    CGroupRel.group_id = 0;
    CGroupRel.channel_id = 0;
    
    [self.managedObjectContext insertObject:CGroupRel];
    
    return CGroupRel;
}

-(BOOL) updateChannelGroupRelation:(TSC_SuplaChannelGroupRelation *)cgroup_relation {
    
    BOOL save = NO;
    
    SAChannelGroupRelation *CGroupRel = [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"group_id = %i AND channel_id = %i", cgroup_relation->ChannelGroupID, cgroup_relation->ChannelID] entityName:@"SAChannelGroupRelation"];
    
    if ( CGroupRel == nil ) {
        CGroupRel = [self newChannelGroupRelation];
        CGroupRel.group_id = cgroup_relation->ChannelGroupID;
        CGroupRel.channel_id = cgroup_relation->ChannelID;
        save = YES;
    }

    if ( [CGroupRel setItemVisible:1] ) {
        save = YES;
    }
    
    if ( CGroupRel.value != nil && CGroupRel.value.channel_id != CGroupRel.channel_id ) {
        CGroupRel.value = nil;
        save = YES;
    }
    
    if ( CGroupRel.group != nil && CGroupRel.group.remote_id != CGroupRel.group_id ) {
        CGroupRel.group = nil;
        save = YES;
    }
    
    if ( CGroupRel.value == nil ) {
        CGroupRel.value = [self fetchChannelValueByChannelId:CGroupRel.channel_id];
        if ( CGroupRel.value != nil ) {
            save = YES;
        }
    }
    
    if ( CGroupRel.group == nil ) {
        CGroupRel.group = [self fetchChannelGroupById:CGroupRel.group_id];
        if ( CGroupRel.group != nil ) {
            save = YES;
        }
    }
    
    if ( save ) {
        [self saveContext];
    }
    
    return save;
}

- (NSArray*) updateChannelGroups {
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"visible > 0 AND group <> %@ AND value <> %@ AND group.visible > 0", nil, nil];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"SAChannelGroupRelation" inManagedObjectContext: self.managedObjectContext]];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"group_id" ascending:YES],nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSError *error;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error ) {
        NSLog(@"%@", error);
    } else if ( r.count == 0 ) {
        return nil;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    SAChannelGroup *cgroup = nil;
    BOOL save = NO;
    
    for(int a=0;a<r.count;a++) {
        SAChannelGroupRelation *cg_rel = [r objectAtIndex:a];
        if (cgroup == nil) {
            cgroup = cg_rel.group;
            [cgroup resetBuffer];
        }
        
        if (cgroup.remote_id == cg_rel.group_id) {
            [cgroup addValueToBuffer:cg_rel.value];
        }
        
        if (a<r.count-1) {
            cg_rel = [r objectAtIndex:a+1];
        }
        
        if (a==r.count-1 || cg_rel.group_id != cgroup.remote_id) {
            if ([cgroup diffWithBuffer]) {
                [cgroup assignBuffer];
                [result addObject: [NSNumber numberWithInteger:cgroup.remote_id]];
                save = YES;
            }
            cgroup = nil;
        }
    }
    
    if ( save ) {
        [self saveContext];
    }
    
    return result;
}

-(NSFetchedResultsController*) getChannelGroupFrc {
    return [self getChannelBaseFrcForEntityName:@"SAChannelGroup"];
}

#pragma mark Color List

-(SAColorListItem *) getColorListItemForRemoteId:(int)remote_id andIndex:(int)idx forGroup:(BOOL)group {
 
    SAColorListItem *item = [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"remote_id = %i AND group = %@ AND idx = %i", remote_id, [NSNumber numberWithBool:group], idx] entityName:@"SAColorListItem"];
    
    if ( item == nil ) {
        
        item = [[SAColorListItem alloc] initWithEntity:[NSEntityDescription entityForName:@"SAColorListItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
        item.remote_id = remote_id;
        item.group = group;
        item.idx = [NSNumber numberWithInt:idx];
        
        [self.managedObjectContext insertObject:item];
        [self saveContext];
    }
    
    return item;
}

-(void) updateColorListItem:(SAColorListItem *)item {
    
    [self saveContext];
}

#pragma mark Measurements - Common

-(NSArray *) getMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo entityName:(NSString*)entityName {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
 
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"channel_id = %i AND (%@ = nil OR date >= %@) AND (%@ = nil OR date <= %@)", channel_id, dateFrom, dateFrom, dateTo, dateTo];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        return r;
    }
    
    return nil;
}

-(long) getTimestampOfMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min entityName:(NSString*)en {
    SAIncrementalMeasurementItem *item = [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i", channel_id] entityName: en sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:min]]];
    
    return item ? [item.date timeIntervalSince1970] : 0;
}

-(void) deleteAllMeasurementsForChannelId:(int)channel_id entityName:(NSString *)en {
    BOOL del = YES;
    do {
        del = NO;
        NSArray *arr = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i", channel_id] entityName:en limit:1000];
        
        if (arr && arr.count) {
            del = YES;
            for(int a=0;a<arr.count;a++) {
                [self.managedObjectContext deleteObject:[arr objectAtIndex:a]];
            }
            [self saveContext];
        }
        
    } while (del);
    
}

-(NSUInteger) getIncrementalMeasurementItemCountWithoutComplementForChannelId:(int)channel_id entityName:(NSString *)en {
    return [self getCountByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i AND complement = NO", channel_id] entityName:en];
}

-(BOOL) timestampStartsWithTheCurrentMonth:(long)timestamp {
    if (timestamp == 0) {
        return YES;
    };
    
    NSDateComponents *dc1 = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
    
    NSDateComponents *dc2 = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    return dc1.month == dc2.month && dc1.year == dc2.year;
}

- (void) addGroupByProperty:(GroupBy)gb toMutableArray:(NSMutableArray*)props entity:(NSEntityDescription *)entity {
    switch (gb) {
        case gbMinute:
            [props addObject:[entity.propertiesByName objectForKey:@"minute"]];
            break;
        case gbHour:
            [props addObject:[entity.propertiesByName objectForKey:@"hour"]];
            break;
        case gbDay:
            [props addObject:[entity.propertiesByName objectForKey:@"day"]];
            break;
        case gbWeekday:
            [props addObject:[entity.propertiesByName objectForKey:@"weekday"]];
            break;
        case gbMonth:
            [props addObject:[entity.propertiesByName objectForKey:@"month"]];
            break;
        case gbYear:
            [props addObject:[entity.propertiesByName objectForKey:@"year"]];
            break;
        default:
            break;
    }
}

-(NSArray *) getIncrementalMeasurementsForChannelId:(int)channel_id fields:(NSArray*)fields entityName:(NSString*)en dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo  groupBy:(GroupBy)gb groupingDepth:(GroupingDepth)gd {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:en inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSMutableArray *propertiesToFetch = [[NSMutableArray alloc] init];
    
    NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
    [ed setName:@"date"];
    [ed setExpression:[NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"date"]]]];
    [ed setExpressionResultType:NSDateAttributeType];
    
    [propertiesToFetch addObject:ed];
    
    for(int a=0;a<fields.count;a++) {
        ed = [[NSExpressionDescription alloc] init];
        [ed setName:[fields objectAtIndex:a]];
        [ed setExpression:[NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:[fields objectAtIndex:a]]]]];
        [ed setExpressionResultType:NSDoubleAttributeType];
        [propertiesToFetch addObject:ed];
    }
    
    fetchRequest.propertiesToFetch = propertiesToFetch;
    NSMutableArray *propertiesToGroupBy = [[NSMutableArray alloc] init];
    
    if (gd != gdNone) {
        switch (gd) {
            case gdMinutes:
                [self addGroupByProperty:gbMinute toMutableArray:propertiesToGroupBy entity:entity];
            case gdHours:
                [self addGroupByProperty:gbHour toMutableArray:propertiesToGroupBy entity:entity];
            case gdDays:
                [self addGroupByProperty:gbDay toMutableArray:propertiesToGroupBy entity:entity];
            case gdMonths:
                [self addGroupByProperty:gbMonth toMutableArray:propertiesToGroupBy entity:entity];
            case gdYears:
                [self addGroupByProperty:gbYear toMutableArray:propertiesToGroupBy entity:entity];
                break;
            default:
                break;
        }
    } else if (gb != gbNone) {
        [self addGroupByProperty:gb toMutableArray:propertiesToGroupBy entity:entity];
    }

    fetchRequest.propertiesToGroupBy = propertiesToGroupBy.count ? propertiesToGroupBy : nil;
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"channel_id = %i AND (%@ = nil OR date >= %@) AND (%@ = nil OR date <= %@)", channel_id, dateFrom, dateFrom, dateTo, dateTo];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        return r;
    }
    
    return nil;
    
}

#pragma mark Electricity Measurements

-(SAElectricityMeasurementItem*) newElectricityMeasurementItemWithManagedObjectContext:(BOOL)moc {
    SAElectricityMeasurementItem *item = [[SAElectricityMeasurementItem alloc] initWithEntity:[NSEntityDescription entityForName:@"SAElectricityMeasurementItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:moc ? self.managedObjectContext : nil];
    
    if (moc) {
        [self.managedObjectContext insertObject:item];
    }
    return item;
}

-(long) getTimestampOfElectricityMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min {
    return [self getTimestampOfMeasurementItemWithChannelId:channel_id minimum:min entityName:@"SAElectricityMeasurementItem"];
}

-(void) deleteAllElectricityMeasurementsForChannelId:(int)channel_id {
    [self deleteAllMeasurementsForChannelId:channel_id entityName:@"SAElectricityMeasurementItem"];
}

-(NSUInteger) getElectricityMeasurementItemCountWithoutComplementForChannelId:(int)channel_id {
    return [self getIncrementalMeasurementItemCountWithoutComplementForChannelId:channel_id entityName:@"SAElectricityMeasurementItem"];
}


-(BOOL) electricityMeterMeasurementsStartsWithTheCurrentMonthForChannelId:(int)channel_id {
    long ts = [self getTimestampOfElectricityMeasurementItemWithChannelId:channel_id minimum:YES];
    return [self timestampStartsWithTheCurrentMonth:ts];
}

- (double) sumActiveEnergyForChannelId:(int)channel_id monthLimitOffset:(int) offset forwarded:(BOOL)fwd {
    
    double result = 0;
    int a;
    
    NSString *field = fwd ? @"fae" : @"rae";
    NSMutableArray *props = [[NSMutableArray alloc] init];
    for(a=1;a<=3;a++) {
        NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
        [ed setName:[NSString stringWithFormat:@"%@%i", field, a]];
        [ed setExpression:[NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:[NSString stringWithFormat:@"phase%i_%@", a, field]]]]];
        [ed setExpressionResultType:NSDoubleAttributeType];
        [props addObject:ed];
    }
    

    NSDate *date = [self lastSecondInMonthWithOffset: offset];
    NSPredicate *predicte = [NSPredicate predicateWithFormat:@"channel_id = %i AND date <= %@", channel_id, date];
    NSDictionary *sum = [self sumValesOfEntitiesWithProperties:props predicate:predicte entityName:@"SAElectricityMeasurementItem"];
    
    if (sum && sum.count == 3) {
        for(a=1;a<=3;a++) {
            result += [[sum objectForKey:[NSString stringWithFormat:@"%@%i", field, a]] doubleValue];
        }
    }
    
    return result;
}

-(NSArray *) getElectricityMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo groupBy:(GroupBy)gb groupingDepth:(GroupingDepth)gd fields:(NSArray*)fields {
    return [self getIncrementalMeasurementsForChannelId:channel_id fields:fields entityName:@"SAElectricityMeasurementItem" dateFrom:dateFrom dateTo:dateTo groupBy:gb groupingDepth:gd];
}

#pragma mark Impulse Counter Measurements

-(SAImpulseCounterMeasurementItem*) newImpulseCounterMeasurementItemWithManagedObjectContext:(BOOL)moc {
    SAImpulseCounterMeasurementItem *item = [[SAImpulseCounterMeasurementItem alloc] initWithEntity:[NSEntityDescription entityForName:@"SAImpulseCounterMeasurementItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:moc ? self.managedObjectContext : nil];
    
    if (moc) {
        [self.managedObjectContext insertObject:item];
    }
    return item;
}

-(long) getTimestampOfImpulseCounterMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min {
    return [self getTimestampOfMeasurementItemWithChannelId:channel_id minimum:min entityName:@"SAImpulseCounterMeasurementItem"];
}

-(void) deleteAllImpulseCounterMeasurementsForChannelId:(int)channel_id {
    [self deleteAllMeasurementsForChannelId:channel_id entityName:@"SAImpulseCounterMeasurementItem"];
}

-(NSUInteger) getImpulseCounterMeasurementItemCountWithoutComplementForChannelId:(int)channel_id {
    return [self getIncrementalMeasurementItemCountWithoutComplementForChannelId:channel_id entityName:@"SAImpulseCounterMeasurementItem"];
}

-(BOOL) impulseCounterMeasurementsStartsWithTheCurrentMonthForChannelId:(int)channel_id {
    long ts = [self getTimestampOfImpulseCounterMeasurementItemWithChannelId:channel_id minimum:YES];
    return [self timestampStartsWithTheCurrentMonth:ts];
}

- (double) calculatedValueSumForChannelId:(int)channel_id monthLimitOffset:(int)offset {
    
    double result = 0;

    NSMutableArray *props = [[NSMutableArray alloc] init];
    NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
    [ed setName:@"calculated_value"];
    [ed setExpression:[NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"calculated_value"]]]];
    [ed setExpressionResultType:NSDoubleAttributeType];
    [props addObject:ed];

    NSDate *date = [self lastSecondInMonthWithOffset: offset];
    NSPredicate *predicte = [NSPredicate predicateWithFormat:@"channel_id = %i AND date <= %@", channel_id, date];
    NSDictionary *sum = [self sumValesOfEntitiesWithProperties:props predicate:predicte entityName:@"SAImpulseCounterMeasurementItem"];
    
    if (sum && sum.count == 1) {
        result = [[sum objectForKey:@"calculated_value"] doubleValue];
    }
    
    return result;
}

-(NSArray *) getImpulseCounterMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo groupBy:(GroupBy)gb groupingDepth:(GroupingDepth)gd {
    return [self getIncrementalMeasurementsForChannelId:channel_id fields:@[@"calculated_value"] entityName:@"SAImpulseCounterMeasurementItem" dateFrom:dateFrom dateTo:dateTo groupBy:gb groupingDepth:gd];
}

#pragma mark Thermometer Measurements

-(SATemperatureMeasurementItem*) newTemperatureMeasurementItem {
    SATemperatureMeasurementItem *item = [[SATemperatureMeasurementItem alloc] initWithEntity:[NSEntityDescription entityForName:@"SATemperatureMeasurementItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    [self.managedObjectContext insertObject:item];
    return item;
}

-(long) getTimestampOfTemperatureMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min {
    return [self getTimestampOfMeasurementItemWithChannelId:channel_id minimum:min entityName:@"SATemperatureMeasurementItem"];
}

-(NSUInteger) getTemperatureMeasurementItemCountForChannelId:(int)channel_id {
    return [self getCountByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i", channel_id] entityName:@"SATemperatureMeasurementItem"];
}

-(void) deleteAllTemperatureMeasurementsForChannelId:(int)channel_id {
    [self deleteAllMeasurementsForChannelId:channel_id entityName:@"SATemperatureMeasurementItem"];
}

-(NSArray *) getTemperatureMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo {
    return [self getMeasurementsForChannelId:channel_id dateFrom:dateFrom dateTo:dateTo entityName:@"SATemperatureMeasurementItem"];
}

#pragma mark Temperature and Humidity Measurements

-(SATempHumidityMeasurementItem*) newTempHumidityMeasurementItem {
    SATempHumidityMeasurementItem *item = [[SATempHumidityMeasurementItem alloc] initWithEntity:[NSEntityDescription entityForName:@"SATempHumidityMeasurementItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    [self.managedObjectContext insertObject:item];
    return item;
}

-(long) getTimestampOfTempHumidityMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min {
    return [self getTimestampOfMeasurementItemWithChannelId:channel_id minimum:min entityName:@"SATempHumidityMeasurementItem"];
}

-(NSUInteger) getTempHumidityMeasurementItemCountForChannelId:(int)channel_id {
    return [self getCountByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i", channel_id] entityName:@"SATempHumidityMeasurementItem"];
}

-(void) deleteAllTempHumidityMeasurementsForChannelId:(int)channel_id {
    [self deleteAllMeasurementsForChannelId:channel_id entityName:@"SATempHumidityMeasurementItem"];
}

-(NSArray *) getTempHumidityMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo {
    return [self getMeasurementsForChannelId:channel_id dateFrom:dateFrom dateTo:dateTo entityName:@"SATempHumidityMeasurementItem"];
}

#pragma mark Thermostat Measurements

-(SAThermostatMeasurementItem*) newThermostatMeasurementItem {
    SAThermostatMeasurementItem *item = [[SAThermostatMeasurementItem alloc] initWithEntity:[NSEntityDescription entityForName:@"SAThermostatMeasurementItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    [self.managedObjectContext insertObject:item];
    return item;
}

-(long) getTimestampOfThermostatMeasurementItemWithChannelId:(int)channel_id minimum:(BOOL)min {
    return [self getTimestampOfMeasurementItemWithChannelId:channel_id minimum:min entityName:@"SAThermostatMeasurementItem"];
}

-(NSUInteger) getThermostatMeasurementItemCountForChannelId:(int)channel_id {
    return [self getCountByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i", channel_id] entityName:@"SAThermostatMeasurementItem"];
}

-(void) deleteAllThermostatMeasurementsForChannelId:(int)channel_id {
    [self deleteAllMeasurementsForChannelId:channel_id entityName:@"SAThermostatMeasurementItem"];
}

-(NSArray *) getThermostatMeasurementsForChannelId:(int)channel_id dateFrom:(NSDate *)dateFrom dateTo:(NSDate *)dateTo {
    return [self getMeasurementsForChannelId:channel_id dateFrom:dateFrom dateTo:dateTo entityName:@"SAThermostatMeasurementItem"];
}

#pragma mark HomePlus groups

-(NSFetchedResultsController*) getHomePlusGroupFrcWithGroupId:(int)groupId {
    NSArray *r = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"group_id = %i AND visible > 0", groupId] entityName:@"SAChannelGroupRelation" limit:0];
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    if ( r != nil ) {
        for(int a=0;a<r.count;a++) {
            [ids addObject:[NSNumber numberWithInt:((SAChannelGroupRelation*)[r objectAtIndex:a]).channel_id]];
        }
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"func > 0 AND visible > 0 AND remote_id IN %@", ids];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"SAChannel" inManagedObjectContext: self.managedObjectContext]];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
                                [[NSSortDescriptor alloc] initWithKey:@"caption" ascending:NO],
                                nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error;
    [frc performFetch:&error];
    
    if ( error ) {
        NSLog(@"%@", error);
    }
    
    return frc;
}

#pragma mark User Icons

-(BOOL) updateChannelUserIconsWithEntityName:(NSString *)entityName {
    BOOL save = NO;
        
    NSArray *r = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"(usericon_id <> 0 AND usericon = nil) OR (usericon != nil AND usericon.remote_id != usericon_id)"] entityName:entityName limit:0];
    
    if ( r != nil ) {
        for(int a=0;a<r.count;a++) {
            SAChannelBase *c = (SAChannelBase*)[r objectAtIndex:a];
    
            if (c.usericon_id) {
                SAUserIcon *userIcon = [self fetchUserIconById:c.usericon_id createNewObject:NO];
                if (userIcon != c.usericon) {
                    c.usericon = userIcon;
                    save = YES;
                }
            } else if (c.usericon) {
                c.usericon = nil;
                save = YES;
            }
           
        }
    }
    
    if ( save ) {
        [self saveContext];
    }
    
    return save;
}

-(BOOL) updateChannelUserIcons {
    return [self updateChannelUserIconsWithEntityName:@"SAChannel"]
    || [self updateChannelUserIconsWithEntityName:@"SAChannelGroup"];
}

-(void) userIconsIdsWithEntity:(NSString*)en channelBase:(BOOL)cb idField:(NSString *)field exclude:(NSArray*)ex result:(NSMutableArray *)result {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:en inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    if (cb) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ > 0 AND func > 0 AND visible > 0", field]];
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ > 0", field]];
    }
    
    fetchRequest.propertiesToGroupBy = @[[entity.propertiesByName objectForKey:field]];
    fetchRequest.propertiesToFetch = fetchRequest.propertiesToGroupBy;
    
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        for(int a=0;a<r.count;a++) {
            id obj = [[r objectAtIndex:a] valueForKey:field];
            if ((ex == nil || NSNotFound == [ex indexOfObject:obj])
                && NSNotFound == [result indexOfObject:obj]) {
                [result addObject:obj];
            }
        }
    }
}

-(NSArray *) iconsToDownload {
    NSMutableArray *i = [[NSMutableArray alloc] init];
    [self userIconsIdsWithEntity:@"SAUserIcon" channelBase:NO idField:@"remote_id" exclude:nil result:i];
   
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self userIconsIdsWithEntity:@"SAChannel" channelBase:YES idField:@"usericon_id" exclude:i result:result];
    [self userIconsIdsWithEntity:@"SAChannelGroup" channelBase:YES idField:@"usericon_id" exclude:i result:result];
    
    return result;
}

-(SAUserIcon*) fetchUserIconById:(int)remote_id createNewObject:(BOOL)create {
    SAUserIcon *i = [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"remote_id = %i", remote_id] entityName:@"SAUserIcon"];
    
    if (i == nil && create) {
        i = [[SAUserIcon alloc] initWithEntity:[NSEntityDescription entityForName:@"SAUserIcon" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        i.remote_id = remote_id;
        [self.managedObjectContext insertObject:i];
    }
    
    return i;
}

-(void) deleteAllUserIcons {
 
    NSArray *arr;
    
    int a,b;
    for(b=0;b<2;b++) {
        arr = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"usericon != nil"] entityName:b == 0 ? @"SAChannel" : @"SAChannelGroup" limit:0];
        
        if (arr) {
            for(a=0;a<arr.count;a++) {
                ((SAChannelBase*)[arr objectAtIndex:a]).usericon = nil;
            }
        }
    }
    
    arr = [self fetchByPredicate:nil entityName:@"SAUserIcon" limit:0];
    if (arr) {
        for(a=0;a<arr.count;a++) {
            NSLog(@"Icon delete %@", [arr objectAtIndex:a]);
            [self.managedObjectContext deleteObject:[arr objectAtIndex:a]];
        }
    }
    
    [self saveContext];
}

-(NSArray*) zwaveBridgeChannelsWithLimit:(int)limit {
    return [self fetchByPredicate:
                  [NSPredicate predicateWithFormat:@"visible > 0 AND type = %i AND (flags & %i) > 0",
                   SUPLA_CHANNELTYPE_BRIDGE,
                   SUPLA_CHANNEL_FLAG_ZWAVE_BRIDGE] entityName:@"SAChannel" limit:limit];
}

-(BOOL) zwaveBridgeChannelAvailable {
    NSArray *r = [self zwaveBridgeChannelsWithLimit:1];
    return r && r.count == 1;
}

-(NSArray*) zwaveBridgeChannels {
    return [self zwaveBridgeChannelsWithLimit:0];
}

-(void)moveChannel:(SAChannelBase*)src toPositionOfChannel:(SAChannelBase*)dst entityName:(NSString*)entityName {
    if (src == nil
        || dst == nil
        || src.location == nil
        || src.location != dst.location) {
        return;
    }

    
    NSFetchRequest* fetchRequest =
    [self getChannelBaseFetchRequestForEntityName:entityName
                                       locationId:[src.location.location_id intValue]];

    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error != nil || r.count < 2 ) {
        return;
    }
    
    NSMutableArray *m = [NSMutableArray arrayWithArray:r];
    r = nil;
    
    NSUInteger srcIdx = [m indexOfObject:src];
    
    if (srcIdx == NSNotFound) {
        return;
    }
    
    NSUInteger dstIdx = [m indexOfObject:dst];
    
    if (dstIdx == NSNotFound) {
        return;
    }
    
    [m removeObjectAtIndex:srcIdx];
    [m insertObject:src atIndex:dstIdx];
    
    for(int a=0;a<m.count;a++) {
        ((SAChannelBase*)[m objectAtIndex:a]).position = a;
    }
    
    [self saveContext];
}

-(void) moveChannel:(SAChannelBase*)src toPositionOfChannel:(SAChannelBase*)dst {
    [self moveChannel:src toPositionOfChannel:dst entityName:@"SAChannel"];
}

-(void) moveChannelGroup:(SAChannelBase*)src toPositionOfChannelGroup:(SAChannelBase*)dst {
    [self moveChannel:src toPositionOfChannel:dst entityName:@"SAChannelGroup"];
}

- (void)deleteObject:(NSManagedObject *)object {
    [self.managedObjectContext deleteObject:object];
}

- (AuthProfileItem *)currentProfile {
    id<ProfileManager> pm = [[MultiAccountProfileManager alloc]
                             initWithContext: _managedObjectContext];
    return [pm getCurrentProfile];
}
@end

