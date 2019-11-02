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

#import <UIKit/UIKit.h>
#import "SuplaClient.h"
#import "SuplaApp.h"
#import "Database.h"

#include "supla-client.h"

void sasuplaclient_on_versionerror(void *_suplaclient, void *user_data, int version, int remote_version_min, int remote_version) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onVersionError:[SAVersionError VersionError:version remoteMinVersion:remote_version_min remoteVersion:remote_version]];
}

void sasuplaclient_on_connected(void *_suplaclient, void *user_data) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onConnected];
}

void sasuplaclient_on_connerror(void *_suplaclient, void *user_data, int code) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onConnError:code];
    
}

void sasuplaclient_on_disconnected(void *_suplaclient, void *user_data) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onDisconnected];
    
}

void sasuplaclient_on_registering(void *_suplaclient, void *user_data) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onRegistering];
    
}

void sasuplaclient_on_registered(void *_suplaclient, void *user_data, TSC_SuplaRegisterClientResult_B *result) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onRegistered:[SARegResult RegResultClientID:result->ClientID locationCount:result->LocationCount channelCount:result->ChannelCount channelGroupCount:result->ChannelGroupCount flags:result->Flags version:result->version]];
    
}

void sasuplaclient_on_register_error(void *_suplaclient, void *user_data, int code) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onRegisterError:code];
    
}

void sasuplaclient_location_update(void *_suplaclient, void *user_data, TSC_SuplaLocation *location) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc locationUpdate:location];
}

void sasuplaclient_channel_update(void *_suplaclient, void *user_data, TSC_SuplaChannel_C *channel) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc channelUpdate: channel];
}

void sasuplaclient_channel_value_update(void *_suplaclient, void *user_data, TSC_SuplaChannelValue *channel_value) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc channelValueUpdate:channel_value];
}

void sasuplaclient_channel_extendedvalue_update(void *_suplaclient, void *user_data,
                                        TSC_SuplaChannelExtendedValue *channel_extendedvalue) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc channelExtendedValueUpdate:channel_extendedvalue];
}

void sasuplaclient_channelgroup_update(void *_suplaclient, void *user_data, TSC_SuplaChannelGroup_B *cgroup) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc channelGroupUpdate: cgroup];
}

void sasuplaclient_channelgroup_relation_update(void *_suplaclient, void *user_data, TSC_SuplaChannelGroupRelation *channelgroup_relation) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc channelGroupRelationUpdate: channelgroup_relation];
}

void sasuplaclient_on_event(void *_suplaclient, void *user_data, TSC_SuplaEvent *event) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onEvent: [SAEvent Event:event->Event ChannelID:event->ChannelID
                         DurationMS:event->DurationMS SenderID:event->SenderID SenderName:[NSString stringWithUTF8String:event->SenderName]]];
}

void sasuplaclient_on_registration_enabled(void *_suplaclient, void *user_data, TSDC_RegistrationEnabled *reg_enabled) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil && reg_enabled != NULL) {
        [sc onRegistrationEnabled:[SARegistrationEnabled ClientTimestamp:reg_enabled->client_timestamp IODeviceTimestamp:reg_enabled->iodevice_timestamp]];
    }
}

void sasuplaclient_on_oauth_token_request_result(void *_suplaclient, void *user_data, TSC_OAuthTokenRequestResult *result) {

    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil && result != NULL) {
        [sc onOAuthTokenRequestResult:[SAOAuthToken tokenWithRequestResult:result]];
    }
}

// ------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------

@implementation SAVersionError

@synthesize version;
@synthesize remoteMinVersion;
@synthesize remoteVersion;

+ (SAVersionError*) VersionError:(int) version remoteMinVersion:(int) remote_version_min remoteVersion:(int) remote_version {
    SAVersionError *ve = [[SAVersionError alloc] init];
    ve.version = version;
    ve.remoteMinVersion = remote_version_min;
    ve.remoteVersion = remote_version;
    
    return ve;
}

@end

// ------------------------------------------------------------------------------------------------------

@implementation SARegResult

@synthesize ClientID;
@synthesize LocationCount;
@synthesize ChannelCount;
@synthesize ChannelGroupCount;
@synthesize Flags;
@synthesize Version;

+ (SARegResult*) RegResultClientID:(int) clientID locationCount:(int) location_count channelCount:(int) channel_count channelGroupCount:(int) cgroup_count flags:(int) flags version:(int)version {
    SARegResult *rr = [[SARegResult alloc] init];
    
    rr.ClientID = clientID;
    rr.LocationCount = location_count;
    rr.ChannelCount = channel_count;
    rr.ChannelGroupCount = cgroup_count;
    rr.Flags = flags;
    rr.Version = version;
    
    return rr;
}

@end

// ------------------------------------------------------------------------------------------------------

@implementation SAEvent

@synthesize Owner;
@synthesize Event;
@synthesize ChannelID;
@synthesize DurationMS;
@synthesize SenderID;
@synthesize SenderName;

+ (SAEvent*) Event:(int) event ChannelID:(int) channel_id DurationMS:(int) duration_ms SenderID:(int) sender_id SenderName:(NSString*)sender_name {
    SAEvent *e = [[SAEvent alloc] init];
    
    e.Event = event;
    e.ChannelID = channel_id;
    e.DurationMS = duration_ms;
    e.SenderID = sender_id;
    e.SenderName = sender_name;
    
    return e;
}

@end


@implementation SARegistrationEnabled
@synthesize ClientRegistrationExpirationDate;
@synthesize IODeviceRegistrationExpirationDate;

+ (SARegistrationEnabled*) ClientTimestamp:(unsigned int) client_timestamp IODeviceTimestamp:(unsigned int) iodevice_timestamp {
    SARegistrationEnabled *r = [[SARegistrationEnabled alloc] init];

    r.ClientRegistrationExpirationDate = client_timestamp == 0 ? nil : [NSDate dateWithTimeIntervalSince1970:client_timestamp];
    r.IODeviceRegistrationExpirationDate = iodevice_timestamp == 0 ? nil : [NSDate dateWithTimeIntervalSince1970:iodevice_timestamp];
    
    return r;
}

-(BOOL)isClientRegistrationEnabled {
   
    return ClientRegistrationExpirationDate != nil && [ClientRegistrationExpirationDate timeIntervalSince1970] >  [[NSDate date] timeIntervalSince1970];
}

-(BOOL)isIODeviceRegistrationEnabled {
    return IODeviceRegistrationExpirationDate != nil && [IODeviceRegistrationExpirationDate timeIntervalSince1970] >  [[NSDate date] timeIntervalSince1970];
}

@end


// ------------------------------------------------------------------------------------------------------

@interface SASuplaClient () {
    void *_sclient;
    int _client_id;
    BOOL _connected;
    int _regTryCounter;
    int _tokenRequestTime;
}
@end

@implementation SASuplaClient {
    SADatabase *_DB;
}

- (id)init {
    self = [super init];
    _sclient = NULL;
    _regTryCounter = 0;
    
    return self;
}

-(SADatabase*)DB {
    if ( _DB == nil ) {
        _DB = [[SADatabase alloc] init];
    }
    
    return _DB;
}

- (char*) getServerHostName {
    
    NSString *host = [SAApp getServerHostName];
    if ( [host isEqualToString:@""] == YES && [SAApp getAdvancedConfig] == NO && ![[SAApp getEmailAddress] isEqualToString:@""] ) {
        
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://autodiscover.supla.org/users/%@", [SAApp getEmailAddress]]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
        
        [request setHTTPMethod: @"GET"];
        
        NSError *requestError = nil;
        NSURLResponse *urlResponse = nil;
        
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        
        if ( response != nil && requestError == nil ) {
            NSError *jsonError = nil;
           NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData: response options: NSJSONReadingMutableContainers error: &jsonError];

            if ( [jsonObj isKindOfClass:[NSDictionary class]] ) {
                NSString *str = [jsonObj objectForKey:@"server"];
                if ( str != nil && [str isKindOfClass:[NSString class]]) {
                    [SAApp setServerHostName:str];
                    host = str;
                }
            }
        }
    }
    
    return (char*)[host UTF8String];

}

- (void*) client_init {
    
    TSuplaClientCfg scc;
    supla_client_cfginit(&scc);
    
    if (![SAApp getClientGUID:scc.clientGUID]) {
        NSLog(@"Can't get client GUID!");
        return NULL;
    }
    
    if (![SAApp getAuthKey:scc.AuthKey]) {
        NSLog(@"Can't get AuthKey!");
        return NULL;
    }
    
    scc.user_data = (__bridge void *)self;
    scc.host = [self getServerHostName];
    
    if ( [SAApp getAdvancedConfig] ) {
        scc.AccessID = [SAApp getAccessID];
        snprintf(scc.AccessIDpwd, SUPLA_ACCESSID_PWD_MAXSIZE, "%s", [[SAApp getAccessIDpwd] UTF8String]);
        
        if ( _regTryCounter >= 2 ) {
            [SAApp setPreferedProtocolVersion:4]; // supla-server v1.0 for Raspberry Compatibility fix
        }
        
    } else {
       snprintf(scc.Email, SUPLA_EMAIL_MAXSIZE, "%s", [[SAApp getEmailAddress] UTF8String]);
    }

    snprintf(scc.Name, SUPLA_CLIENT_NAME_MAXSIZE, "%s", [[[UIDevice currentDevice] name] UTF8String]);
    snprintf(scc.SoftVer, SUPLA_SOFTVER_MAXSIZE, "iOS%s/%s", [[[UIDevice currentDevice] systemVersion] UTF8String], [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] UTF8String]);
    
    scc.cb_on_versionerror = sasuplaclient_on_versionerror;
    scc.cb_on_connected = sasuplaclient_on_connected;
    scc.cb_on_connerror = sasuplaclient_on_connerror;
    scc.cb_on_disconnected = sasuplaclient_on_disconnected;
    scc.cb_on_registering = sasuplaclient_on_registering;
    scc.cb_on_registered = sasuplaclient_on_registered;
    scc.cb_on_registererror = sasuplaclient_on_register_error;
    scc.cb_location_update = sasuplaclient_location_update;
    scc.cb_channel_update = sasuplaclient_channel_update;
    scc.cb_channelgroup_update = sasuplaclient_channelgroup_update;
    scc.cb_channelgroup_relation_update = sasuplaclient_channelgroup_relation_update;
    scc.cb_channel_value_update = sasuplaclient_channel_value_update;
    scc.cb_channel_extendedvalue_update = sasuplaclient_channel_extendedvalue_update;
    scc.cb_on_event = sasuplaclient_on_event;
    scc.cb_on_registration_enabled = sasuplaclient_on_registration_enabled;
    scc.cb_on_oauth_token_request_result = sasuplaclient_on_oauth_token_request_result;
    
    scc.protocol_version = [SAApp getPreferedProtocolVersion];
    
    return supla_client_init(&scc);

}

- (void)main {

    //NSLog(@"Started");
    
    while(![self isCancelled]) {
        @autoreleasepool {
           
            [self onConnecting];
            BOOL DataChanged = NO;
            
            if ( [self.DB setAllOfChannelVisible:2 whereVisibilityIs:1] ) {
                DataChanged = YES;
            }
            
            if ( [self.DB setAllOfChannelGroupVisible:2 whereVisibilityIs:1] ) {
                DataChanged = YES;
            }
            
            if ( [self.DB setAllOfChannelGroupRelationVisible:2 whereVisibilityIs:1] ) {
                DataChanged = YES;
            }
            
            if ( [self.DB setChannelsOffline] ) {
                DataChanged = YES;
            }
            
            if ( DataChanged ) {
                [self onDataChanged];
            }
            
            @synchronized(self) {
                _sclient = [self client_init];
            }
            
            if ( _sclient == NULL ) {
                NSLog(@"_sclient not initialized!");
                usleep(2000000);
            } else {
                @try {
                    if ( supla_client_connect(_sclient) == 1 ) {
                        while ( [self isCancelled] == NO
                               && supla_client_iterate(_sclient, 100000) == 1) {
                        }
                        
                        if ( [self isCancelled] == NO ) {
                            usleep(5000000);
                        }
                    }
                    
                    if ( [self isCancelled] == NO ) {
                        usleep(2000000);
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception);
                }
                @finally {
                    @synchronized(self) {
                        supla_client_free(_sclient);
                        _sclient = NULL;
                    }
                    
                }
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(_onTerminated) withObject:nil waitUntilDone:NO];
    //NSLog(@"SuplaClient Finished");
}

- (void) _onTerminated {
    [[SAApp instance] onTerminated:self];
}



- (void) _onVersionError:(SAVersionError*)ve {
    [[SAApp instance] onVersionError:ve];
}

- (void) onVersionError:(SAVersionError*)ve {
    
    _regTryCounter = 0;
    
    if ( ([SAApp getAdvancedConfig] || ve.remoteVersion >= 7)
        && ve.remoteVersion >= 5
        && ve.version > ve.remoteVersion
        && [SAApp getPreferedProtocolVersion] != ve.remoteVersion ) {
        
        [SAApp setPreferedProtocolVersion:ve.remoteVersion];
        [self reconnect];
        return;
    }
    
    
    [self performSelectorOnMainThread:@selector(_onVersionError:)
                           withObject:ve waitUntilDone:NO];
}

- (void) _onConnected {
    [[SAApp instance] onConnected];
}

- (void) onConnected {
   [self performSelectorOnMainThread:@selector(_onConnected) withObject:nil waitUntilDone:NO];
}

- (void) _onConnError:(NSNumber*)code {
    [[SAApp instance] onConnError:code];
}

- (void) onConnError:(int)code {
    [self performSelectorOnMainThread:@selector(_onConnError:) withObject:[NSNumber numberWithInt:code] waitUntilDone:NO];
}

- (void) _onDisconnected {
    [[SAApp instance] onDisconnected];
}

- (void) onDisconnected {
    
   if ( [self.DB setChannelsOffline] ) {
       [self onDataChanged];
   }
    
   [self performSelectorOnMainThread:@selector(_onDisconnected) withObject:nil waitUntilDone:NO];
}

- (void) _onRegistering {
    [[SAApp instance] onRegistering];
}

- (void) onRegistering {
    _regTryCounter++;
   [self performSelectorOnMainThread:@selector(_onRegistering) withObject:nil waitUntilDone:NO];
}

- (void) _onRegisterError:(NSNumber*)code {
    [[SAApp instance] onRegisterError:code];
}

- (void) onRegisterError:(int)code {
     _regTryCounter = 0;
    [self performSelectorOnMainThread:@selector(_onRegisterError:) withObject:[NSNumber numberWithInt:code] waitUntilDone:NO];
}

- (void) _onRegistered:(SARegResult*)result {
    [[SAApp instance] onRegistered: result];
}

- (void) onRegistered:(SARegResult*)result {

    _regTryCounter = 0;
    
    if ( [SAApp getPreferedProtocolVersion] < SUPLA_PROTO_VERSION
         && result.Version > [SAApp getPreferedProtocolVersion]
        && result.Version <= SUPLA_PROTO_VERSION ) {
        
        [SAApp setPreferedProtocolVersion:result.Version];
        
    };
    
    if ( result.ChannelCount == 0
         && [self.DB setAllOfChannelVisible:0 whereVisibilityIs:2] ) {
        [self onDataChanged];
    }
    
    if ( result.ChannelGroupCount == 0
        && [self.DB setAllOfChannelGroupVisible:0 whereVisibilityIs:2] ) {
        [self onDataChanged];
    }
    
    _client_id = result.ClientID;
    
    [self performSelectorOnMainThread:@selector(_onRegistered:) withObject:result waitUntilDone:NO];
}

- (void) _onConnecting {
    [[SAApp instance] onConnecting];
}

- (void) onConnecting {
    [self performSelectorOnMainThread:@selector(_onConnecting) withObject:nil waitUntilDone:NO];
}

- (void) _onDataChanged {
    [[SAApp instance] onDataChanged];
}

- (void) onDataChanged {
    [self performSelectorOnMainThread:@selector(_onDataChanged) withObject:nil waitUntilDone:NO];
}

- (void) _onChannelValueChanged:(NSArray*)arr {
    [[SAApp instance] onChannelValueChanged:[arr objectAtIndex:0] isGroup:[arr objectAtIndex:1]];
}

- (void) onChannelValueChanged:(int)Id isGroup:(BOOL)group {
    NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:Id], [NSNumber numberWithBool:group], nil];
    [self performSelectorOnMainThread:@selector(_onChannelValueChanged:) withObject:arr waitUntilDone:NO];
};

- (void) onChannelGroupValueChanged {
    NSArray *result = [self.DB updateChannelGroups];
    BOOL DataChanged = NO;
    
    if (result!=nil) {
        for(int a=0;a<result.count;a++) {
            [self onChannelValueChanged:[[result objectAtIndex:a] intValue] isGroup:YES];
            DataChanged = YES;
        }
    }
    
    if (DataChanged) {
        [self onDataChanged];
    }
}

- (void) locationUpdate:(TSC_SuplaLocation *)location {
    
    if ( [self.DB updateLocation: location] ) {
        [self onDataChanged];
    };
    
}

- (BOOL) isChannelExcluded:(TSC_SuplaChannel_C *)channel {
    // For partner applications 
    return NO;
}

- (void) channelUpdate:(TSC_SuplaChannel_C *)channel {
    
    BOOL DataChanged = NO;
    BOOL ChannelValueChanged = NO;
    
    //NSLog(@"ChannelID: %i, caption: %@", channel->Id, [NSString stringWithUTF8String:channel->Caption]);
    
    if ( ![self isChannelExcluded:channel]
         && [self.DB updateChannel:channel] ) {
        DataChanged = YES;
    }
    
    TSC_SuplaChannelValue value;
    value.EOL = channel->EOL;
    value.Id = channel->Id;
    value.online = channel->online;
    memcpy(&value.value, &channel->value, sizeof(TSuplaChannelValue));
    
    if ( [self.DB updateChannelValue:&value] ) {
        DataChanged = YES;
        ChannelValueChanged = YES;
    }

    if ( channel->EOL == 1
         && [self.DB setAllOfChannelVisible:0 whereVisibilityIs:2] ) {
        DataChanged = YES;
    }
    
    if ( DataChanged ) {
        [self onDataChanged];
    }
    
    if ( ChannelValueChanged ) {
        [self onChannelValueChanged: channel->Id isGroup:NO];
    }
    
}

- (void) channelValueUpdate:(TSC_SuplaChannelValue *)channel_value {
    if ( [self.DB updateChannelValue:channel_value] ) {
        [self onChannelValueChanged: channel_value->Id isGroup:NO];
        [self onDataChanged];
    }
    
    if (channel_value->EOL == 1) {
        [self onChannelGroupValueChanged];
    }
    
}

- (void) channelExtendedValueUpdate:(TSC_SuplaChannelExtendedValue *)channel_extendedvalue {
  
    if ( [self.DB updateChannelExtendedValue:channel_extendedvalue] ) {
        [self onChannelValueChanged: channel_extendedvalue->Id isGroup:NO];
        [self onDataChanged];
    }

}

- (void) channelGroupUpdate:(TSC_SuplaChannelGroup_B *)cgroup {
    //NSLog(@"CGroup %i", cgroup->Id);
    
    BOOL DataChanged = NO;
    
    if ( [self.DB updateChannelGroup:cgroup] ) {
        DataChanged = YES;
    }
    
    if ( cgroup->EOL == 1
        && [self.DB setAllOfChannelGroupVisible:0 whereVisibilityIs:2] ) {
        DataChanged = YES;
    }
    
    if (cgroup->EOL == 1) {
        [self onChannelGroupValueChanged];
    }
    
    if ( DataChanged ) {
        [self onDataChanged];
    }
}

- (void) channelGroupRelationUpdate:(TSC_SuplaChannelGroupRelation *)cgroup_relation {
    BOOL DataChanged = NO;
    
    if ( [self.DB updateChannelGroupRelation:cgroup_relation] ) {
        DataChanged = YES;
    }
    
    if ( cgroup_relation->EOL == 1
        && [self.DB setAllOfChannelGroupRelationVisible:0 whereVisibilityIs:2] ) {
        DataChanged = YES;
    }
    
    if (cgroup_relation->EOL == 1) {
        [self onChannelGroupValueChanged];
    }
    
    if ( DataChanged ) {
        [self onDataChanged];
    }
}

- (void) _onEvent:(SAEvent *)event {
    [[SAApp instance] onEvent:event];
}

- (void) onEvent:(SAEvent *)event {
    event.Owner = event.SenderID == _client_id;
    [self performSelectorOnMainThread:@selector(_onEvent:) withObject:event waitUntilDone:NO];
    
}

- (void) _onRegistrationEnabled:(SARegistrationEnabled *)reg_enabled {
    [[SAApp instance] onRegistrationEnabled:reg_enabled];
}

- (void) onRegistrationEnabled:(SARegistrationEnabled *)reg_enabled {
    [self performSelectorOnMainThread:@selector(_onRegistrationEnabled:) withObject:reg_enabled waitUntilDone:NO];
}

- (void) _onOAuthTokenRequestResult:(SAOAuthToken *)token {
    [[SAApp instance] onOAuthTokenRequestResult:token];
}

- (void) onOAuthTokenRequestResult:(SAOAuthToken *)token {
    [self performSelectorOnMainThread:@selector(_onOAuthTokenRequestResult:) withObject:token waitUntilDone:NO];
}

- (void) reconnect {
    @synchronized(self) {
        if ( _sclient ) {
            if ( supla_client_connected(_sclient) == 1 )
                supla_client_disconnect(_sclient);
        }
    }
}

- (BOOL) isConnected {
    BOOL result = NO;
    @synchronized(self) {
        if ( _sclient ) {
            result = supla_client_connected(_sclient) == 1 ? YES : NO;
        }
    }
    return result;
}

- (BOOL) isRegistered {
    BOOL result = NO;
    @synchronized(self) {
        if ( _sclient ) {
            result = supla_client_registered(_sclient) == 1 ? YES : NO;
        }
    }
    return result;
}

- (BOOL) cg:(int)ID setRGB:(UIColor*)color colorBrightness:(int)color_brightness brightness:(int)brightness group:(BOOL)group turnOnOff:(BOOL)turnOnOff {
    
    BOOL result = NO;
    
    @synchronized(self) {
        if ( _sclient ) {
            
            CGFloat red,green,blue,alpha;
            
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            
            red*=255;
            green*=255;
            blue*=255;
            
            int _color = (int)blue;
            _color |= ((int)green) << 8;
            _color |= ((int)red) << 16;
            
            if ( brightness < 0 || brightness > 100 )
                brightness = 0;
            
            if ( color_brightness < 0 || color_brightness > 100 )
                color_brightness = 0;
            
            result = 1 == supla_client_set_rgbw(_sclient, ID, group, _color, color_brightness, brightness, turnOnOff ? 1 : 0);
        }
    }
    
    return result;
}

- (void) cg:(int)ID Open:(char)open group:(BOOL)group {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_open(_sclient, ID, group, open);
        }
    }
}

- (void) channel:(int)ChannelID Open:(char)open {
    [self cg:ChannelID Open:open group:NO];
}

- (BOOL) channel:(int)ChannelID setRGB:(UIColor*)color colorBrightness:(int)color_brightness brightness:(int)brightness {
    return [self cg:ChannelID setRGB:color colorBrightness:color_brightness brightness:brightness group:NO turnOnOff:NO];
}

- (void) group:(int)GroupID Open:(char)open {
    [self cg:GroupID Open:open group:YES];
}

- (BOOL) group:(int)GroupID setRGB:(UIColor*)color colorBrightness:(int)color_brightness brightness:(int)brightness {
    return [self cg:GroupID setRGB:color colorBrightness:color_brightness brightness:brightness group:YES turnOnOff:NO];
}

- (void) deviceCalCfgRequest:(TCS_DeviceCalCfgRequest_B*)request {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_device_calcfg_request(_sclient, request);
        }
    }
}

- (void) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group data:(char*)data dataSize:(unsigned int)size {
    TCS_DeviceCalCfgRequest_B request;
    memset(&request, 0, sizeof(TCS_DeviceCalCfgRequest_B));
    request.Id = ID;
    request.Target = group ? SUPLA_TARGET_GROUP : SUPLA_TARGET_CHANNEL;
    request.Command = command;
    if (data && size > 0 && size <= SUPLA_CALCFG_DATA_MAXSIZE) {
        request.DataSize = size;
        memcpy(request.Data, data, size);
    }
    
    [self deviceCalCfgRequest:&request];
}

- (void) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group {
    [self deviceCalCfgCommand:command cg:ID group:group data:NULL dataSize:0];
}

- (void) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group charValue:(char)c {
    [self deviceCalCfgCommand:command cg:ID group:group data:&c dataSize:sizeof(c)];
}

- (void) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group shortValue:(short)s {
   [self deviceCalCfgCommand:command cg:ID group:group data:(char*)&s dataSize:sizeof(s)];
}

- (void) thermostatScheduleCfgRequest:(SAThermostatScheduleCfg *)cfg cg:(int)ID group:(BOOL)group {
    if (cfg == nil || cfg.groupCount == 0) {
        return;
    }
    
    TCS_DeviceCalCfgRequest_B request;
    memset(&request, 0, sizeof(TCS_DeviceCalCfgRequest_B));
    request.Id = ID;
    request.Target = group ? SUPLA_TARGET_GROUP : SUPLA_TARGET_CHANNEL;
    request.Command = SUPLA_THERMOSTAT_CMD_SET_SCHEDULE;
    request.DataSize = sizeof(TThermostat_ScheduleCfg);
    
    TThermostat_ScheduleCfg *scfg = (TThermostat_ScheduleCfg *)request.Data;
 
    int n = 0;
    for(int a=0;a<cfg.groupCount;a++) {
        
        scfg->Group[n].ValueType = [cfg valueTypeForGroupIndex:a] ==
        kPROGRAM ? THERMOSTAT_SCHEDULE_HOURVALUE_TYPE_PROGRAM
        : THERMOSTAT_SCHEDULE_HOURVALUE_TYPE_TEMPERATURE;
        
        scfg->Group[n].WeekDays = [cfg weekDaysForGroupIndex:a];
        [cfg getHourValue:scfg->Group[n].HourValue forGroupIndex:a];
            
        n++;
        if (n==4 || a == cfg.groupCount - 1) {
            @synchronized(self) {
                if ( _sclient ) {
                    supla_client_device_calcfg_request(_sclient, &request);
                }
            }
            n=0;
            memset(scfg, 0, sizeof(TThermostat_ScheduleCfg));
        }
    }
}

- (void) getRegistrationEnabled {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_get_registration_enabled(_sclient);
        }
    }
}

- (int) getProtocolVersion {
    int result = 0;
    @synchronized(self) {
        if ( _sclient ) {
            result = supla_client_get_proto_version(_sclient);
        }
    }
    return result;
}

- (BOOL) OAuthTokenRequest {
    BOOL result = false;
    
    @synchronized(self) {
        int now = [[NSDate date] timeIntervalSince1970];
        
        if (now-_tokenRequestTime > 5 ) {
            if ( _sclient ) {
                supla_client_oauth_token_request(_sclient);
                _tokenRequestTime = now;
            }
        }

    }
    
    return result;
}


@end
