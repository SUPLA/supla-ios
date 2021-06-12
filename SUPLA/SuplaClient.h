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
#import "SAThermostatScheduleCfg.h"
#import "proto.h"

@class SASuplaClient;
@protocol SASuplaClientDelegate <NSObject>

@required
-(void) onSuplaClientTerminated: (SASuplaClient*)client;
@end

@interface SASuplaClient : NSThread
- (id)initWithOneTimePassword:(NSString*)oneTimePassword;
+ (NSString *)codeToString:(NSNumber*)code;
+ (NSString *)codeToString:(NSNumber*)code authDialog:(BOOL)authDialog;

- (void) reconnect;
- (BOOL) isConnected;
- (BOOL) isRegistered;
- (BOOL) cg:(int)ID setRGB:(UIColor*)color colorBrightness:(int)color_brightness brightness:(int)brightness group:(BOOL)group turnOnOff:(BOOL)turnOnOff;
- (void) cg:(int)ID Open:(char)open group:(BOOL)group;
- (void) channel:(int)ChannelID Open:(char)open;
- (BOOL) channel:(int)ChannelID setRGB:(UIColor*)color colorBrightness:(int)color_brightness brightness:(int)brightness;
- (void) group:(int)GroupID Open:(char)open;
- (BOOL) group:(int)GroupID setRGB:(UIColor*)color colorBrightness:(int)color_brightness brightness:(int)brightness;
- (void) deviceCalCfgRequest:(TCS_DeviceCalCfgRequest_B*)request;
- (void) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group data:(char*)data dataSize:(unsigned int)size;
- (void) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group;
- (void) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group charValue:(char)c;
- (void) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group shortValue:(short)s;
- (void) thermostatScheduleCfgRequest:(SAThermostatScheduleCfg *)cfg cg:(int)ID group:(BOOL)group;
- (void) getRegistrationEnabled;
- (int) getProtocolVersion;
- (BOOL) OAuthTokenRequest;
- (void) superuserAuthorizationRequestWithEmail:(NSString*)email andPassword:(NSString*)password;
- (void) channelStateRequestWithChannelId:(int)channelId;
- (void) setLightsourceLifespanWithChannelId:(int)channelId resetCounter:(BOOL)reset setTime:(BOOL)setTime lifespan:(unsigned short)lifespan;
- (void) setIODeviceRegistrationEnabledForTime:(int)iodevice_sec clientRegistrationEnabledForTime:(int)client_sec;
- (void) setDgfTransparencyMask:(short)mask activeBits:(short)active_bits channelId:(int)channelId;
- (void) getSuperuserAuthorizationResult;
- (BOOL) isSuperuserAuthorized;
- (void) getChannelBasicCfg:(int)channelId;
- (void) setChannelCaption:(int)channelId caption:(NSString*)caption;
- (void) setLocationCaption:(int)locationId caption:(NSString*)caption;
- (void) setFunction:(int)function forChannelId:(int)channelId;
- (void) zwaveGetAssignedNodeIdForChannelId:(int)channelId;
- (void) zwaveGetNodeListForDeviceId:(int)deviceId;
- (void) zwaveCfgModeIsStillActiveForDeviceId:(int)deviceId;
- (void) deviceCalCfgCancelAllCommandsWithDeviceId:(int)deviceId;
- (void) reconnectDeviceWithId:(int)deviceId;
- (void) zwaveResetAndClearSettingsWithDeviceId:(int)deviceId;
- (void) zwaveAddNodeToDeviceWithId:(int)deviceId;
- (void) zwaveRemoveNodeFromTheDeviceWithId:(int)deviceId;
- (void) zwaveAssignChannelId:(int)channelId toNodeId:(unsigned char)nodeId;
- (void) zwaveGetWakeUpSettingsForChannelId:(int)channelId;
- (void) zwaveSetWakeUpTime:(int)time forChannelId:(int)channelId;
- (BOOL) turnOn:(BOOL)on remoteId:(int)remoteId group:(BOOL)group channelFunc:(int)channelFunc vibrate:(BOOL)vibrate;

@property (nonatomic, weak) id<SASuplaClientDelegate> delegate;
@end
