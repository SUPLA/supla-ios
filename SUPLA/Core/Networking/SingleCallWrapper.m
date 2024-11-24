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

#import "SingleCallWrapper.h"
#import "SUPLA-Swift.h"
#import "supla-client.h"

#define APP_ID 1


@implementation SingleCallWrapper

+ (TCS_ClientAuthorizationDetails) prepareAuthorizationDetailsFor: (AuthProfileItem*) profile {
    TCS_ClientAuthorizationDetails authInfo = {};
    
    [profile.clientGUID getBytes:authInfo.GUID length:SUPLA_GUID_SIZE];
    [profile.authKey getBytes:authInfo.AuthKey length:SUPLA_AUTHKEY_SIZE];
    
    if (profile.authInfo.emailAuth) {
        [profile.authInfo.emailAddress utf8StringToBuffer:authInfo.Email withSize:sizeof(authInfo.Email)];
        [profile.authInfo.serverForEmail utf8StringToBuffer:authInfo.ServerName withSize:sizeof(authInfo.ServerName)];
    } else {
        authInfo.AccessID = (int) profile.authInfo.accessID;
        [profile.authInfo.accessIDpwd utf8StringToBuffer:authInfo.AccessIDpwd withSize:sizeof(authInfo.AccessIDpwd)];
        [profile.authInfo.serverForAccessID utf8StringToBuffer:authInfo.ServerName withSize:sizeof(authInfo.ServerName)];
    }
    
    return authInfo;
}

+ (TCS_PnClientToken) prepareClientTokenFor: (NSData*) token andProfile: (NSString*) profileName {
    TCS_PnClientToken clientToken = {};
    clientToken.AppId = APP_ID;
#ifdef DEBUG
    clientToken.DevelopmentEnv = 1;
#endif /*DEBUG*/
    clientToken.Platform = PLATFORM_IOS;
    
    if (token) {
        NSMutableString *_token = [NSMutableString string];
        const char *bytes = [token bytes];
        
        for (NSUInteger i = 0; i < [token length]; i++) {
            [_token appendFormat:@"%02.2hhx", bytes[i]];
        }
        
        snprintf((char*)clientToken.Token, sizeof(clientToken.Token), "%s", [_token UTF8String]);
     
    
        [profileName utf8StringToBuffer:(char*)clientToken.ProfileName withSize:sizeof(clientToken.ProfileName)];
        
        clientToken.TokenSize = strnlen((char*)clientToken.Token, sizeof(clientToken.Token)) + 1;
        clientToken.RealTokenSize = clientToken.TokenSize;
        if (clientToken.TokenSize > SUPLA_PN_CLIENT_TOKEN_MAXSIZE) {
            clientToken.TokenSize = SUPLA_PN_CLIENT_TOKEN_MAXSIZE;
        }
    }
    
    return clientToken;
}

+ (TCS_RegisterPnClientToken) prepareRegisterStructureFor: (AuthProfileItem*) profile with: (NSData*) token {
    TCS_RegisterPnClientToken reg = {};
    reg.Token = [SingleCallWrapper prepareClientTokenFor: token andProfile: profile.name];
    reg.Auth = [SingleCallWrapper prepareAuthorizationDetailsFor: profile];
    
    return reg;
}

@end
