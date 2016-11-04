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
 
 Author: Przemyslaw Zygmunt przemek@supla.org
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

void sasuplaclient_on_registered(void *_suplaclient, void *user_data, TSC_SuplaRegisterClientResult *result) {
    
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onRegistered:[SARegResult RegResultClientID:result->ClientID locationCount:result->LocationCount channelCount:result->ChannelCount]];
    
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

void sasuplaclient_channel_update(void *_suplaclient, void *user_data, TSC_SuplaChannel *channel) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc channelUpdate: channel];
}

void sasuplaclient_channel_value_update(void *_suplaclient, void *user_data, TSC_SuplaChannelValue *channel_value) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc channelValueUpdate:channel_value];
}

void sasuplaclient_on_event(void *_suplaclient, void *user_data, TSC_SuplaEvent *event) {
    SASuplaClient *sc = (__bridge SASuplaClient*)user_data;
    if ( sc != nil )
        [sc onEvent: [SAEvent Event:event->Event ChannelID:event->ChannelID
                         DurationMS:event->DurationMS SenderID:event->SenderID SenderName:[NSString stringWithUTF8String:event->SenderName]]];
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

+ (SARegResult*) RegResultClientID:(int) clientID locationCount:(int) location_count channelCount:(int) channel_count {
    SARegResult *rr = [[SARegResult alloc] init];
    
    rr.ClientID = clientID;
    rr.LocationCount = location_count;
    rr.ChannelCount = channel_count;
    
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


// ------------------------------------------------------------------------------------------------------

@interface SASuplaClient () {
    void *_sclient;
    int _client_id;
    BOOL _connected;
}
@end

@implementation SASuplaClient {
    SADatabase *_DB;
}

- (id)init {
    self = [super init];
    _sclient = NULL;
    
    return self;
}

-(SADatabase*)DB {
    if ( _DB == nil ) {
        _DB = [[SADatabase alloc] init];
    }
    
    return _DB;
}

- (void*) client_init {
    
    TSuplaClientCfg scc;
    supla_client_cfginit(&scc);
    
    [SAApp getClientGUID:scc.clientGUID];
    
    scc.user_data = (__bridge void *)self;
    scc.host = (char*)[[SAApp getServerHostName] UTF8String];
    scc.AccessID = [SAApp getAccessID];
    snprintf(scc.AccessIDpwd, SUPLA_ACCESSID_PWD_MAXSIZE, "%s", [[SAApp getAccessIDpwd] UTF8String]);
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
    scc.cb_channel_value_update = sasuplaclient_channel_value_update;
    scc.cb_on_event = sasuplaclient_on_event;
    
    return supla_client_init(&scc);

}

- (void)main {

    //NSLog(@"Started");
    
    while(![self isCancelled]) {
        @autoreleasepool {
           
            [self onConnecting];
            BOOL DataChanged = NO;
            
            if ( [self.DB setChannelsVisible:2 WhereVisibilityIs:1] ) {
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
            
            if ( _sclient != NULL )
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
   [self performSelectorOnMainThread:@selector(_onRegistering) withObject:nil waitUntilDone:NO];
}

- (void) _onRegisterError:(NSNumber*)code {
    [[SAApp instance] onRegisterError:code];
}

- (void) onRegisterError:(int)code {
    

    [self performSelectorOnMainThread:@selector(_onRegisterError:) withObject:[NSNumber numberWithInt:code] waitUntilDone:NO];
}

- (void) _onRegistered:(SARegResult*)result {
    [[SAApp instance] onRegistered: result];
}

- (void) onRegistered:(SARegResult*)result {
    
    if ( result.ChannelCount == 0
         && [self.DB setChannelsVisible:0 WhereVisibilityIs:2] ) {
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

- (void) _onChannelValueChanged:(NSNumber*)Id {
    [[SAApp instance] onChannelValueChanged:Id];
}

- (void) onChannelValueChanged:(int)Id {
    [self performSelectorOnMainThread:@selector(_onChannelValueChanged:) withObject:[NSNumber numberWithInt:Id] waitUntilDone:NO];
};


- (void) locationUpdate:(TSC_SuplaLocation *)location {
    
    if ( [self.DB updateLocation: location] ) {
        [self onDataChanged];
    };
    
}

- (void) channelUpdate:(TSC_SuplaChannel *)channel {
    
    BOOL DataChanged = NO;
    
    //NSLog(@"ChannelID: %i, caption: %@", channel->Id, [NSString stringWithUTF8String:channel->Caption]);
    
    if ( [self.DB updateChannel:channel] ) {
        DataChanged = YES;
    }
    
    if ( channel->EOL == 1
         && [self.DB setChannelsVisible:0 WhereVisibilityIs:2] ) {
        DataChanged = YES;
    }
    
    if ( DataChanged == YES ) {
        [self onDataChanged];
    }
    
}

- (void) channelValueUpdate:(TSC_SuplaChannelValue *)channel_value {
    if ( [self.DB updateChannelValue:channel_value] ) {
        [self onChannelValueChanged: channel_value->Id];
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

- (void) channel:(int)ChannelID Open:(char)open {
    
    @synchronized(self) {
        if ( _sclient ) {
            supla_client_open(_sclient, ChannelID, open);
        }
    }
    
}

- (BOOL) channel:(int)ChannelID setRGB:(UIColor*)color colorBrightness:(int)color_brightness brightness:(int)brightness {
   
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
            
            result = 1 == supla_client_set_rgbw(_sclient, ChannelID, _color, color_brightness, brightness);
        }
    }
    
    return result;
}



@end
