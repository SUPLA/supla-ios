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

#import "SAChannelBasicCfg.h"

@implementation SAChannelBasicCfg

@synthesize deviceName = _deviceName;
@synthesize deviceSoftVer = _deviceSoftVer;
@synthesize deviceId = _deviceId;
@synthesize deviceFlags = _deviceFlags;
@synthesize manufacturerId = _manufacturerId;
@synthesize productId = _productId;
@synthesize channelId = _channelId;
@synthesize channelNumber = _channelNumber;
@synthesize channelType = _channelType;
@synthesize channelFunc = _channelFunc;
@synthesize channelFuncList = _channelFuncList;
@synthesize channelFlags = _channelFlags;
@synthesize channelCaption = _channelCaption;

- (id)initWithCfg:(TSC_ChannelBasicCfg *)cfg {
    if ((self = [super init]) && cfg) {
        _deviceName = [NSString stringWithUTF8String:cfg->DeviceName];
        _deviceSoftVer = [NSString stringWithUTF8String:cfg->DeviceSoftVer];
        _deviceId = cfg->DeviceID;
        _deviceFlags = cfg->DeviceFlags;
        _manufacturerId = cfg->ManufacturerID;
        _productId = cfg->ProductID;
        _channelId = cfg->ID;
        _channelNumber = cfg->Number;
        _channelType = cfg->Type;
        _channelFunc = cfg->Func;
        _channelFuncList = cfg->FuncList;
        _channelFlags = cfg->ChannelFlags;
        _channelCaption = [NSString stringWithUTF8String:cfg->Caption];
    }
    return self;
}

+ (SAChannelBasicCfg*)notificationToChannelBasicCfg:(NSNotification *)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"cfg"];
        if (r != nil && [r isKindOfClass:[SAChannelBasicCfg class]]) {
            return r;
        }
    }
    return nil;
}

@end
