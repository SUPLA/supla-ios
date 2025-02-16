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

#import "SADownloadUserIcons.h"
#import "SuplaApp.h"
#import "SAUserIcon+CoreDataClass.h"
#import "SUPLA-Swift.h"

#define PACKAGE_SIZE 4
#define START_DELAY 2.5

@implementation SADownloadUserIcons {
}

- (void)task {
    
    [NSThread sleepForTimeInterval:START_DELAY];
    
    NSArray *ids = [UseCaseLegacyWrapper getAllIconsToDownload];
    NSString *packageIds = @"";
    
    for(int a=0;a<ids.count;a++) {
        packageIds = [NSString stringWithFormat:@"%@%@%@",
                      packageIds,
                      packageIds.length > 0 ? @"," : @"", [ids objectAtIndex:a]];
        
        if (a%PACKAGE_SIZE == PACKAGE_SIZE-1
            || a == ids.count-1) {
            
            SAApiRequestResult *result = [self apiRequestForEndpoint:[NSString stringWithFormat:@"user-icons?include=images&ids=%@", packageIds]];
            
            if (result != nil
                && result.responseCode == 200
                && result.jsonObject != nil
                && [result.jsonObject isKindOfClass:[NSArray class]]) {
                NSArray *items = (NSArray*)result.jsonObject;
                
                for(int a=0;a<items.count;a++) {
                    NSDictionary *i = [items objectAtIndex:a];
                    NSArray *images = nil;
                    NSArray *darkImages = nil;
                    NSNumber *remote_id = nil;
                    
                    if (i != nil
                        && [i isKindOfClass: [NSDictionary class]]
                        && (images = [i valueForKey:@"images"]) != nil
                        && [images isKindOfClass:[NSArray class]]
                        && (remote_id = [i valueForKey:@"id"])
                        && [remote_id isKindOfClass:[NSNumber class]]) {
                        
                        if ([[i valueForKey:@"imagesDark"] isKindOfClass:[NSArray class]]) {
                            darkImages = [i valueForKey:@"imagesDark"];
                        }
                        
                        [UseCaseLegacyWrapper saveIconWithRemoteId:remote_id images: images darkImages: darkImages];
                    
                    }
                }
            }
            packageIds = @"";
        }
    }
    
    [UseCaseLegacyWrapper updateChannelIconsRelation];
    [UseCaseLegacyWrapper updateGroupIconsRelation];
    [UseCaseLegacyWrapper updateSceneIconsRelation];
}

@end
