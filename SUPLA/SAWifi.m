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

#import "SAWifi.h"
#import <UIKit/UIKit.h>
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#define TRY_COUNT 3

@implementation SAWifi {
    NSMutableArray *_prefixes;
    short _tryCount;
    SAWifiAutoConnectCompletionHandler _completionHandler;
}

+(BOOL)autoConnectIsAvailable {
    if (@available(iOS 13.0, *)) {
        return YES;
    }
    return NO;
}

-(void)prefixesInit {
    _prefixes = [NSMutableArray arrayWithArray:@[@"ZAMEL-", @"SUPLA-", @"NICE-", @"HEATPOL-", @"COMELIT-"]];
}

-(void)onResultWithSuccess:(BOOL)success {
    _completionHandler(success);
}

-(void)tryConnect {
    if (@available(iOS 13.0, *)) {
        
        if (_prefixes.count == 0) {
            _tryCount--;
            if (_tryCount > 0) {
                [self prefixesInit];
            }
        }
        
        if (_prefixes != NULL && _prefixes.count > 0) {
            NSString *prefix = [_prefixes objectAtIndex:0];
            [_prefixes removeObject:prefix];

            NEHotspotConfiguration *cfg = [[NEHotspotConfiguration alloc] initWithSSIDPrefix:prefix];
            cfg.joinOnce = NO;
            
            [NEHotspotConfigurationManager.sharedManager applyConfiguration:cfg completionHandler:^(NSError* error) {
                if (error) {
                    [self tryConnect];
                }
                else
                {
                    [self onResultWithSuccess:YES];
                }
            }];
        } else {
            [SAWifi cleanup];
            [self onResultWithSuccess:NO];
        }
    }
}

-(void)tryConnectWithCompletionHandler:(void (^)(BOOL success))completionHandler {
    [self prefixesInit];
    [SAWifi cleanup];
    _tryCount = TRY_COUNT;
    _completionHandler = completionHandler;
    
    [self tryConnect];
}

+(void)cleanup {
    if (@available(iOS 13.0, *)) {
        [NEHotspotConfigurationManager.sharedManager getConfiguredSSIDsWithCompletionHandler:^(NSArray<NSString *> *ssids) {
            for(int a=0;a<ssids.count;a++) {
                [NEHotspotConfigurationManager.sharedManager removeConfigurationForSSID:[ssids objectAtIndex:a]];
            }
        }];
    }
}

+(NSString*)currentSSID {
    /*
    if (@available(iOS 14.0, *)) {
        [NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork * _Nullable currentNetwork) {
           NSString  *strSSID = [currentNetwork BSSID];
            NSLog(@"SSID 1 %@", strSSID);
        }];
    } else {

        NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
        
        NSDictionary *info;
        
        for (NSString *ifnam in ifs) {
            
            info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            
            if (info && [info count]) {
                
                NSString  *strSSID = [info objectForKey:@"SSID"];
                NSLog(@"SSID 2 %@", strSSID);
                break;
            }
        }
    }
    */
    return nil;
}
@end
