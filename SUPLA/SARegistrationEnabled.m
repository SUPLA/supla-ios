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

#import "SARegistrationEnabled.h"

@implementation SARegistrationEnabled
@synthesize ClientRegistrationExpirationDate;
@synthesize IODeviceRegistrationExpirationDate;

+ (SARegistrationEnabled*) ClientTimestamp:(unsigned int) client_timestamp IODeviceTimestamp:(unsigned int) iodevice_timestamp {
    SARegistrationEnabled *r = [[SARegistrationEnabled alloc] init];

    r.ClientRegistrationExpirationDate = client_timestamp == 0 ? nil : [NSDate dateWithTimeIntervalSince1970:client_timestamp];
    r.IODeviceRegistrationExpirationDate = iodevice_timestamp == 0 ? nil : [NSDate dateWithTimeIntervalSince1970:iodevice_timestamp];
    
    return r;
}

+ (SARegistrationEnabled *)notificationToRegistrationEnabled:(NSNotification *)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"reg_enabled"];
        if (r != nil && [r isKindOfClass:[SARegistrationEnabled class]]) {
            return r;
        }
    }
    return nil;
}

-(BOOL)isClientRegistrationEnabled {
   
    return ClientRegistrationExpirationDate != nil && [ClientRegistrationExpirationDate timeIntervalSince1970] >  [[NSDate date] timeIntervalSince1970];
}

-(BOOL)isIODeviceRegistrationEnabled {
    return IODeviceRegistrationExpirationDate != nil && [IODeviceRegistrationExpirationDate timeIntervalSince1970] >  [[NSDate date] timeIntervalSince1970];
}

@end
