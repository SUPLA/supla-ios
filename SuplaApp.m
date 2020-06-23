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


#import "SuplaApp.h"
#import "Database.h"
#import "NSData+AES.h"
#import "SAKeychain.h"

static SAApp* _Globals = nil;

NSString *kSADataChangedNotification = @"kSA-N01";
NSString *kSAConnectingNotification = @"kSA-N02";
NSString *kSARegisteredNotification = @"kSA-N03";
NSString *kSARegisteringNotification = @"kSA-N04";
NSString *kSARegisterErrorNotification = @"kSA-N05";
NSString *kSADisconnectedNotification = @"kSA-N06";
NSString *kSAConnectedNotification = @"kSA-N07";
NSString *kSAVersionErrorNotification = @"kSA-N08";
NSString *kSAEventNotification = @"kSA-N09";
NSString *kSAConnErrorNotification = @"kSA-N10";
NSString *kSAChannelValueChangedNotification = @"KSA-N11";
NSString *kSARegistrationEnabledNotification = @"KSA-N12";
NSString *kSAOAuthTokenRequestResult = @"KSA-N13";
NSString *kSASuperuserAuthorizationResult = @"KSA-N14";
NSString *kSACalCfgResult = @"KSA-N15";
NSString *kSAMenubarBackButtonPressed = @"KSA-N16";

@implementation SAApp {
    
    int _cfg_ver;
    int _current_access_id;
    NSString *_current_server;
    NSString *_current_email;
    
    SASuplaClient* _SuplaClient;
    SADatabase *_DB;
    SAUIHelper *_UI;
    NSMutableArray *_RestApiClientTasks;
    SAOAuthToken *_OAuthToken;
}

-(id)init {
    self = [super init];
    if ( self ) {
        _cfg_ver = 0;
        _current_access_id = 0;
        _current_server = nil;
        
        if ( [self getCfgVersion] == 0 ) {
          
            BOOL advCfg = [[self getServerHostName] isEqualToString:@""] == NO && [self getAccessID] != 0 && [[SAApp getAccessIDpwd] isEqualToString:@""] == NO;
            [self setAdvancedConfig: advCfg];
            [self setCfgVersion:2];
        };

        _RestApiClientTasks = [[NSMutableArray alloc] init];
    }
    return self;
}

+(SAApp*)instance {
     @synchronized(self) {
         if ( _Globals == nil ) {
             _Globals = [[SAApp alloc] init];
         }
     }
    
    return _Globals;
}

-(BOOL) getRandom:(char*)key size:(int)size forPrefKey:(NSString*)pref_key {
    
    @synchronized(self) {
        NSData *data = nil;
        BOOL keychainStored = NO;
        
        data = [SAKeychain getObjectWithKey:pref_key];
       
        if (data == nil
            || ![data isKindOfClass:[NSData class]]
            || data.length != size) {
            
            if ([[NSUserDefaults standardUserDefaults]
                 boolForKey:[NSString stringWithFormat:@"%@_keychain", pref_key]]) {
                // Something goes wrong
                // Maybe beacuse of kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                return false;
            }
            
            data = [[NSUserDefaults standardUserDefaults] dataForKey:pref_key];
                    
            if (data != nil
                && data.length > 0
                && [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_encrypted", pref_key]]) {
                data = [data aes128DecryptWithDeviceUniqueId];
                
                // After the device has been restarted but before
                // the user has unlocked the device, dectyption result
                // can be null beacuse of identifierForVendor.
                
                if (data == nil || data.length == 0) {
                    return false;
                }
            }
            
        } else {
            keychainStored = YES;
        }
        
        if ( data == nil || data.length != size ) {
            NSMutableData* newRandomData = [NSMutableData dataWithCapacity:size];
            for( int i = 0 ; i < size; ++i ) {
                Byte random = arc4random();
                [newRandomData appendBytes:(void*)&random length:1];
            }
            
            keychainStored = NO;
            data = newRandomData;
        }
        
        if ( data && [data length] == size ) {
            [data getBytes:key length:size];
            
            if (!keychainStored) {
                [SAKeychain deleteObjectWithKey:pref_key];
                if ([SAKeychain addObject:data withKey:pref_key]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@_keychain", pref_key]];
                }
            }
            
            return true;
        } else {
            memset(key, 0, size);
        }
    }
    
    return false;
}

+(BOOL) getClientGUID:(char[SUPLA_GUID_SIZE])guid {
   return [[self instance] getRandom:guid size:SUPLA_GUID_SIZE forPrefKey:@"client_guid"];
}

+(BOOL) getAuthKey:(char [SUPLA_AUTHKEY_SIZE])auth_key {
   return [[self instance] getRandom:auth_key size:SUPLA_AUTHKEY_SIZE forPrefKey:@"auth_key"];
}

-(int) getCfgVersion {
    
    
    @synchronized(self) {
        if ( _cfg_ver == 0 ) {
            _cfg_ver = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"cfg_version"];
        }
    }
    
    return _cfg_ver;
}

-(void) setCfgVersion:(int)cfg_ver {
    
    @synchronized(self) {
        _cfg_ver = cfg_ver;
        [[NSUserDefaults standardUserDefaults] setInteger:cfg_ver forKey:@"cfg_version"];
    }
    
}

-(BOOL) isAdvancedConfig {
    
    BOOL result = NO;
    
    @synchronized(self) {
        result = [[NSUserDefaults standardUserDefaults] boolForKey:@"advanced_config"];
    }
    
    return result;
}

+(BOOL) isAdvancedConfig {
    
    return [[self instance] isAdvancedConfig];
}

-(void) setAdvancedConfig:(BOOL)adv_cfg {
    
    @synchronized(self) {
        [[NSUserDefaults standardUserDefaults] setBool:adv_cfg forKey:@"advanced_config"];
    }
    
}

+(void) setAdvancedConfig:(BOOL)adv_cfg {
    
    [[self instance] setAdvancedConfig:adv_cfg];
    
}


-(int) getAccessID {
    
    
    @synchronized(self) {
        if ( _current_access_id == 0 ) {
            _current_access_id = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"access_id"];
        }
    }
    
    return _current_access_id;
}

+(int) getAccessID {
    
    return [[self instance] getAccessID];
}

-(void) setAccessID:(int)aid {
    
    @synchronized(self) {
        _current_access_id = aid;
        [[NSUserDefaults standardUserDefaults] setInteger:aid forKey:@"access_id"];
    }
    
}

+(void) setAccessID:(int)aid {
    
    [[self instance] setAccessID:aid];
    
}

+(NSString*) getAccessIDpwd {
    NSString *result = nil;
    
    @synchronized(self) {
        result = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_id_pwd"];
    }
    
    return result == nil ? [[NSString alloc] init] : result;
}

+(void) setAccessIDpwd:(NSString *)pwd {
    pwd = [pwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    @synchronized(self) {
        [[NSUserDefaults standardUserDefaults] setValue:pwd forKey:@"access_id_pwd"];
    }
    
}

-(NSString*) getServerHostName {
    
    @synchronized(self) {
        if ( _current_server == nil ) {
            _current_server = [[NSUserDefaults standardUserDefaults] stringForKey:@"server_host"];
        }
    }
    
    return _current_server == nil ? [[NSString alloc] init] : _current_server;
}

+(NSString*) getServerHostName {
    
    return [[self instance] getServerHostName];
}

-(void) setServerHostName:(NSString *)hostname {
    hostname = [hostname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    @synchronized(self) {
        [[NSUserDefaults standardUserDefaults] setValue:hostname forKey:@"server_host"];
        _current_server = hostname;
    }
    
}

+(void) setServerHostName:(NSString *)hostname {
    
    [[self instance] setServerHostName:hostname];
    
}


-(NSString*) getEmailAddress {
    
    @synchronized(self) {
        if ( _current_email == nil ) {
            _current_email = [[NSUserDefaults standardUserDefaults] stringForKey:@"email_address"];
        }
    }
    
    return _current_email == nil ? [[NSString alloc] init] : _current_email;
}

+(NSString*) getEmailAddress {
    
    return [[self instance] getEmailAddress];
}

-(void) setEmailAddress:(NSString *)email {
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    @synchronized(self) {
        [[NSUserDefaults standardUserDefaults] setValue:email forKey:@"email_address"];
        _current_email = email;
    }
    
}

+(void) setEmailAddress:(NSString *)email {
    
    [[self instance] setEmailAddress:email];
    
}

-(int)getPreferedProtocolVersion {
    
    int result = 0;
    
    @synchronized(self) {
       result = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"pref_proto_version"];
    }
    
    return result == 0 ? SUPLA_PROTO_VERSION : result;
}

+(int) getPreferedProtocolVersion {
   return [[self instance] getPreferedProtocolVersion];
}

-(void)setPreferedProtocolVersion:(int)version {
        
    @synchronized(self) {
        [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"pref_proto_version"];
    }
}

-(void) setBrightnessPickerTypeToSlider:(BOOL)slider {
    @synchronized(self) {
       [[NSUserDefaults standardUserDefaults] setBool:slider forKey:@"pref_brightness_picker_type_slider"];
    }
}

-(BOOL) isBrightnessPickerTypeSet {
    BOOL result = 0;
    
    @synchronized(self) {
       result = [[NSUserDefaults standardUserDefaults] objectForKey:@"pref_brightness_picker_type_slider"] != nil;
    }
    
    return result;
}

-(BOOL) isBrightnessPickerTypeSlider {
    BOOL result = 0;
    
    @synchronized(self) {
       result = [[NSUserDefaults standardUserDefaults] boolForKey:@"pref_brightness_picker_type_slider"];
    }
    
    return result;
}

+(void) setPreferedProtocolVersion:(int)version {
    [[self instance] setPreferedProtocolVersion: version];
}

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+(BOOL) configIsSet {
    if ( [SAApp isAdvancedConfig] ) {
        return ![[SAApp getServerHostName] isEqual:@""] && [SAApp getAccessID] != 0 && ![[SAApp getAccessIDpwd] isEqual:@""];
    }
    
    return ![[SAApp getEmailAddress] isEqual:@""];
}

+(void) setBrightnessPickerTypeToSlider:(BOOL)slider {
    [[self instance] setBrightnessPickerTypeToSlider:slider];
}

+(BOOL) isBrightnessPickerTypeSet {
    return [[self instance] isBrightnessPickerTypeSet];
}

+(BOOL) isBrightnessPickerTypeSlider {
   return [[self instance] isBrightnessPickerTypeSlider];
}

-(void)onInitTimer:(NSTimer *)timer {
    [self SuplaClient];
}


-(void)initClientDelayed:(double)time {
    
    @synchronized(self) {
        
        if ( _SuplaClient == nil ) {
            [NSTimer scheduledTimerWithTimeInterval:time
                                                     target:self
                                                     selector:@selector(onInitTimer:)
                                                     userInfo:nil
                                                     repeats:NO];
        }

    }
    
}

+(void)initClientDelayed:(double)time {
    [[self instance] initClientDelayed:time];
}

-(SASuplaClient*) SuplaClient {
    
    SASuplaClient *result = nil;
    
    @synchronized(self) {
        
        if ( _SuplaClient == nil ) {
            
            _SuplaClient = [[SASuplaClient alloc] init];
            [_SuplaClient start];
        }
        
        result = _SuplaClient;
    }
    
    return result;
    
}

+(SASuplaClient*) SuplaClient {
    return [[self instance] SuplaClient];
}

-(BOOL) SuplaClientTerminate {
    
    BOOL result = NO;
    
    @synchronized(self) {
        if ( _SuplaClient != nil ) {
            [_SuplaClient cancel];
            result = YES;
        }
    }
    
    return result;
}

-(void)onTerminated:(SASuplaClient*)sender {
    
    @synchronized(self) {
        if ( _SuplaClient == sender ) {
            _SuplaClient = nil;
        }
    }
    
}

+(void) SuplaClientTerminate {
    [[self instance] SuplaClientTerminate];
}

+(void) SuplaClientWaitForTerminate {
    
    while([[self instance] SuplaClientTerminate]) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    }
    
}

-(BOOL) SuplaClientConnected {
    return _SuplaClient != nil && [_SuplaClient isConnected];
}


+(BOOL) SuplaClientConnected {
    return [[self instance] SuplaClientConnected];
}

-(SADatabase*)DB {
    
    if ( _DB == nil ) {
        _DB = [[SADatabase alloc] init];
        [_DB initSaveObserver];
    }
    
    return _DB;
}

-(SAUIHelper *)UI {
    
    if ( _UI == nil ) {
        _UI = [[SAUIHelper alloc] init];
    }
    
    return _UI;
}

+(SAUIHelper *)UI {
    return [[self instance] UI];
}


+(SADatabase*)DB {
    return [[self instance] DB];
}


-(void)onDisconnected {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    [self.UI.StatusVC.progress setProgress:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSADisconnectedNotification object:self userInfo:nil];
}

-(void)onConnecting {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    if ( self.UI.rootViewController == self.UI.SettingsVC ) {
         [self.UI.StatusVC.progress setProgress:0.25];
    } else {
         [self.UI showStatusConnectingProgress:0.25];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAConnectingNotification object:self userInfo:nil];
}

-(void)onConnected {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    [self.UI showStatusConnectingProgress:0.5];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAConnectedNotification object:self userInfo:nil];
}

-(void)onConnError:(NSNumber*)code {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    if ( [code intValue] == SUPLA_RESULTCODE_HOSTNOTFOUND ) {
        
        [self SuplaClientTerminate];
        [self.UI showStatusError:NSLocalizedString(@"Host not found", nil)];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAConnErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[code] forKeys:@[@"code"]]];
    
    
}

-(void)onRegistering {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    [self.UI showStatusConnectingProgress:0.75];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegisteringNotification object:self userInfo:nil];
}

-(void)onRegistered:(SARegResult*)result {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    [self.UI showStatusConnectingProgress:1];
    [self.UI showMainVC];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegisteredNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}


-(NSString*)getMsgHostName {
    NSString *hostname = [SAApp getServerHostName];
    if ( [[hostname lowercaseString] containsString:@"supla.org"] ) {
        return @"cloud.supla.org";
    } else {
        return hostname;
    }
}

-(void)onRegisterError:(NSNumber*)code {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    [self SuplaClientTerminate];
    
    NSString *msg = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"Unknown error", nil), code];
    
    switch([code intValue]) {
        case SUPLA_RESULTCODE_TEMPORARILY_UNAVAILABLE:
            msg = NSLocalizedString(@"Service temporarily unavailable", nil);
            break;
        case SUPLA_RESULTCODE_BAD_CREDENTIALS:
            msg = NSLocalizedString(@"Bad credentials", nil);
            break;
        case SUPLA_RESULTCODE_CLIENT_LIMITEXCEEDED:
            msg = NSLocalizedString(@"Client limit exceeded", nil);
            break;
        case SUPLA_RESULTCODE_CLIENT_DISABLED:
            msg = NSLocalizedString(@"Device is disabled", nil);
            break;
        case SUPLA_RESULTCODE_ACCESSID_DISABLED:
            msg = NSLocalizedString(@"Access Identifier is disabled", nil);
            break;
        case SUPLA_RESULTCODE_REGISTRATION_DISABLED:
            msg = [NSString stringWithFormat:NSLocalizedString(@"Client Registration is off. Please go to \"Smartphone\" at %@ to activate it.", nil), [self getMsgHostName]];
            break;
        case SUPLA_RESULTCODE_ACCESSID_NOT_ASSIGNED:
            msg = [NSString stringWithFormat:NSLocalizedString(@"This client does not have access identifier assigned. Please go to \"Smartphone\" at %@ and get a valid identifier.", nil), [self getMsgHostName]];
            break;
            
    }
    
    [self.UI showStatusError:msg];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegisterErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[code] forKeys:@[@"code"]]];
    
}

-(BOOL)canChangeView {
    return [self.UI addWizardIsVisible] != YES && [self.UI createAccountVCisVisible] != YES && ![self.UI settingsVCisVisible];
    
}
-(void)onVersionError:(SAVersionError*)ve {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    [self SuplaClientTerminate];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAVersionErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[ve] forKeys:@[@"version_error"]]];
    
    [self.UI showStatusError:NSLocalizedString(@"Incompatible server version", nil)];
}

-(void)onEvent:(SAEvent*)event {
     [[NSNotificationCenter defaultCenter] postNotificationName:kSAEventNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[event] forKeys:@[@"event"]]];
}

-(void)onRegistrationEnabled:(SARegistrationEnabled*)reg_enabled {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegistrationEnabledNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[reg_enabled] forKeys:@[@"reg_enabled"]]];
}

-(void)onDataChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSADataChangedNotification object:self userInfo:nil];
}

-(void)onChannelValueChanged:(NSNumber*)ChannelId isGroup:(NSNumber*)group {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAChannelValueChangedNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[ChannelId, group] forKeys:@[@"remoteId", @"isGroup"]]];
}

-(void)onOAuthTokenRequestResult:(SAOAuthToken *)token {
    
    @synchronized (self) {
        NSEnumerator *e = [_RestApiClientTasks objectEnumerator];
        SARestApiClientTask *cli;
        _OAuthToken = token;
        while (cli = [e nextObject]) {
            cli.token = token;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAOAuthTokenRequestResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[token] forKeys:@[@"token"]]];
}

-(void)onSuperuserAuthorizationResult:(SASuperuserAuthorizationResult *)result {
     [[NSNotificationCenter defaultCenter] postNotificationName:kSASuperuserAuthorizationResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

-(void)onCalCfgResult:(SACalCfgResult *)result {
     [[NSNotificationCenter defaultCenter] postNotificationName:kSACalCfgResult object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

-(SAOAuthToken*) registerRestApiClientTask:(SARestApiClientTask *)task {
    SAOAuthToken *result = nil;
    
    @synchronized (self) {
        if ( _OAuthToken != nil && [_OAuthToken isAlive]) {
            result = _OAuthToken;
        }
        
        [_RestApiClientTasks addObject:task];
    }
    
    return result;
}

- (void) unregisterRestApiClientTask:(SARestApiClientTask *)task {
    @synchronized (self) {
        [_RestApiClientTasks removeObject:task];
    }
}

-(void) cancelAllRestApiClientTasks {
    @synchronized (self) {
        NSEnumerator *e = [_RestApiClientTasks objectEnumerator];
        SARestApiClientTask *cli;
        while (cli = [e nextObject]) {
            [cli cancel];
        }
    }
}

+(void) abstractMethodException:(NSString *)methodName {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", methodName];
}

@end
