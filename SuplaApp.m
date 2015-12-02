/*
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
 
 Author: Przemyslaw Zygmunt p.zygmunt@acsoftware.pl [AC SOFTWARE]
 */


#import "SuplaApp.h"
#import "Database.h"


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

@implementation SAApp {
    
    int _current_access_id;
    NSString *_current_server;
    
    SASuplaClient* _SuplaClient;
    SADatabase *_DB;
    SAUIHelper *_UI;
}

-(id)init {
    self = [super init];
    if ( self ) {
        _current_access_id = 0;
        _current_server = nil;

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

+(void) getClientGUID:(char[SUPLA_GUID_SIZE])guid {

    @synchronized(self) {
        
        NSData *GUID = [[NSUserDefaults standardUserDefaults] dataForKey:@"client_guid"];
        if ( GUID == nil || [GUID length] != SUPLA_GUID_SIZE ) {
           
            NSMutableData* newGUID = [NSMutableData dataWithCapacity:SUPLA_GUID_SIZE];
            for( int i = 0 ; i < SUPLA_GUID_SIZE; ++i ) {
                Byte random = arc4random();
                [newGUID appendBytes:(void*)&random length:1];
            }
            
            [[NSUserDefaults standardUserDefaults] setValue:newGUID forKey:@"client_guid"];
            GUID = newGUID;
        };
        
        if ( GUID && [GUID length] == SUPLA_GUID_SIZE ) {
            [GUID getBytes:guid length:SUPLA_GUID_SIZE];
        } else {
            memset(guid, 0, SUPLA_GUID_SIZE);
        }
    
    }

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
    
    @synchronized(self) {
        [[NSUserDefaults standardUserDefaults] setValue:hostname forKey:@"server_host"];
        _current_server = hostname;
    }
    
}

+(void) setServerHostName:(NSString *)hostname {
    
    [[self instance] setServerHostName:hostname];
    
}

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
    [self.UI.StatusVC.progress setProgress:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSADisconnectedNotification object:self userInfo:nil];
}

-(void)onConnecting {
    if ( self.UI.rootViewController == self.UI.SettingsVC ) {
         [self.UI.StatusVC.progress setProgress:0.25];
    } else {
         [self.UI showStatusConnectingProgress:0.25];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAConnectingNotification object:self userInfo:nil];
}

-(void)onConnected {
    [self.UI showStatusConnectingProgress:0.5];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAConnectedNotification object:self userInfo:nil];
}

-(void)onRegistering {
    [self.UI showStatusConnectingProgress:0.75];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegisteringNotification object:self userInfo:nil];
}

-(void)onRegistered:(SARegResult*)result {
    [self.UI showStatusConnectingProgress:1];
    [self.UI showMainVC];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegisteredNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[result] forKeys:@[@"result"]]];
}

-(void)onRegisterError:(NSNumber*)code {
    
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
        case SUPLA_RESULTCODE_ACCESSID_DISABLED:
            msg = NSLocalizedString(@"Access disabled", nil);
            break;
    }

    [self.UI showStatusError:msg];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSARegisterErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[code] forKeys:@[@"code"]]];

}


-(void)onVersionError:(SAVersionError*)ve {
    
    [self SuplaClientTerminate];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSAVersionErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[ve] forKeys:@[@"version_error"]]];
    
    [self.UI showStatusError:NSLocalizedString(@"Incompatible server version", nil)];
}

-(void)onEvent:(SAEvent*)event {
     [[NSNotificationCenter defaultCenter] postNotificationName:kSAEventNotification object:self userInfo:[[NSDictionary alloc] initWithObjects:@[event] forKeys:@[@"event"]]];
}

-(void)onDataChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSADataChangedNotification object:self userInfo:nil];
}

@end
