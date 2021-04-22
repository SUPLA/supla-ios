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

#import "SACalCfgResult.h"

@implementation SACalCfgResult
@synthesize channelID = _channelID;
@synthesize command = _command;
@synthesize result = _result;
@synthesize data = _data;

- (id)initWithResult:(TSC_DeviceCalCfgResult *)result {
    if ([self init]) {
        _channelID = result->ChannelID;
        _command = result->Command;
        _result = result->Result;
        _data = nil;
        if (result->DataSize > 0) {
            _data = [NSData dataWithBytes:result->Data
                                   length:result->DataSize > sizeof(result->Data) ? sizeof(result->Data) : result->DataSize];
        }
    }
    return self;
}

+ (SACalCfgResult*) resultWithResult:(TSC_DeviceCalCfgResult *)result {
    return [[SACalCfgResult alloc] initWithResult:result];
}

+ (SACalCfgResult *)notificationToDeviceCalCfgResult:(NSNotification *)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"result"];
        if (r != nil && [r isKindOfClass:[SACalCfgResult class]]) {
            return r;
        }
    }
    return nil;
}

@end
