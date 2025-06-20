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
#import <AudioToolbox/AudioToolbox.h>
#import "SARestApiClientTask.h"
#import "SAChannelStateExtendedValue.h"
#import "SAVersionError.h"
#import "SARegResult.h"
#import "SAEvent.h"
#import "SARegistrationEnabled.h"
#import "SASuperuserAuthorizationResult.h"
#import "SACalCfgResult.h"
#import "SuplaClient.h"
#import "SuplaApp.h"
#import "Database.h"
#import "SAChannelBasicCfg.h"
#import "SAChannelCaptionSetResult.h"
#import "SAChannelFunctionSetResult.h"
#import "SAZWaveNodeIdResult.h"
#import "SAZWaveNodeResult.h"
#import "SACalCfgProgressReport.h"
#import "SAZWaveWakeupSettingsReport.h"
#import "SAChannel+CoreDataClass.h"
#import "supla-client.h"
#import "SUPLA-Swift.h"
@import UserNotifications;

#define MINIMUM_WAITING_TIME_SEC 2
#define CONNECTION_TIMEOUT_MS 5000

@interface SASuplaClient ()
- (void) onVersionError:(SAVersionError*)ve;
- (void) onConnected;
- (void) onConnError:(int)code;
- (void) onDisconnected;
- (void) onRegistering;
- (void) onRegistered:(SARegResult *)result;
- (void) onRegisterError:(int)code;
- (void) locationUpdate:(TSC_SuplaLocation *)location;
- (void) channelUpdate:(TSC_SuplaChannel_E *)channel;
- (void) channelValueUpdate:(TSC_SuplaChannelValue_B *)channel_value;
- (void) channelExtendedValueUpdate:(TSC_SuplaChannelExtendedValue *)channel_extendedvalue;
- (void) channelGroupUpdate:(TSC_SuplaChannelGroup_B *)cgroup;
- (void) channelGroupRelationUpdate:(TSC_SuplaChannelGroupRelation *)cgroup_relation;
- (void) channelRelationUpdate: (TSC_SuplaChannelRelation *) relation;
- (void) sceneUpdate:(TSC_SuplaScene *)scene;
- (void) sceneStateUpdate:(TSC_SuplaSceneState *)state;
- (void) onEvent:(SAEvent *)event;
- (void) onRegistrationEnabled:(SARegistrationEnabled*)reg_enabled;
- (void) onSetRegistrationEnabledResultCode:(int)code;
- (void) onOAuthTokenRequestResult:(SAOAuthToken *)token;
- (void) onSuperuserAuthorizationResult:(SASuperuserAuthorizationResult*)result;
- (void) onCalCfgResult:(SACalCfgResult*)result;
- (void) onChannelState:(SAChannelStateExtendedValue*)state;
- (void) onChannelBasicCfg:(SAChannelBasicCfg*)cfg;
- (void) onChannelCaptionSetResult:(SAChannelCaptionSetResult*)result;
- (void) onChannelGroupCaptionSetResult:(SAChannelCaptionSetResult*)result;
- (void) onChannelFunctionSetResult:(SAChannelFunctionSetResult*)result;
- (void) onZwaveGetAssignedNodeIdResult:(SAZWaveNodeIdResult*)result;
- (void) onZwaveGetNodeListResult:(SAZWaveNodeResult*)result;
- (void) onCalCfgProgressReport:(SACalCfgProgressReport*)report;
- (void) onZWaveResetAndClearResult:(NSNumber *)result;
- (void) onZwaveAddNodeResult:(SAZWaveNodeResult*)result;
- (void) onZwaveRemoveNodeResult:(SAZWaveNodeIdResult*)result;
- (void) onZwaveOnAssignNodeIdResult:(SAZWaveNodeIdResult*)result;
- (void) onZwaveWakeupSettingsReport:(SAZWaveWakeupSettingsReport*)report;
- (void) onZWaveSetWakeUpTimeResult:(NSNumber *)result;
- (void) onChannelConfigUpdateOrResult: (TSC_ChannelConfigUpdateOrResult*) config crc32: (unsigned _supla_int_t) crc32;
- (void) onDeviceConfigUpdateOrResult: (TSC_DeviceConfigUpdateOrResult*) config;
@end

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

void sasuplaclient_on_registered(void *_suplaclient, void *user_data, TSC_SuplaRegisterClientResult_D *result) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
        sc->serverTimeDiffInSec = [[NSDate alloc] init].timeIntervalSince1970 - result->serverUnixTimestamp;
        [sc onRegistered:[SARegResult RegResultClientID:result->ClientID locationCount:result->LocationCount channelCount:result->ChannelCount channelGroupCount:result->ChannelGroupCount sceneCount: result->SceneCount flags:result->Flags version:result->version]];
    }
}

void sasuplaclient_on_set_registration_enabled_result(void *_suplaclient, void *user_data, TSC_SetRegistrationEnabledResult *result) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onSetRegistrationEnabledResultCode:result ? result->ResultCode : 0];
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

#pragma mark Channels callbacks

void sasuplaclient_channel_update(void *_suplaclient, void *user_data, TSC_SuplaChannel_E *channel) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc channelUpdate: channel];
}

void sasuplaclient_channel_value_update(void *_suplaclient, void *user_data, TSC_SuplaChannelValue_B *channel_value) {
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

void sasuplaclient_channel_relation_update(void *_suplaclient, void *user_data, TSC_SuplaChannelRelation *channel_relation) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
        [sc channelRelationUpdate: channel_relation];
    }
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

void sasuplaclient_on_superuser_authorization_result(void *_suplaclient, void *user_data, char authorized, _supla_int_t code) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
        SASuperuserAuthorizationResult *result = [SASuperuserAuthorizationResult superuserAuthorizationResult:authorized > 0 withCode:code];
        [sc onSuperuserAuthorizationResult:result];
    }
}

void sasuplaclient_on_calcfg_result(void *_suplaclient, void *user_data, TSC_DeviceCalCfgResult *result) {
   
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil && result != NULL) {
        [sc onCalCfgResult:[SACalCfgResult resultWithResult:result]];
    }
}

void sasuplaclient_on_device_channel_state(void *_suplaclient, void *user_data, TDSC_ChannelState *state) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil && state != NULL) {
        [sc onChannelState: [[SAChannelStateExtendedValue alloc] initWithChannelState:state]];
    }
}

void sasuplaclient_on_channel_basic_cfg(void *_suplaclient,
                                        void *user_data,
                                        TSC_ChannelBasicCfg *cfg) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil && cfg != NULL) {
        [sc onChannelBasicCfg:[[SAChannelBasicCfg alloc] initWithCfg:cfg]];
    }
}

void sasuplaclient_on_channel_caption_set_result(void *_suplaclient,
                                                 void *user_data,
                                                 TSCD_SetCaptionResult *result) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil && result != NULL) {
        [sc onChannelCaptionSetResult:[[SAChannelCaptionSetResult alloc] initWithResult:result]];
    }
}

void sasuplaclient_on_channel_group_caption_set_result(void *_suplaclient,
                                                       void *user_data,
                                                       TSCD_SetCaptionResult *result) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil && result != NULL) {
        [sc onChannelGroupCaptionSetResult:[[SAChannelCaptionSetResult alloc] initWithResult:result]];
    }
}

void sasuplaclient_on_channel_function_set_result(void *_suplaclient,
                                         void *user_data,
                                         TSC_SetChannelFunctionResult *result) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil && result != NULL) {
        [sc onChannelFunctionSetResult:[[SAChannelFunctionSetResult alloc] initWithResult:result]];
    }
}

void sasuplaclient_on_zwave_get_assigned_node_id_result(void *_suplaclient,
                                                        void *user_data,
                                                        _supla_int_t result,
                                                        unsigned char node_id) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
        [sc onZwaveGetAssignedNodeIdResult:[[SAZWaveNodeIdResult alloc]
                                            initWithResultCode:result andNodeId:node_id]];
    }
}

void sasuplaclient_on_zwave_get_node_list_result(void *_suplaclient,
                                                 void *user_data,
                                                 _supla_int_t result,
                                            TCalCfg_ZWave_Node *node) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
        [sc onZwaveGetNodeListResult:[SAZWaveNodeResult
                                      resultWithResultCode:result
                                      andZWaveNode:node]];
    }
}

void sasuplaclient_on_device_calcfg_progress_report(void *_suplaclient,
                                                 void *user_data, int ChannelID,
                                                 TCalCfg_ProgressReport *progress_report) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
        [sc onCalCfgProgressReport:[SACalCfgProgressReport
                                    reportWithReport:progress_report
                                    channelId:ChannelID]];
    }
}

void sasuplaclient_on_zwave_reset_and_clear_result(void *_suplaclient,
                                                   void *user_data,
                                                   _supla_int_t result) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
        [sc onZWaveResetAndClearResult:[NSNumber numberWithInt:result]];
    }
}

void sasuplaclient_on_zwave_add_node_result(void *_suplaclient,
                                            void *user_data,
                                            _supla_int_t result,
                                       TCalCfg_ZWave_Node *node) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
       [sc onZwaveAddNodeResult:[SAZWaveNodeResult
                                     resultWithResultCode:result
                                     andZWaveNode:node]];
    }
}

void sasuplaclient_on_zwave_remove_node_result(void *_suplaclient,
                                               void *user_data,
                                               _supla_int_t result,
                                               unsigned char node_id) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
    [sc onZwaveRemoveNodeResult:[[SAZWaveNodeIdResult alloc]
                                       initWithResultCode:result andNodeId:node_id]];
    }
}

void sasuplaclient_on_zwave_assign_node_id_result(void *_suplaclient,
                                                  void *user_data,
                                                  _supla_int_t result,
                                                  unsigned char node_id) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
    [sc onZwaveOnAssignNodeIdResult:[[SAZWaveNodeIdResult alloc]
                                       initWithResultCode:result andNodeId:node_id]];
    }
}

void sasuplaclient_on_zwave_wake_up_settings_report(void *_suplaclient,
                                                    void *user_data, _supla_int_t result,
                                                    TCalCfg_ZWave_WakeupSettingsReport *report) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil ) {
    [sc onZwaveWakeupSettingsReport:[[SAZWaveWakeupSettingsReport alloc]
                                       initWithResultCode:result andReport:report]];
    }
}

void sasuplaclient_on_zwave_set_wake_up_time_result(void *_suplaclient,
                                                    void *user_data,
                                                    _supla_int_t result) {
     SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
     if ( sc != nil ) {
         [sc onZWaveSetWakeUpTimeResult:[NSNumber numberWithInt:result]];
     }
 }

#pragma mark Scenes callbacks

void sasuplaclient_scene_update(void *_suplaclient,
                                   void *user_data,
                                   TSC_SuplaScene *scene) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc sceneUpdate: scene];
}

void sasuplaclient_scene_state_update(void *_suplaclient,
                                      void *user_data,
                                      TSC_SuplaSceneState *state) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc sceneStateUpdate:state];
}

void sasuplaclient_channel_config_update_or_result(void *_suplaclient,
                                                   void *user_data,
                                                   TSC_ChannelConfigUpdateOrResult *config,
                                                   unsigned _supla_int_t crc32) {
    SASuplaClient *sc = (__bridge SASuplaClient*) user_data;
    if ( sc != nil ) {
        [sc onChannelConfigUpdateOrResult: config crc32:crc32];
    }
}

void sasuplaclient_device_config_update_or_result(void *_suplaclient,
                                                  void *user_data,
                                                  TSC_DeviceConfigUpdateOrResult *config) {
    SASuplaClient *sc = (__bridge SASuplaClient*) user_data;
    if ( sc != nil ) {
        [sc onDeviceConfigUpdateOrResult: config];
    }
}

// ------------------------------------------------------------------------------------------------------

@implementation SASuplaClient {
    SADatabase *_DB;
    
    void *_sclient;
    int _client_id;
    BOOL _connected;
    int _regTryCounter;
    int _tokenRequestTime;
    BOOL _superuserAuthorized;
    NSString *_oneTimePassword;
    NSDate *_connectingStatusLastTime;
}

@synthesize delegate;

- (id)initWithOneTimePassword:(NSString*)oneTimePassword {
    assert(_sclient == NULL);
    if (self = [super init]) {
        _oneTimePassword = oneTimePassword;
    }
    return self;
}

+(NSString *)codeToString:(NSNumber*)code authDialog:(BOOL)authDialog {
    NSString *str = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"Unknown error", nil), code];
    
    switch([code intValue]) {
        case SUPLA_RESULTCODE_TEMPORARILY_UNAVAILABLE:
            str = NSLocalizedString(@"Service temporarily unavailable", nil);
            break;
        case SUPLA_RESULTCODE_BAD_CREDENTIALS:
            str = NSLocalizedString(authDialog ? @"Incorrect Email Address or Password" : @"Bad credentials", nil);
            break;
        case SUPLA_RESULTCODE_CLIENT_LIMITEXCEEDED:
            str = NSLocalizedString(@"Client limit exceeded", nil);
            break;
        case SUPLA_RESULTCODE_CLIENT_DISABLED:
            str = NSLocalizedString(@"Device disabled. Please log in to \"Supla Cloud\" and enable this device in “Smartphone” section of the website.", nil);
            break;
        case SUPLA_RESULTCODE_ACCESSID_DISABLED:
            str = NSLocalizedString(@"Access Identifier is disabled", nil);
            break;
        case SUPLA_RESULTCODE_REGISTRATION_DISABLED:
            str = NSLocalizedString(@"New client registration disabled. Please log in to \"Supla Cloud\" and enable \"New client registration\" in \"Smartphone\" section of the website.", nil);
            break;
        case SUPLA_RESULTCODE_ACCESSID_NOT_ASSIGNED:
            str = NSLocalizedString(@"Client activation required. Please log in to \"Supla Cloud\" and assign an “Access ID” for this device in “Smartphone” section of the website.", nil);
            break;
        case SUPLA_RESULTCODE_INACTIVE:
            str = NSLocalizedString(@"Access Identifier inactive.", nil);
            break;
            
    }
    
    return str;
}

+(NSString *)codeToString:(NSNumber*)code {
    return [SASuplaClient codeToString:code authDialog:NO];
}

-(SADatabase*)DB {
    if ( _DB == nil ) {
        _DB = [[SADatabase alloc] init];
    }
    
    return _DB;
}

- (char*) getServerHostName {
    id<ProfileManager> pm = SAApp.profileManager;
    AuthProfileItem *profile = [pm getCurrentProfile];
    if (profile == nil) {
        return "";
    }
    
    SAProfileServer *server = profile.server;
    if (server == nil || ([server.address isEqualToString:@""] && profile.rawAuthorizationType == AuthorizationTypeEmail && ![profile.email isEqualToString:@""] )) {
        return (char*) [[UseCaseLegacyWrapper loadServerHostName] UTF8String];
    }
    
    return (char*)[server.address UTF8String];
    
}

- (void*) client_init {
    
    TSuplaClientCfg scc;
    supla_client_cfginit(&scc);
    id<ProfileManager> pm = SAApp.profileManager;
    AuthProfileItem *profile = [pm getCurrentProfile];
    
    if (profile != nil) {
        [profile.clientGUID getBytes: scc.clientGUID
                              length: SUPLA_GUID_SIZE];
        [profile.authKey getBytes: scc.AuthKey
                           length: SUPLA_AUTHKEY_SIZE];
        
        scc.user_data = (__bridge void *)self;
        scc.host = [self getServerHostName];
        
        if (scc.host == NULL
            || strnlen(scc.host, SUPLA_SERVER_NAME_MAXSIZE) == 0) {
            [self onConnError:SUPLA_RESULT_HOST_NOT_FOUND];
        }
        
        if ( profile.rawAuthorizationType == AuthorizationTypeAccessId ) {
            scc.AccessID = profile.accessId;
            [profile.accessIdPassword utf8StringToBuffer:scc.AccessIDpwd withSize:sizeof(scc.AccessIDpwd)];
            if ( _regTryCounter >= 2 ) {
                [UseCaseLegacyWrapper updatePreferredProtocolVersion: 4];
            }
            
        } else {
            [profile.email utf8StringToBuffer:scc.Email withSize:sizeof(scc.Email)];
            if (_oneTimePassword && _oneTimePassword.length) {
                [_oneTimePassword utf8StringToBuffer:scc.Password withSize:sizeof(scc.Password)];
            }
        }
        scc.protocol_version = profile.preferredProtocolVersion;
    }
    
    _oneTimePassword = nil;
    
    [[[UIDevice currentDevice] name] utf8StringToBuffer:scc.Name withSize:sizeof(scc.Name)];
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
    scc.cb_channel_relation_update = sasuplaclient_channel_relation_update;
    scc.cb_on_event = sasuplaclient_on_event;
    scc.cb_on_registration_enabled = sasuplaclient_on_registration_enabled;
    scc.cb_on_oauth_token_request_result = sasuplaclient_on_oauth_token_request_result;
    scc.cb_on_superuser_authorization_result = sasuplaclient_on_superuser_authorization_result;
    scc.cb_on_device_calcfg_result = sasuplaclient_on_calcfg_result;
    scc.cb_on_device_channel_state = sasuplaclient_on_device_channel_state;
    scc.cb_on_set_registration_enabled_result = sasuplaclient_on_set_registration_enabled_result;
    scc.cb_on_channel_basic_cfg = sasuplaclient_on_channel_basic_cfg;
    scc.cb_on_channel_caption_set_result = sasuplaclient_on_channel_caption_set_result;
    scc.cb_on_channel_group_caption_set_result = sasuplaclient_on_channel_group_caption_set_result;
    scc.cb_on_channel_function_set_result = sasuplaclient_on_channel_function_set_result;
    scc.cb_on_zwave_get_assigned_node_id_result = sasuplaclient_on_zwave_get_assigned_node_id_result;
    scc.cb_on_zwave_get_node_list_result = sasuplaclient_on_zwave_get_node_list_result;
    scc.cb_on_device_calcfg_progress_report = sasuplaclient_on_device_calcfg_progress_report;
    scc.cb_on_zwave_reset_and_clear_result = sasuplaclient_on_zwave_reset_and_clear_result;
    scc.cb_on_zwave_add_node_result = sasuplaclient_on_zwave_add_node_result;
    scc.cb_on_zwave_remove_node_result = sasuplaclient_on_zwave_remove_node_result;
    scc.cb_on_zwave_assign_node_id_result = sasuplaclient_on_zwave_assign_node_id_result;
    scc.cb_on_zwave_wake_up_settings_report = sasuplaclient_on_zwave_wake_up_settings_report;
    scc.cb_on_zwave_set_wake_up_time_result = sasuplaclient_on_zwave_set_wake_up_time_result;
    scc.cb_scene_update = sasuplaclient_scene_update;
    scc.cb_scene_state_update = sasuplaclient_scene_state_update;
    scc.cb_on_channel_config_update_or_result = sasuplaclient_channel_config_update_or_result;
    scc.cb_on_device_config_update_or_result = sasuplaclient_device_config_update_or_result;
    
    return supla_client_init(&scc);
    
}

- (void)main {
    
    //NSLog(@"Started");
    
    while(![self isCancelled]) {
        @autoreleasepool {
            
            @synchronized(self) {
                _superuserAuthorized = NO;
            }
            
            _connectingStatusLastTime = [NSDate date];
            
            [self onConnecting];
            BOOL DataChanged = NO;
            
            if ( [UseCaseLegacyWrapper changeChannelsVisibilityFrom:1 to:2] ) {
                DataChanged = YES;
            }
            
            if ( [UseCaseLegacyWrapper changeGroupsVisibilityFrom:1 to:2] ) {
                DataChanged = YES;
            }
            
            if ( [UseCaseLegacyWrapper changeChannelGroupRelationsVisibilityFrom:1 to:2] ) {
                DataChanged = YES;
            }
            
            if ([UseCaseLegacyWrapper changeScenesVisibilityFrom:1 to:2]) {
                DataChanged = YES;
            }
            
            [UseCaseLegacyWrapper markChannelRelationsAsRemovable];
            
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
                    // TODO: Add network check
                    if ( [self isCancelled] == NO && supla_client_connect(_sclient, CONNECTION_TIMEOUT_MS) == 1 ) {
                        while ( [self isCancelled] == NO
                               && supla_client_iterate(_sclient, 100000) == 1) {
                        }
                    }
                    
                    if ( [self isCancelled] == NO ) {
                        double timeDiff = [_connectingStatusLastTime timeIntervalSinceNow] * -1;
                        if ( timeDiff < MINIMUM_WAITING_TIME_SEC) {
                            usleep((MINIMUM_WAITING_TIME_SEC - timeDiff) * 1000000);
                        }
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception);
                }
                @finally {
                    [UseCaseLegacyWrapper killAsyncChannelsManager];
                    @synchronized(self) {
                        supla_client_free(_sclient);
                        _sclient = NULL;
                    }
                    
                }
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(_onTerminated) withObject:nil waitUntilDone:NO];
    [SuplaAppStateHolderProxy finish];
    //NSLog(@"SuplaClient Finished");
}

- (void) _onTerminated {
    if (self.delegate) {
        [self.delegate onSuplaClientTerminated:self];
    }
}



- (void) _onVersionError:(SAVersionError*)ve {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAVersionErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[ve] forKeys:@[@"version_error"]]];
}

- (void) onVersionError:(SAVersionError*)ve {
    
    _regTryCounter = 0;
    id<ProfileManager> pm = SAApp.profileManager;
    AuthProfileItem *profile = [pm getCurrentProfile];
    
    if ( profile != nil && (profile.rawAuthorizationType == AuthorizationTypeAccessId || ve.remoteVersion >= 7)
        && ve.remoteVersion >= 5
        && ve.version > ve.remoteVersion
        && profile.preferredProtocolVersion != ve.remoteVersion ) {
        [UseCaseLegacyWrapper updatePreferredProtocolVersion: ve.remoteVersion];
        [self reconnect];
        return;
    }
    
    [self performSelectorOnMainThread:@selector(_onVersionError:)
                           withObject:ve waitUntilDone:NO];
    
    [self cancel];
    [SuplaAppStateHolderProxy versionError];
}

- (void) _onConnected {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAConnectedNotification object:self userInfo:nil];
}

- (void) onConnected {
    [self performSelectorOnMainThread:@selector(_onConnected) withObject:nil waitUntilDone:NO];
}

- (void) _onConnError:(NSNumber*)code {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAConnErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[code] forKeys:@[@"code"]]];
}

- (void) onConnError:(int)code {
    [self performSelectorOnMainThread:@selector(_onConnError:) withObject:[NSNumber numberWithInt:code] waitUntilDone:NO];
    
    if (code == SUPLA_RESULT_HOST_NOT_FOUND) {
        [self cancel];
    }
    
    [SuplaAppStateHolderProxy connectionErrorWithCode: code];
}

- (void) _onDisconnected {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSADisconnectedNotification object:self userInfo:nil];
}

- (void) onDisconnected {
    [self performSelectorOnMainThread:@selector(_onDisconnected) withObject:nil waitUntilDone:NO];
}

- (void) _onRegistering {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegisteringNotification object:self userInfo:nil];
}

- (void) onRegistering {
    _regTryCounter++;
    [self performSelectorOnMainThread:@selector(_onRegistering) withObject:nil waitUntilDone:NO];
}

- (void) _onRegisterError:(NSNumber*)code {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegisterErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[code] forKeys:@[@"code"]]];
}

- (void) onRegisterError:(int)code {
    _regTryCounter = 0;
    
    [self cancel];
    
    [self performSelectorOnMainThread:@selector(_onRegisterError:) withObject:[NSNumber numberWithInt:code] waitUntilDone:NO];
    [SuplaAppStateHolderProxy registerErrorWithCode:code];
}

- (void) _onRegistered:(SARegResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegisteredNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onRegistered:(SARegResult*)result {
    
    _regTryCounter = 0;
    id<ProfileManager> pm = [SAApp profileManager];
    AuthProfileItem *profile = [pm getCurrentProfile];
    
    long maxVersionSupportedByLibrary = SUPLA_PROTO_VERSION;
    long storedVersion = profile.preferredProtocolVersion;
    long serverVersion = result.Version;
    if (storedVersion < maxVersionSupportedByLibrary && serverVersion > storedVersion) {
        long newVersion = serverVersion;
        if (newVersion > maxVersionSupportedByLibrary) {
            newVersion = maxVersionSupportedByLibrary;
        }
        [UseCaseLegacyWrapper updatePreferredProtocolVersion: newVersion];
    };
    
    NSLog(@"Protocol Version=%d", result.Version);
    
    if ( result.ChannelCount == 0
        && [UseCaseLegacyWrapper changeChannelsVisibilityFrom:2 to:0] ) {
        [self onDataChanged];
        [DiContainer.updateEventsManager emitChannelsUpdate];
    }
    
    if ( result.ChannelGroupCount == 0
        && [UseCaseLegacyWrapper changeGroupsVisibilityFrom:2 to:0] ) {
        [self onDataChanged];
        [DiContainer.updateEventsManager emitGroupsUpdate];
    }
    
    if (result.SceneCount == 0
        && [UseCaseLegacyWrapper changeScenesVisibilityFrom:2 to:0]) {
        [self onDataChanged];
        [DiContainer.updateEventsManager emitScenesUpdate];
    }
    
    _client_id = result.ClientID;
    NSData* pushToken = [DiContainer getPushToken];
    [self registerPushNotificationClientToken:pushToken forProfile: profile];
    [DiContainer setOAuthUrlWithUrl: profile.serverUrlString];

    [self performSelectorOnMainThread:@selector(_onRegistered:) withObject:result waitUntilDone:NO];
    
    if (!self.isCancelled) {
        [SuplaAppStateHolderProxy connected];
    }
}

- (void) _onConnecting {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAConnectingNotification object:self userInfo:nil];
}

- (void) onConnecting {
    [self performSelectorOnMainThread:@selector(_onConnecting) withObject:nil waitUntilDone:NO];
    [SuplaAppStateHolderProxy connecting];
}

- (void) _onDataChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSADataChangedNotification object:self userInfo:nil];
}

- (void) onDataChanged {
    [self performSelectorOnMainThread:@selector(_onDataChanged) withObject:nil waitUntilDone:NO];
}

- (void) _onChannelValueChanged:(NSArray*)arr { 
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAChannelValueChangedNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[[arr objectAtIndex:0], [arr objectAtIndex:1]] forKeys:@[@"remoteId", @"isGroup"]]];
}

- (void) onChannelValueChanged:(int)Id isGroup:(BOOL)group {
    if (group) {
        [DiContainer.updateEventsManager emitGroupUpdateWithRemoteId: Id];
    } else {
        [DiContainer.updateEventsManager emitChannelUpdateWithRemoteId: Id];
    }
    NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:Id], [NSNumber numberWithBool:group], nil];
    [self performSelectorOnMainThread:@selector(_onChannelValueChanged:) withObject:arr waitUntilDone:NO];
};

- (void) onChannelGroupValueChanged {
    NSArray *result = [UseCaseLegacyWrapper updateChannelGroups];
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
    
    if ( [UseCaseLegacyWrapper updateLocationWithSuplaLocation: *location] ) {
        [self onDataChanged];
    };
    
}

- (BOOL) isChannelExcluded:(TSC_SuplaChannel_E *)channel {
    // For partner applications
    return NO;
}

- (void) channelUpdate:(TSC_SuplaChannel_E *)channel {
    
    BOOL DataChanged = NO;
    BOOL ChannelValueChanged = NO;
    
    NSLog(@"ChannelID: %i, caption: %@", channel->Id, [NSString stringWithUTF8String:channel->Caption]);
    
    if ( ![self isChannelExcluded:channel]
        && [UseCaseLegacyWrapper updateChannelWithSuplaChannel: *channel] ) {
        DataChanged = YES;
    }
    
    TSC_SuplaChannelValue_B value;
    value.EOL = channel->EOL;
    value.Id = channel->Id;
    value.online = channel->online;
    memcpy(&value.value, &channel->value, sizeof(TSuplaChannelValue_B));
    
    if ( [UseCaseLegacyWrapper updateChannelValueWithSuplaChannelValue: value] ) {
        DataChanged = YES;
        ChannelValueChanged = YES;
    }
    
    if ( channel->EOL == 1 ) {
        [DiContainer.updateEventsManager emitChannelsUpdate];
        DataChanged = [UseCaseLegacyWrapper changeChannelsVisibilityFrom:2 to:0];
        [UseCaseLegacyWrapper startAsyncChannelsManager];
    }
    
    if ( DataChanged ) {
        [self onDataChanged];
        [DiContainer.updateEventsManager emitChannelUpdateWithRemoteId: channel->Id];
    }
    
    if ( ChannelValueChanged ) {
        [self onChannelValueChanged: channel->Id isGroup:NO];
    }
    
}

- (void) channelValueUpdate:(TSC_SuplaChannelValue_B *)channel_value {
    if ( [UseCaseLegacyWrapper updateChannelValueWithSuplaChannelValue: *channel_value] ) {
        [self onChannelValueChanged: channel_value->Id isGroup:NO];
        [self onDataChanged];
    }
    
    if (channel_value->EOL == 1) {
        [self onChannelGroupValueChanged];
    }
    
}

- (void) channelExtendedValueUpdate:(TSC_SuplaChannelExtendedValue *)channel_extendedvalue {
    NSLog(@"Extended value update for : %d", channel_extendedvalue->Id);
    if ( [UseCaseLegacyWrapper updateChannelExtendedValueWithSuplaChannelExtendedValue: *channel_extendedvalue] ) {
        [self onChannelValueChanged: channel_extendedvalue->Id isGroup:NO];
        [self onDataChanged];
    }
    
}

- (void) channelGroupUpdate:(TSC_SuplaChannelGroup_B *)cgroup {
    //NSLog(@"CGroup %i", cgroup->Id);
    
    BOOL DataChanged = NO;
    
    if ( [UseCaseLegacyWrapper updateGroupWithSuplaGroup: *cgroup] ) {
        DataChanged = YES;
    }
    
    if ( cgroup->EOL == 1 ) {
        [DiContainer.updateEventsManager emitGroupsUpdate];
        [self onChannelGroupValueChanged];
        DataChanged = [UseCaseLegacyWrapper changeGroupsVisibilityFrom:2 to:0];
    }
    
    if ( DataChanged ) {
        [self onDataChanged];
        [DiContainer.updateEventsManager emitGroupUpdateWithRemoteId: cgroup->Id];
    }
}

- (void) channelGroupRelationUpdate:(TSC_SuplaChannelGroupRelation *)cgroup_relation {
    BOOL DataChanged = NO;
    
    if ( [UseCaseLegacyWrapper updateGroupRelationWithSuplaGroupRelation: *cgroup_relation] ) {
        DataChanged = YES;
    }
    
    if ( cgroup_relation->EOL == 1
        && [UseCaseLegacyWrapper changeChannelGroupRelationsVisibilityFrom:2 to:0] ) {
        DataChanged = YES;
    }
    
    if (cgroup_relation->EOL == 1) {
        [self onChannelGroupValueChanged];
    }
    
    if ( DataChanged ) {
        [self onDataChanged];
    }
}

- (void) channelRelationUpdate: (TSC_SuplaChannelRelation *) relation {
    NSLog(@"Relation for channel `%i` setting parent to `%i` (S/EOL: %d)", relation->Id, relation->ParentId, relation->EOL);
    
    if ((relation->EOL & 0x2) > 0) {
        [UseCaseLegacyWrapper markChannelRelationsAsRemovable];
    }
    
    [UseCaseLegacyWrapper insertChannelRelationWithRelation: *relation];
    
    if ((relation->EOL & 0x1) > 0) {
        [UseCaseLegacyWrapper deleteRemovableRelations];
        [UseCaseLegacyWrapper reloadChannelToRootRelation];
        [DiContainer.updateEventsManager emitChannelsUpdate];
    }
}

- (void) sceneUpdate:(TSC_SuplaScene *)scene {
    
    BOOL DataChanged = NO;
    
    NSLog(@"Scene with ID: %i, caption: %@", scene->Id, [NSString stringWithUTF8String:scene->Caption]);
    
    if ( [UseCaseLegacyWrapper updateSceneWithScene: *scene] ) {
        DataChanged = YES;
    }
    
    if ( scene->EOL == 1 ) {
        [DiContainer.updateEventsManager emitScenesUpdate];
        DataChanged = [UseCaseLegacyWrapper changeScenesVisibilityFrom:2 to:0];
    }
    
    if ( DataChanged ) {
        [self onDataChanged];
    }
}

- (void) sceneStateUpdate:(TSC_SuplaSceneState *)state {
    NSLog(@"State update for scene with ID: %i", state->SceneId);
    if ([UseCaseLegacyWrapper updateSceneStateWithState: *state clientId:_client_id]) {
        NSLog(@"State for scene with ID: %i updated", state->SceneId);
        [self onDataChanged];
    }
}

- (void) onChannelConfigUpdateOrResult: (TSC_ChannelConfigUpdateOrResult*) config crc32: (unsigned _supla_int_t) crc32 {
    [UseCaseLegacyWrapper insertChannelConfig:config->Result :config->Config :crc32];
    [[DiContainer channelConfigEventsManager] emitConfigWithResult: config->Result config: config->Config crc32: crc32];
    if (config != nil && config->Result == SUPLA_CONFIG_RESULT_TRUE) {
        [[DiContainer updateEventsManager] emitChannelUpdateWithRemoteId: config->Config.ChannelId];
    }
}

- (void) onDeviceConfigUpdateOrResult: (TSC_DeviceConfigUpdateOrResult*) config {
    [[DiContainer deviceConfigEventsManager] emitConfigWithResult: config->Result config: config->Config];
}

- (void) _onEvent:(SAEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAEventNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[event] forKeys:@[@"event"]]];
}

- (void) onEvent:(SAEvent *)event {
    event.Owner = event.SenderID == _client_id;
    [self performSelectorOnMainThread:@selector(_onEvent:) withObject:event waitUntilDone:NO];
    
}

- (void) _onRegistrationEnabled:(SARegistrationEnabled *)reg_enabled {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegistrationEnabledNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[reg_enabled] forKeys:@[@"reg_enabled"]]];
}

- (void) onRegistrationEnabled:(SARegistrationEnabled *)reg_enabled {
    [self performSelectorOnMainThread:@selector(_onRegistrationEnabled:) withObject:reg_enabled waitUntilDone:NO];
}

- (void) _onSetRegistrationEnabledResultCode:(NSNumber *)code {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnSetRegistrationEnableResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[code] forKeys:@[@"code"]]];
}

- (void) onSetRegistrationEnabledResultCode:(int)code {
    [self performSelectorOnMainThread:@selector(_onSetRegistrationEnabledResultCode:) withObject:[NSNumber numberWithInt:code] waitUntilDone:NO];
}

- (void) _onOAuthTokenRequestResult:(SAOAuthToken *)token {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOAuthTokenRequestResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[token] forKeys:@[@"token"]]];
    
    [DiContainer setOAuthTokenWithToken: token];
}

- (void) onOAuthTokenRequestResult:(SAOAuthToken *)token {
    [self performSelectorOnMainThread:@selector(_onOAuthTokenRequestResult:) withObject:token waitUntilDone:NO];
}

- (void) _onSuperuserAuthorizationResult:(SASuperuserAuthorizationResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSASuperuserAuthorizationResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onSuperuserAuthorizationResult:(SASuperuserAuthorizationResult *)result {
    @synchronized(self) {
        _superuserAuthorized = result
        && result.success
        && result.code == SUPLA_RESULTCODE_AUTHORIZED;
    }
    
    [self performSelectorOnMainThread:@selector(_onSuperuserAuthorizationResult:) withObject:result waitUntilDone:NO];
}

- (void) _onCalCfgResult:(SACalCfgResult*)result  {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSACalCfgResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onCalCfgResult:(SACalCfgResult*)result {
    [self performSelectorOnMainThread:@selector(_onCalCfgResult:) withObject:result waitUntilDone:NO];
}

- (void) _onChannelState:(SAChannelStateExtendedValue*)state  {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnChannelState object:self userInfo:[[NSDictionary alloc] initWithObjects:@[state] forKeys:@[@"state"]]];
}

- (void) onChannelState:(SAChannelStateExtendedValue*)state {
    NSLog(@"Channel state update for: %d", state.channelId.intValue);
    [UseCaseLegacyWrapper updateChannelState:state.state channelId:state.state.ChannelID];
    [self onChannelValueChanged: state.channelId.intValue isGroup:NO];
    [self performSelectorOnMainThread:@selector(_onChannelState:) withObject:state waitUntilDone:NO];
}

- (void) _onChannelBasicCfg:(SAChannelBasicCfg*)cfg {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnChannelBasicCfg object:self userInfo:[[NSDictionary alloc] initWithObjects:@[cfg] forKeys:@[@"cfg"]]];
}

- (void) onChannelBasicCfg:(SAChannelBasicCfg*)cfg {
    [self performSelectorOnMainThread:@selector(_onChannelBasicCfg:) withObject:cfg waitUntilDone:NO];
}

- (void) _onChannelCaptionSetResult:(SAChannelCaptionSetResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnChannelCaptionSetResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onChannelCaptionSetResult:(SAChannelCaptionSetResult*)result {
    [self performSelectorOnMainThread:@selector(_onChannelCaptionSetResult:) withObject:result waitUntilDone:NO];
}

- (void) _onChannelGroupCaptionSetResult:(SAChannelCaptionSetResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnChannelGroupCaptionSetResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onChannelGroupCaptionSetResult:(SAChannelCaptionSetResult*)result {
    [self performSelectorOnMainThread:@selector(_onChannelGroupCaptionSetResult:) withObject:result waitUntilDone:NO];
}

- (void) _onChannelFunctionSetResult:(SAChannelFunctionSetResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnChannelFunctionSetResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onChannelFunctionSetResult:(SAChannelFunctionSetResult*)result {
    [self performSelectorOnMainThread:@selector(_onChannelFunctionSetResult:) withObject:result waitUntilDone:NO];
}

- (void) _onZwaveGetAssignedNodeIdResult:(SAZWaveNodeIdResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnZWaveAssignedNodeIdResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onZwaveGetAssignedNodeIdResult:(SAZWaveNodeIdResult*)result {
    [self performSelectorOnMainThread:@selector(_onZwaveGetAssignedNodeIdResult:) withObject:result waitUntilDone:NO];
}


- (void) _onZwaveGetNodeListResult:(SAZWaveNodeResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnZWaveNodeListResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onZwaveGetNodeListResult:(SAZWaveNodeResult*)result {
    [self performSelectorOnMainThread:@selector(_onZwaveGetNodeListResult:) withObject:result waitUntilDone:NO];
}

- (void) _onCalCfgProgressReport:(SACalCfgProgressReport*)report {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnCalCfgProgressReport object:self userInfo:[[NSDictionary alloc] initWithObjects:@[report] forKeys:@[@"report"]]];
}

- (void) onCalCfgProgressReport:(SACalCfgProgressReport*)report {
    [self performSelectorOnMainThread:@selector(_onCalCfgProgressReport:) withObject:report waitUntilDone:NO];
}

- (void) _onZWaveResetAndClearResult:(NSNumber*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnZWaveResetAndClearResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onZWaveResetAndClearResult:(NSNumber*)result {
    [self performSelectorOnMainThread:@selector(_onZWaveResetAndClearResult:) withObject:result waitUntilDone:NO];
}

- (void) _onZwaveAddNodeResult:(SAZWaveNodeResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnZWaveAddNodeResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onZwaveAddNodeResult:(SAZWaveNodeResult*)result {
    [self performSelectorOnMainThread:@selector(_onZwaveAddNodeResult:) withObject:result waitUntilDone:NO];
}

- (void) _onZwaveRemoveNodeResult:(SAZWaveNodeIdResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnZWaveRemoveNodeResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onZwaveRemoveNodeResult:(SAZWaveNodeIdResult*)result {
    [self performSelectorOnMainThread:@selector(_onZwaveRemoveNodeResult:) withObject:result waitUntilDone:NO];
}

- (void) _onZwaveOnAssignNodeIdResult:(SAZWaveNodeIdResult*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnZWaveAssignNodeIdResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onZwaveOnAssignNodeIdResult:(SAZWaveNodeIdResult*)result {
    [self performSelectorOnMainThread:@selector(_onZwaveOnAssignNodeIdResult:) withObject:result waitUntilDone:NO];
}

- (void) _onZwaveWakeupSettingsReport:(SAZWaveWakeupSettingsReport*)report {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnZWaveWakeupSettingsReport object:self userInfo:[[NSDictionary alloc] initWithObjects:@[report] forKeys:@[@"report"]]];
}

- (void) onZwaveWakeupSettingsReport:(SAZWaveWakeupSettingsReport*)report {
    [self performSelectorOnMainThread:@selector(_onZwaveWakeupSettingsReport:) withObject:report waitUntilDone:NO];
}

- (void) _onZWaveSetWakeUpTimeResult:(NSNumber*)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOnZWaveSetWakeUpTimeResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

- (void) onZWaveSetWakeUpTimeResult:(NSNumber*)result {
    [self performSelectorOnMainThread:@selector(_onZWaveSetWakeUpTimeResult:) withObject:result waitUntilDone:NO];
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

- (BOOL) cg:(int)ID Open:(char)open group:(BOOL)group {
    @synchronized(self) {
        if ( _sclient ) {
            return supla_client_open(_sclient, ID, group, open) == 1;
        }
    }
    
    return NO;
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

- (BOOL) deviceCalCfgRequest:(TCS_DeviceCalCfgRequest_B*)request {
    @synchronized(self) {
        if ( _sclient ) {
            return supla_client_device_calcfg_request(_sclient, request) == 1;
        }
    }
    
    return NO;
}

- (BOOL) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group data:(char*)data dataSize:(unsigned int)size {
    TCS_DeviceCalCfgRequest_B request;
    memset(&request, 0, sizeof(TCS_DeviceCalCfgRequest_B));
    request.Id = ID;
    request.Target = group ? SUPLA_TARGET_GROUP : SUPLA_TARGET_CHANNEL;
    request.Command = command;
    if (data && size > 0 && size <= SUPLA_CALCFG_DATA_MAXSIZE) {
        request.DataSize = size;
        memcpy(request.Data, data, size);
    }
    
    return [self deviceCalCfgRequest:&request];
}

- (BOOL) deviceCalCfgCommand:(int)command cg:(int)ID group:(BOOL)group {
    return [self deviceCalCfgCommand:command cg:ID group:group data:NULL dataSize:0];
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

- (void) superuserAuthorizationRequestWithEmail:(NSString*)email andPassword:(NSString*)password {
    @synchronized(self) {
        if ( _sclient ) {
            char eml[SUPLA_EMAIL_MAXSIZE] = {};
            char pwd[SUPLA_PASSWORD_MAXSIZE] = {};
            [email utf8StringToBuffer:eml withSize:sizeof(eml)];
            [password utf8StringToBuffer:pwd withSize:sizeof(pwd)];
            supla_client_superuser_authorization_request(_sclient, eml, pwd);
        }
    }
}

- (void) getSuperuserAuthorizationResult {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_get_superuser_authorization_result(_sclient);
        }
    }
}

- (BOOL) isSuperuserAuthorized {
    BOOL result = NO;
    @synchronized(self) {
        result = _superuserAuthorized;
    }
    
    return result;
}

- (void) channelStateRequestWithChannelId:(int)channelId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_get_channel_state(_sclient, channelId);
        }
    }
}

- (BOOL) getChannelConfig: (TCS_GetChannelConfigRequest*) configRequest {
    @synchronized (self) {
        if ( _sclient ) {
            return supla_client_get_channel_config(_sclient, configRequest) > 0;
        }
    }
    
    return false;
}

- (BOOL) setChannelConfig: (TSCS_ChannelConfig*) config {
    @synchronized (self) {
        if ( _sclient ) {
            return supla_client_set_channel_config(_sclient, config) > 0;
        }
    }
    
    return false;
}

- (BOOL) getDeviceConfig: (TCS_GetDeviceConfigRequest*) configRequest {
    @synchronized (self) {
        if ( _sclient ) {
            return supla_client_get_device_config(_sclient, configRequest);
        }
    }
    
    return false;
}

- (void) setLightsourceLifespanWithChannelId:(int)channelId resetCounter:(BOOL)reset setTime:(BOOL)setTime lifespan:(unsigned short)lifespan {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_set_lightsource_lifespan(_sclient, channelId, reset ? 1 : 0, setTime ? 1 : 0, lifespan);
        }
    }
}

- (void) setIODeviceRegistrationEnabledForTime:(int)iodevice_sec clientRegistrationEnabledForTime:(int)client_sec {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_set_registration_enabled(_sclient, iodevice_sec, client_sec);
        }
    }
}

- (void) setDgfTransparencyMask:(short)mask activeBits:(short)active_bits channelId:(int)channelId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_set_dgf_transparency(_sclient, channelId, mask, active_bits);
        }
    }
}

- (void) getChannelBasicCfg:(int)channelId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_get_channel_basic_cfg(_sclient, channelId);
        }
    }
}

- (void) setChannelCaption:(int)channelId caption:(NSString*)caption {
    @synchronized(self) {
        if ( _sclient ) {
            char _caption[SUPLA_CHANNEL_CAPTION_MAXSIZE] = {};
            [caption utf8StringToBuffer:_caption withSize:sizeof(_caption)];
            supla_client_set_channel_caption(_sclient, channelId, _caption);
        }
    }
}

- (void) setSceneCaption:(int)sceneId caption:(NSString*)caption {
    @synchronized(self) {
        if ( _sclient ) {
            char _caption[SUPLA_SCENE_CAPTION_MAXSIZE] = {};
            [caption utf8StringToBuffer:_caption withSize:sizeof(_caption)];
            supla_client_set_scene_caption(_sclient, sceneId, _caption);
        }
    }
}

- (void) setChannelGroupCaption:(int)channelGroupId caption:(NSString*)caption {
    @synchronized(self) {
        if ( _sclient ) {
            char _caption[SUPLA_CHANNEL_GROUP_CAPTION_MAXSIZE] = {};
            [caption utf8StringToBuffer:_caption withSize:sizeof(_caption)];
            supla_client_set_channel_group_caption(_sclient, channelGroupId, _caption);
        }
    }
}

- (void) setLocationCaption:(int)locationId caption:(NSString*)caption {
    @synchronized(self) {
        if ( _sclient ) {
            char _caption[SUPLA_LOCATION_CAPTION_MAXSIZE] = {};
            [caption utf8StringToBuffer:_caption withSize:sizeof(_caption)];
            supla_client_set_location_caption(_sclient, locationId, _caption);
        }
    }
}

- (void) setFunction:(int)function forChannelId:(int)channelId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_set_channel_function(_sclient, channelId, function);
        }
    }
}

- (void) zwaveGetAssignedNodeIdForChannelId:(int)channelId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_zwave_get_assigned_node_id(_sclient, channelId);
        }
    }
}

- (void) zwaveGetNodeListForDeviceId:(int)deviceId  {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_zwave_get_node_list(_sclient, deviceId);
        }
    }
}

- (void) zwaveCfgModeIsStillActiveForDeviceId:(int)deviceId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_zwave_config_mode_active(_sclient, deviceId);
        }
    }
}

- (void) deviceCalCfgCancelAllCommandsWithDeviceId:(int)deviceId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_device_calcfg_cancel_all_commands(_sclient, deviceId);
        }
    }
}

- (void) reconnectDeviceWithId:(int)deviceId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_reconnect_device(_sclient, deviceId);
        }
    }
}

- (void) zwaveResetAndClearSettingsWithDeviceId:(int)deviceId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_zwave_reset_and_clear(_sclient, deviceId);
        }
    }
}

- (void) zwaveAddNodeToDeviceWithId:(int)deviceId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_zwave_add_node(_sclient, deviceId);
        }
    }
}

- (void) zwaveRemoveNodeFromTheDeviceWithId:(int)deviceId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_zwave_remove_node(_sclient, deviceId);
        }
    }
}

- (void) zwaveAssignChannelId:(int)channelId toNodeId:(unsigned char)nodeId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_zwave_assign_node_id(_sclient, channelId, nodeId);
        }
    }
}

- (void) zwaveGetWakeUpSettingsForChannelId:(int)channelId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_zwave_get_wake_up_settings(_sclient, channelId);
        }
    }
}

- (void) zwaveSetWakeUpTime:(int)time forChannelId:(int)channelId {
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_zwave_set_wake_up_time(_sclient, channelId, time);
        }
    }
}

- (BOOL) turnOn:(BOOL)on remoteId:(int)remoteId group:(BOOL)group channelFunc:(int)channelFunc vibrate:(BOOL)vibrate {
    if ((channelFunc != SUPLA_CHANNELFNC_POWERSWITCH
         && channelFunc != SUPLA_CHANNELFNC_LIGHTSWITCH
         && channelFunc != SUPLA_CHANNELFNC_STAIRCASETIMER)) {
        return false;
    }
    
    
    if (on) {
        SADatabase *DB = [SADatabase alloc];
        if (DB == nil || [DB init] == nil) {
            return false;
        }
        
        SAChannel *channel = [DB fetchChannelById:remoteId];
        if (channel == nil) {
            return false;
        }
        
        if (![channel hiValue] && [channel overcurrentRelayOff]) {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"SUPLA"
                                         message:NSLocalizedString(@"The power was turned off after exceeding the set threshold of the allowable current. Are you sure you want to power on?", nil)
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesBtn = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Yes", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                if (vibrate) {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                }
                [self cg:remoteId Open:1 group:group];
            }];
            
            UIAlertAction* noBtn = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"No", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
            }];
            
            
            [alert setTitle: NSLocalizedString(@"Warning", nil)];
            [alert addAction:noBtn];
            [alert addAction:yesBtn];
            
            UIViewController *vc = [SuplaAppCoordinatorLegacyWrapper currentViewController];
            [vc presentViewController:alert animated:YES completion:nil];
            
            return true;
        }
    }
    
    if (vibrate) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    [self cg:remoteId Open:on ? 1 : 0 group:group];
    return true;
}

- (BOOL) executeAction: (int)actionId subjecType: (int)subjectType subjectId: (int)subjectId parameters: (void *) parameters length: (int) length {
    if (!_sclient) {
        return NO;
    }
    
    return supla_client_execute_action(_sclient, actionId, parameters, length, subjectType, subjectId) > 0;
}

- (BOOL) timerArmFor: (int) remoteId withTurnOn: (BOOL) on withTime: (int) milis {
    if (!_sclient) {
        return NO;
    }
    
    return supla_client_timer_arm(_sclient, remoteId, on ? 1 : 0, milis);
}

- (void) registerPushNotificationClientToken:(NSData *)token forProfile: (AuthProfileItem*) profile {
    @synchronized(self) {
        if ( _sclient ) {
            TCS_RegisterPnClientToken reg = [SingleCallWrapper prepareRegisterStructureFor: profile with: token];
            supla_client_pn_register_client_token(_sclient, &reg);
        }
    }
}

- (void) cancel {
    [super cancel];
    [SuplaAppStateHolderProxy cancel];
}

- (int) getServerTimeDiffInSec {
    return serverTimeDiffInSec;
}
@end
