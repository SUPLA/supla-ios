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
#import "SASuperuserAuthorizationDialog.h"
#import "NSNumber+SUPLA.h"
#import "SUPLA-Swift.h"
#import "AppDelegate.h"
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
NSString *kChannelHeightDidChange = @"ChannelHeightDidChange";

@implementation SAApp {
    
    int _cfg_ver;
    int _current_access_id;
    NSString *_current_server;
    NSString *_current_email;
    
    SASuplaClient* _SuplaClient;
    SADatabase *_DB;
    NSMutableArray *_RestApiClientTasks;
    SAOAuthToken *_OAuthToken;
}

-(id)init {
    self = [super init];
    if ( self ) {
        _cfg_ver = 0;
        _current_access_id = 0;
        _current_server = nil;
        
        signal(SIGPIPE, SIG_IGN);
        
        _RestApiClientTasks = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onDisconnected)
         name:kSADisconnectedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onConnecting)
         name:kSAConnectingNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onConnected)
         name:kSAConnectedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onConnError:)
         name:kSAConnErrorNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onRegistering)
         name:kSARegisteringNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onRegistered:)
         name:kSARegisteredNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onRegisterError:)
         name:kSARegisterErrorNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onVersionError:)
         name:kSAVersionErrorNotification object:nil];
        
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

+(id<NavigationCoordinator>)currentNavigationCoordinator {
    return [[((AppDelegate *)[UIApplication sharedApplication].delegate) navigation]
            currentCoordinator];
}

+(MainNavigationCoordinator*)mainNavigationCoordinator {
    id coordinator = [((AppDelegate *)[UIApplication sharedApplication].delegate) navigation];
    if([coordinator isKindOfClass:[MainNavigationCoordinator class]]) {
        return (MainNavigationCoordinator*)coordinator;
    } else {
        return nil;
    }
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

+ (id<ProfileManager>)profileManager {
    return [[MultiAccountProfileManager alloc] initWithContext: [[self instance] DB]
            .managedObjectContext];
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

+(BOOL) configIsSet {
    return [SAApp.profileManager getCurrentAuthInfo]
        .isAuthDataComplete;
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
    [self SuplaClientWithOneTimePassword:nil];
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
    
    while([[self instance] SuplaClientTerminate]) {
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
    NSString *hostname = [SAApp.profileManager getCurrentAuthInfo]
        .serverForCurrentAuthMethod;
    if ( [[hostname lowercaseString] containsString:@"supla.org"] ) {
        return @"cloud.supla.org";
    } else {
        return hostname;
    }
}

-(BOOL)canChangeView {
    NSObject<NavigationCoordinator> *nav = [SAApp currentNavigationCoordinator];
    if(nav == [SAApp mainNavigationCoordinator] ||
       ([nav isKindOfClass: [PresentationNavigationCoordinator class]] &&
        [nav.viewController isKindOfClass: [SAStatusVC class]]))
        return YES;
    else
        return NO;
//    return [self.UI addWizardIsVisible] != YES && [self.UI createAccountVCisVisible] != YES && ![self.UI settingsVCisVisible];
    
}

-(void)onDisconnected {
    if ( ![self canChangeView] ) {
        return;
    }
    
    [[SAApp mainNavigationCoordinator] showStatusViewWithProgress: @-1];
}

-(void)onConnecting {
    if ( ![self canChangeView] ) {
        return;
    }
    [[SAApp mainNavigationCoordinator] showStatusViewWithProgress:@0.25];
}

-(void)onConnected {
    if ( ![self canChangeView] ) {
        return;
    }
    [[SAApp mainNavigationCoordinator] showStatusViewWithProgress:@0.5];
}

-(void)onConnError:(NSNotification *)notification {
    if ( ![self canChangeView] ) {
        return;
    }
    
    NSNumber *code = [NSNumber codeNotificationToNumber:notification];
    
    if ( code && [code intValue] == SUPLA_RESULTCODE_HOSTNOTFOUND ) {
        
        [self SuplaClientTerminate];
        [[SAApp mainNavigationCoordinator] showStatusViewWithError:NSLocalizedString(@"Host not found. Make sure you are connected to the internet and that an account with the entered email address has been created.", nil) completion: nil];
    }
}

-(void)onRegistering {
    if ( ![self canChangeView] ) {
        return;
    }
    
    [[SAApp mainNavigationCoordinator] showStatusViewWithProgress:@0.75];
}

-(void)onRegistered:(NSNotification *)notification {
    if ( ![self canChangeView] ) {
        return;
    }
    
    [[SAApp mainNavigationCoordinator] showStatusViewWithProgress:@1];
}

-(void)onRegisterError:(NSNotification *)notification {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    [self SuplaClientTerminate];
    
    NSNumber *code = [NSNumber codeNotificationToNumber:notification];
    [[SAApp mainNavigationCoordinator] showStatusViewWithError:[SASuplaClient codeToString:code]
                                                    completion: ^{
        int cint = [code intValue];
        
        AuthProfileItem *profile = [SAApp.profileManager getCurrentProfile];
        if ((cint == SUPLA_RESULTCODE_REGISTRATION_DISABLED
            || cint == SUPLA_RESULTCODE_ACCESSID_NOT_ASSIGNED)
            && profile.authInfo.isAuthDataComplete
            && profile.authInfo.emailAuth
            && ![SASuperuserAuthorizationDialog.globalInstance isVisible]) {
            [SASuperuserAuthorizationDialog.globalInstance authorizeWithDelegate:nil];
        }
    }];
    
}

-(void)onVersionError:(NSNotification *)notification {
    
    if ( ![self canChangeView] ) {
        return;
    }
    
    [self SuplaClientTerminate];
    
    [[SAApp mainNavigationCoordinator] showStatusViewWithError: NSLocalizedString(@"Incompatible server version", nil)
                                                    completion: nil];
}

-(void)onOAuthTokenRequestResult:(NSNotification *)notification {
    SAOAuthToken *token = [SAOAuthToken notificationToToken:notification];
    
    @synchronized (self) {
        NSEnumerator *e = [_RestApiClientTasks objectEnumerator];
        SARestApiClientTask *cli;
        _OAuthToken = token;
        while (cli = [e nextObject]) {
            cli.token = token;
        }
    }
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

- (void) revokeOAuthToken {
    @synchronized (self) {
        _OAuthToken = nil;
    }
}

+ (void) revokeOAuthToken {
    [[self instance] revokeOAuthToken];
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
