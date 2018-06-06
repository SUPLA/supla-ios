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

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[SAApp applicationDocumentsDirectory] URLByAppendingPathComponent:@"SUPLA_DB2.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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

-(NSArray *) fetchByPredicate:(NSPredicate *)predicate entityName:(NSString*)en limit:(int)l {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = predicate;
    
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

-(id) fetchItemByPredicate:(NSPredicate *)predicate entityName:(NSString*)en {
    
    NSArray *r = [self fetchByPredicate:predicate entityName:en limit:1];
    if ( r != nil && r.count > 0 ) {
        return [r objectAtIndex:0];
    }
    
    return nil;
};

#pragma mark Locations
-(_SALocation*) fetchLocationById:(int)location_id {
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"location_id = %i", location_id] entityName:@"SALocation"];
};

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
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"remote_id = %i", channel_id] entityName:@"SAChannel"];
};

-(SAChannelValue*) fetchChannelValueByChannelId:(int)channel_id {
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i", channel_id] entityName:@"SAChannelValue"];
};


-(SAChannel*) newChannel {
    
    SAChannel *Channel = [[SAChannel alloc] initWithEntity:[NSEntityDescription entityForName:@"SAChannel" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    Channel.caption = @"";
    Channel.remote_id = 0;
    Channel.func = 0;
    Channel.visible = 1;
    Channel.alticon = 0;
    Channel.protocolversion = 0;
    Channel.flags = 0;
    Channel.value = nil;

    [self.managedObjectContext insertObject:Channel];
    
    return Channel;
}

-(SAChannelValue*) newChannelValueForChannelId:(int)channel_id {
    
    SAChannelValue *Value = [[SAChannelValue alloc] initWithEntity:[NSEntityDescription entityForName:@"SAChannelValue" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    
    Value.channel_id = channel_id;
    Value.value = [[NSData alloc] init];
    Value.sub_value = [[NSData alloc] init];
    TSuplaChannelValue v;
    [Value setValueWithChannelValue:&v];
    
    [self.managedObjectContext insertObject:Value];
    
    return Value;
}

-(BOOL) updateChannel:(TSC_SuplaChannel_B *)channel {
    
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
    
    if ( [Channel setChannelProtocolVersion:channel->ProtocolVersion] ) {
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

-(BOOL) updateChannelValue:(TSC_SuplaChannelValue *)channel_value {
 
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
    
    if ( save ) {
        NSArray *r = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"remote_id = %i AND value <> %@", channel_value->Id, Value] entityName:@"SAChannel" limit:0];
        
        if ( r != nil ) {
            for(int a=0;a<r.count;a++) {
                ((SAChannel*)[r objectAtIndex:a]).value = Value;
            }
        }
        
        r = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"channel_id = %i AND value <> %@", channel_value->Id, Value] entityName:@"SAChannelGroupRelation" limit:0];
        
        if ( r != nil ) {
            for(int a=0;a<r.count;a++) {
                ((SAChannelGroupRelation*)[r objectAtIndex:a]).value = Value;
                NSLog(@"CGroup Rel value updated");
            }
        }
        
        [self saveContext];
    }
    
    return save;
}

-(NSFetchedResultsController*) getChannelBaseFrcForEntityName:(NSString*)entity {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"func > 0 AND visible > 0"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext: self.managedObjectContext]];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"location.caption" ascending:YES],
                                [[NSSortDescriptor alloc] initWithKey:@"func" ascending:NO],
                                [[NSSortDescriptor alloc] initWithKey:@"caption" ascending:NO],
                                nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"location.caption" cacheName:nil];
    
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"func > 0 AND visible > 0"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"SAChannel" inManagedObjectContext: self.managedObjectContext]];
    [fetchRequest setIncludesSubentities:NO];

    NSError *fetchError = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&fetchError];
    
    if(count == NSNotFound || fetchError != nil ) {
        count = 0;
    }
    
    return count;
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

-(BOOL) updateChannelGroup:(TSC_SuplaChannelGroup *)channel_group {
    
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

@end
