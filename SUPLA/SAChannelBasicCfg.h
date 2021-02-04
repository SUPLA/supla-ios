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
#import "proto.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAChannelBasicCfg : NSObject

@property (nonatomic, readonly) NSString* deviceName;
@property (nonatomic, readonly) NSString* deviceSoftVer;
@property (nonatomic, readonly) int deviceId;
@property (nonatomic, readonly) int deviceFlags;
@property (nonatomic, readonly) int manufacturerId;
@property (nonatomic, readonly) int productId;
@property (nonatomic, readonly) int channelId;
@property (nonatomic, readonly) unsigned char channelNumber;
@property (nonatomic, readonly) int channelType;
@property (nonatomic, readonly) int channelFunc;
@property (nonatomic, readonly) int channelFuncList;
@property (nonatomic, readonly) int channelFlags;
@property (nonatomic, readonly) NSString* channelCaption;

- (id)initWithCfg:(TSC_ChannelBasicCfg *)cfg;
+ (SAChannelBasicCfg*)notificationToChannelBasicCfg:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
