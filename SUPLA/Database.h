/*
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
 
 Author: Przemyslaw Zygmunt p.zygmunt@acsoftware.pl [AC SOFTWARE]
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "proto.h"

@class SALocation;
@class SAChannel;
@interface SADatabase : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)initSaveObserver;
- (void)releaseSaveObserver;
- (void)saveContext;

-(SALocation*) fetchLocationById:(int)location_id;
-(SALocation*) newLocation;
-(BOOL) updateLocation:(TSC_SuplaLocation *)location;

-(SAChannel*) fetchChannelById:(int)channel_id;
-(BOOL) updateChannel:(TSC_SuplaChannel *)channel;
-(BOOL) updateChannelValue:(TSC_SuplaChannelValue *)channel_value;
-(NSFetchedResultsController*) getChannelFrc;
-(BOOL) setChannelsOffline;
-(BOOL) setChannelsVisible:(int)visible WhereVisibilityIs:(int)wvi;

@end


