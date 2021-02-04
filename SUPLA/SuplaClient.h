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
#import "SARestApiClientTask.h"
#import "SAThermostatScheduleCfg.h"
#import "SAChannelStateExtendedValue.h"
#import "SAVersionError.h"
#import "SARegResult.h"
#import "SAEvent.h"
#import "SARegistrationEnabled.h"
#import "SASuperuserAuthorizationResult.h"
#import "SACalCfgResult.h"
#include "proto.h"

/*
@interface SAChannelBasicCfg : NSObject
@property (nonatomic, readonly) NSString *deviceName;
@property (nonatomic, readonly) NSString *deviceSoftVer;
@property (nonatomic, readonly)int deviceId;

- (id)initWithResult:(TSC_DeviceCalCfgResult *)result;
+ (SACalCfgResult*) resultWithResult:(TSC_DeviceCalCfgResult *)result;
@end
 */

@class SASuplaClient;
@protocol SASuplaClientDelegate <NSObject>

@required
-(void) onSuplaClientTerminated: (SASuplaClient*)client;
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
- (void) channelUpdate:(TSC_SuplaChannel_C *)channel;
- (void) channelValueUpdate:(TSC_SuplaChannelValue *)channel_value;
- (void) channelExtendedValueUpdate:(TSC_SuplaChannelExtendedValue *)channel_extendedvalue;
- (void) channelGroupUpdate:(TSC_SuplaChannelGroup_B *)cgroup;
- (void) channelGroupRelationUpdate:(TSC_SuplaChannelGroupRelation *)cgroup_relation;
- (void) onEvent:(SAEvent *)event;
- (void) onRegistrationEnabled:(SARegistrationEnabled*)reg_enabled;
- (void) onSetRegistrationEnabledResultCode:(int)code;
- (void) onOAuthTokenRequestResult:(SAOAuthToken *)token;
- (void) getSuperuserAuthorizationResult;
- (void) onSuperuserAuthorizationResult:(SASuperuserAuthorizationResult*)result;
- (void) onCalCfgResult:(SACalCfgResult*)result;
- (void) onChannelState:(SAChannelStateExtendedValue*)state;

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

@property (nonatomic, weak) id<SASuplaClientDelegate> delegate;
@end
