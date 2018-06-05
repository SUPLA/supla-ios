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

#import "SAChannel+CoreDataClass.h"
#import "_SALocation+CoreDataClass.h"
#import "Database.h"

@implementation SAChannel

- (BOOL) setChannelProtocolVersion:(int)protocolVersion {
    
    if ( [self.protocolversion isEqualToNumber:[NSNumber numberWithInt:protocolVersion]] == NO ) {
        self.protocolversion = [NSNumber numberWithInt:protocolVersion];
        return YES;
    }
    
    return NO;
}

- (BOOL) isOnline {
    return self.value == nil ? [super isOnline] : [self.value isOnline];
}

- (int) hiValue {
    return self.value == nil ? [super hiValue] : [self.value hiValue];
}

- (int) hiSubValue {
    return self.value == nil ? [super hiSubValue] : [self.value hiSubValue];
}

- (double) temperatureValue {
    return self.value == nil ? [super temperatureValue] : [self.value getTemperatureForFunction:self.func];
}

- (double) humidityValue {
    return self.value == nil ? [super humidityValue] : [self.value humidityValue];
}

- (double) doubleValue {
    return self.value == nil ? [super doubleValue] : [self.value doubleValue];
}

- (int) percentValue {
     return self.value == nil ? [super percentValue] : [self.value percentValue];
}

- (int) brightnessValue {
    return self.value == nil ? [super brightnessValue] : [self.value brightnessValue];
}

- (int) colorBrightnessValue {
    return self.value == nil ? [super colorBrightnessValue] : [self.value colorBrightnessValue];
}

- (UIColor *) colorValue {
    return self.value == nil ? [super colorValue] : [self.value colorValue];
}

@end
