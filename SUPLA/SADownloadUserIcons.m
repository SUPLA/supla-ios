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

#define PACKAGE_SIZE 4
#define START_DELAY 2.5

@implementation SADownloadUserIcons {
    BOOL _channelsUpdated;
}

- (NSData *) imageAtIndex:(int)idx data:(NSArray *)arr {
    if (arr.count > idx) {
        return [[NSData alloc] initWithBase64EncodedString:[arr objectAtIndex:idx] options:0];
    }
    return nil;
}

- (void)task {
    @synchronized(self) {
        _channelsUpdated = NO;
    }
    
    [NSThread sleepForTimeInterval:START_DELAY];
    
    NSArray *ids = [SAApp.DB iconsToDownload];
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
                    NSNumber *remote_id = nil;
                    
                    if (i != nil
                        && [i isKindOfClass: [NSDictionary class]]
                        && (images = [i valueForKey:@"images"]) != nil
                        && [images isKindOfClass:[NSArray class]]
                        && (remote_id = [i valueForKey:@"id"])
                        && [remote_id isKindOfClass:[NSNumber class]]) {
                    
                        SAUserIcon *userIcon = [self.DB fetchUserIconById:[remote_id intValue] createNewObject:YES];
                        if (userIcon != nil) {
                            userIcon.uimage1 = [self imageAtIndex:0 data:images];
                            userIcon.uimage2 = [self imageAtIndex:1 data:images];
                            userIcon.uimage3 = [self imageAtIndex:2 data:images];
                            userIcon.uimage4 = [self imageAtIndex:3 data:images];
                            
                            if (userIcon.uimage1 == nil
                                && userIcon.uimage2 == nil
                                && userIcon.uimage3 == nil
                                && userIcon.uimage4 == nil) {
                                [self.DB deleteObject:userIcon];
                            }

                            [self.DB saveContext];
                        }
                    }
                }
            }
            packageIds = @"";
        }
    }
    
    @synchronized(self) {
      _channelsUpdated = [self.DB updateChannelUserIcons];
    }
}

- (BOOL)channelsUpdated {
    BOOL result = NO;
    @synchronized(self) {
        result = _channelsUpdated;
    }
    return result;
}

@end
