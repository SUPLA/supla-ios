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

+ (TCS_RegisterPnClientToken) prepareRegisterStructureFor: (AuthProfileItem*) profile with: (NSData*) token {
    TCS_RegisterPnClientToken reg = {};
    reg.Token = [profile token:token];
    reg.Auth = profile.authDetails;
    
    return reg;
}

@end
