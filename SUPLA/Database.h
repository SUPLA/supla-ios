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

#import "proto.h"

@class _SALocation;
@class SAChannel;
@class SAChannelValue;
@class SAColorListItem;
@interface SADatabase : NSObject

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
-(BOOL) updateChannel:(TSC_SuplaChannel_B *)channel;
-(BOOL) updateChannelValue:(TSC_SuplaChannelValue *)channel_value;
-(NSFetchedResultsController*) getChannelFrc;
-(BOOL) setChannelsOffline;
-(BOOL) setChannelsVisible:(int)visible WhereVisibilityIs:(int)wvi;
-(NSUInteger) getChannelCount;
-(SAColorListItem *) getColorListItemForRemoteId:(int)remote_id andIndex:(int)idx forGroup:(BOOL)group;
-(void) updateColorListItem:(SAColorListItem *)item;

@end


