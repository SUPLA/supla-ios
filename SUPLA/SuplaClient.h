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
#include "proto.h"

@interface SAVersionError : NSObject

@property (nonatomic)int version;
@property (nonatomic)int remoteMinVersion;
@property (nonatomic)int remoteVersion;

+ (SAVersionError*) VersionError:(int) version remoteMinVersion:(int) remote_version_min remoteVersion:(int) remote_version;

@end

@interface SARegResult : NSObject

@property (nonatomic)int ClientID;
@property (nonatomic)int LocationCount;
@property (nonatomic)int ChannelCount;


+ (SARegResult*) RegResultClientID:(int) clientID locationCount:(int) location_count channelCount:(int) channel_count;

@end

@interface SAEvent : NSObject

@property (nonatomic)BOOL Owner;
@property (nonatomic)int Event;
@property (nonatomic)int ChannelID;
@property (nonatomic)int DurationMS;
@property (nonatomic)int SenderID;
@property (nonatomic, copy)NSString *SenderName;

+ (SAEvent*) Event:(int) event ChannelID:(int) channel_id DurationMS:(int) duration_ms SenderID:(int) sender_id SenderName:(NSString*)sender_name;

@end

@interface SASuplaClient : NSThread

- (id)init;

- (void) onVersionError:(SAVersionError*)ve;
- (void) onConnected;
- (void) onConnError:(int)code;
- (void) onDisconnected;
- (void) onRegistering;
- (void) onRegistered:(SARegResult *)result;
- (void) onRegisterError:(int)code;
- (void) locationUpdate:(TSC_SuplaLocation *)location;
- (void) channelUpdate:(TSC_SuplaChannel_B *)channel;
- (void) channelValueUpdate:(TSC_SuplaChannelValue *)channel_value;
- (void) onEvent:(SAEvent *)event;

- (void) reconnect;
- (BOOL) isConnected;
- (BOOL) isRegistered;
- (void) channel:(int)ChannelID Open:(char)open;
- (BOOL) channel:(int)ChannelID setRGB:(UIColor*)color colorBrightness:(int)color_brightness brightness:(int)brightness;

@end
