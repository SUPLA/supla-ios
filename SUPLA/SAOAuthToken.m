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

#import "SAOAuthToken.h"

@implementation SAOAuthToken;

@synthesize resultCode;
@synthesize tokenString;
@synthesize expiresIn;
@synthesize birthday;

-(id)init {
    if (self = [super init]) {
        resultCode = 0;
        tokenString = nil;
        birthday = nil;
    }
    return self;
}

-(id)initWithRequestResult:(TSC_OAuthTokenRequestResult *)result {
    if (self = [self init]) {
        resultCode = result->ResultCode;
        result->Token.Token[SUPLA_OAUTH_TOKEN_MAXSIZE-1] = 0;
        tokenString = [NSString stringWithUTF8String:result->Token.Token];
        birthday = [NSDate date];
        expiresIn = result->Token.ExpiresIn;
    }
    return self;
}

-(id)initWithToken:(SAOAuthToken *)token {
    if ((self = [self init]) && token != nil) {
        resultCode = token.resultCode;
        tokenString = token.tokenString;
        birthday = token.birthday;
        expiresIn = token.expiresIn;
    }
    return self;
}

+(SAOAuthToken *)tokenWithRequestResult:(TSC_OAuthTokenRequestResult *)result {
    return [[SAOAuthToken alloc] initWithRequestResult: result];
}

+(SAOAuthToken *)tokenWithToken:(SAOAuthToken *)sourceToken {
    return [[SAOAuthToken alloc] initWithToken:sourceToken];
}

+(SAOAuthToken *)notificationToToken:(NSNotification *)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"token"];
        if (r != nil && [r isKindOfClass:[SAOAuthToken class]]) {
            return r;
        }
    }
    return nil;
}

- (BOOL)isAlive {
    return [birthday timeIntervalSince1970] + expiresIn - [[NSDate date] timeIntervalSince1970] >= 20;
}

- (NSString*)url {
    if (self.tokenString != nil) {
        NSArray *stringArray = [self.tokenString componentsSeparatedByString:@"."];
        if (stringArray.count == 2) {
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:[stringArray objectAtIndex:1] options:0];
            return [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        }
    }

    return nil;
}

@end
