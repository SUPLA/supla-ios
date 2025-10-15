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
#import "SASuperuserAuthorizationDialog.h"
#import "NSNumber+SUPLA.h"
#import "SUPLA-Swift.h"
#import "AuthProfileItem+CoreDataClass.h"

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
NSString *kSASuperuserAuthorizationNotification = @"KSA-N14";

NSString *kSAOAuthTokenRequestResult = @"KSA-N13";
NSString *kSASuperuserAuthorizationResult = @"KSA-N14";
NSString *kSACalCfgResult = @"KSA-N15";
NSString *kSAMenubarBackButtonPressed = @"KSA-N16";
NSString *kSAOnChannelState = @"KSA-N17";
NSString *kSAOnSetRegistrationEnableResult = @"KSA-N18";
NSString *kSAOnChannelBasicCfg = @"KSA-N19";
NSString *kSAOnChannelCaptionSetResult = @"KSA-N20";
NSString *kSAOnChannelFunctionSetResult = @"KSA-N21";
NSString *kSAOnZWaveAssignedNodeIdResult = @"KSA-N22";
NSString *kSAOnZWaveNodeListResult = @"KSA-N23";
NSString *kSAOnCalCfgProgressReport = @"KSA-N24";
NSString *kSAOnZWaveResetAndClearResult = @"KSA-N25";
NSString *kSAOnZWaveAddNodeResult = @"KSA-N26";
NSString *kSAOnZWaveRemoveNodeResult = @"KSA-N27";
NSString *kSAOnZWaveAssignNodeIdResult = @"KSA-N28";
NSString *kSAOnZWaveWakeupSettingsReport = @"KSA-N29";
NSString *kSAOnZWaveSetWakeUpTimeResult = @"KSA-N30";
NSString *kSAOnChannelGroupCaptionSetResult = @"OnChannelGroupCaptionSetResult";

@implementation SAApp {
    
    int _cfg_ver;
    int _current_access_id;
    NSString *_current_server;
    NSString *_current_email;
    
    SASuplaClient* _SuplaClient;
    SADatabase *_DB;
    SAOAuthToken *_OAuthToken;
}

-(id)init {
    self = [super init];
    if ( self ) {
        _cfg_ver = 0;
        _current_access_id = 0;
        _current_server = nil;
        
        signal(SIGPIPE, SIG_IGN);
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onOAuthTokenRequestResult:)
         name:kSAOAuthTokenRequestResult object:nil];
    
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
                if ([SAKeychain add:data withKey:pref_key]) {
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

+ (id<ProfileManager>)profileManager {
    return [[MultiAccountProfileManager alloc] init];
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


+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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

-(SASuplaClient*) SuplaClientWithOneTimePassword:(NSString *)password {
    
    SASuplaClient *result = nil;
    
    @synchronized(self) {
        
        if ( _SuplaClient == nil) {
            
            _SuplaClient = [[SASuplaClient alloc] initWithOneTimePassword:password];
            _SuplaClient.delegate = self;
            [_SuplaClient start];
        }
        
        result = _SuplaClient;
    }
    
    return result;
    
}

-(BOOL) isClientRegistered {
    BOOL result = NO;
    
    @synchronized(self) {
        if ( _SuplaClient != nil) {
            result = [_SuplaClient isRegistered];
        }
    }
    
    return result;
    
}

-(BOOL) isClientWorking {
    BOOL result = NO;
    
    @synchronized(self) {
        if ( _SuplaClient != nil) {
            result = ![_SuplaClient isCancelled];
        }
    }
    
    return result;
}

-(SASuplaClient *) optionalSuplaClient {
    @synchronized(self) {
        if ( _SuplaClient != nil) {
            return _SuplaClient;
        }
    }
    
    return nil;
    
}

-(BOOL) isClientAuthorized {
    BOOL result = NO;
    @synchronized(self) {
        if ( _SuplaClient != nil) {
            result = [_SuplaClient isRegistered] && [_SuplaClient isSuperuserAuthorized];
        }
    }
    
    return result;
}

+(SASuplaClient*) SuplaClient {
    return [[self instance] SuplaClientWithOneTimePassword:nil];
}

+(SASuplaClient *) SuplaClientWithOneTimePassword:(NSString*)password {
    return [[self instance] SuplaClientWithOneTimePassword:password];
}

+(BOOL) isClientRegistered {
    return [[self instance] isClientRegistered];
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

-(void)onSuplaClientTerminated:(SASuplaClient*)client {
    @synchronized(self) {
        if ( _SuplaClient == client ) {
            _SuplaClient = nil;
        }
    }
}

+(void) SuplaClientTerminate {
    [[self instance] SuplaClientTerminate];
}

+(void) SuplaClientWaitForTerminate {
    
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow: 3];
    BOOL working = [[self instance] SuplaClientTerminate];
    
    while(working && [[self instance] isClientWorking]) {
        @autoreleasepool {
            NSDate *cDate = [NSDate date];
            if([cDate earlierDate: deadline] == deadline)
                break;
            else
                [[NSRunLoop currentRunLoop] runUntilDate: cDate];
        }
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

+(SADatabase*)DB {
    return [[self instance] DB];
}

-(NSString*)getMsgHostName {
    AuthProfileItem *profile = [SAApp.profileManager getCurrentProfile];
    if (profile == nil) {
        return @"";
    }
    
    SAProfileServer *server = profile.server;
    if (server == nil) {
        return @"";
    }
    
    NSString *hostname = server.address;
    if (hostname == nil) {
        return @"";
    }
    
    if ( [[hostname lowercaseString] containsString:@"supla.org"] ) {
        return @"cloud.supla.org";
    } else {
        return hostname;
    }
}

-(void)onOAuthTokenRequestResult:(NSNotification *)notification {
    SAOAuthToken *token = [SAOAuthToken notificationToToken:notification];
    @synchronized (self) {
        _OAuthToken = token;
    }
}

- (void) revokeOAuthToken {
    @synchronized (self) {
        _OAuthToken = nil;
    }
}

+ (void) revokeOAuthToken {
    [[self instance] revokeOAuthToken];
}

+(void) abstractMethodException:(NSString *)methodName {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", methodName];
}
@end
