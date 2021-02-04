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

#import "SASuperuserAuthorizationResult.h"

@implementation SASuperuserAuthorizationResult
@synthesize success = _success;
@synthesize code = _code;

- (id)initWithResult:(BOOL)success andCode:(int)code {
    if ([self init]) {
        _success = success;
        _code = code;
    }
    return self;
}

+ (SASuperuserAuthorizationResult*) superuserAuthorizationResult:(BOOL)success withCode:(int)code {
    return [[SASuperuserAuthorizationResult alloc] initWithResult:success andCode:code];
}

+ (SASuperuserAuthorizationResult *)notificationToAuthorizationResult:(NSNotification *)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"result"];
        if (r != nil && [r isKindOfClass:[SASuperuserAuthorizationResult class]]) {
            return r;
        }
    }
    return nil;
}
@end
