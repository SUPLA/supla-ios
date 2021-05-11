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

#import "SAChannelCaptionSetResult.h"

@implementation SAChannelCaptionSetResult

@synthesize remoteId = _remoteId;
@synthesize resultCode = _resultCode;
@synthesize caption = _caption;

-(id)initWithResult:(TSC_SetCaptionResult *)result {
    if ([self init]) {
        if (result) {
            _remoteId = result->ID;
            _resultCode = result->ResultCode;
            _caption = [NSString stringWithUTF8String:result->Caption];
        }
    }
    return self;
}

+(SAChannelCaptionSetResult*) resultWithResult:(TSC_SetCaptionResult *)result {
    return [[SAChannelCaptionSetResult alloc] initWithResult:result];
}

+(SAChannelCaptionSetResult *)notificationToCaptionSetResult:(NSNotification *)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"result"];
        if (r != nil && [r isKindOfClass:[SAChannelCaptionSetResult class]]) {
            return r;
        }
    }
    return nil;
}
@end
