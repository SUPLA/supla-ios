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
        snprintf(authInfo.Email, SUPLA_EMAIL_MAXSIZE, "%s", [profile.authInfo.emailAddress UTF8String]);
        snprintf(authInfo.ServerName, SUPLA_SERVER_NAME_MAXSIZE, "%s", [profile.authInfo.serverForEmail UTF8String]);
    } else {
        authInfo.AccessID = (int) profile.authInfo.accessID;
        snprintf(authInfo.AccessIDpwd, SUPLA_ACCESSID_PWD_MAXSIZE, "%s", [profile.authInfo.accessIDpwd UTF8String]);
        snprintf(authInfo.ServerName, SUPLA_SERVER_NAME_MAXSIZE, "%s", [profile.authInfo.serverForAccessID UTF8String]);
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
        
        clientToken.TokenSize = _token.length + 1;
        clientToken.RealTokenSize = clientToken.TokenSize;
        if (clientToken.TokenSize > SUPLA_PN_CLIENT_TOKEN_MAXSIZE) {
            clientToken.TokenSize = SUPLA_PN_CLIENT_TOKEN_MAXSIZE;
        }
        snprintf((char*)clientToken.Token, clientToken.TokenSize, "%s", [_token UTF8String]);
        
        unsigned long profileNameLenght = profileName.length + 1;
        if (profileNameLenght >= SUPLA_PN_PROFILE_NAME_MAXSIZE) {
            profileNameLenght = SUPLA_PN_PROFILE_NAME_MAXSIZE;
        }
        snprintf((char*)clientToken.ProfileName, profileNameLenght, "%s", [profileName UTF8String]);
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
