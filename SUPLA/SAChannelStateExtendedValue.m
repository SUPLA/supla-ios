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

#import "SAChannelStateExtendedValue.h"

@implementation SAChannelStateExtendedValue {
    TChannelState_ExtendedValue _csev;
}

-(id)initWithExtendedValue:(SAChannelExtendedValue *)ev {
    if ([super initWithExtendedValue:ev]
        && [self getChannelStateExtendedValue:&_csev]) {
        return self;
    }
    return nil;
}

-(id)initWithChannelState:(TDSC_ChannelState *)state {
    if ([super init]) {
        if (state) {
            memcpy(&_csev, state, sizeof(TDSC_ChannelState));
        } else {
            memset(&_csev, 0, sizeof(TChannelState_ExtendedValue));
        }
        return self;
    }
    return nil;
}

-(BOOL)getChannelStateExtendedValue:(TChannelState_ExtendedValue*)csev {
    if (csev == NULL) {
        return false;
    }
    
    memset(csev, 0, sizeof(TChannelState_ExtendedValue));
    
    __block BOOL result = NO;
    
    [self forEach:^BOOL(TSuplaChannelExtendedValue * _Nonnull ev) {
        if (ev->type == EV_TYPE_CHANNEL_STATE_V1
              && ev->size == sizeof(TChannelState_ExtendedValue)) {
            memcpy(csev, ev->value, sizeof(TChannelState_ExtendedValue));
            result = YES;
        } else if (self.valueType == EV_TYPE_CHANNEL_AND_TIMER_STATE_V1
                   && ev->size >= sizeof(TChannelAndTimerState_ExtendedValue) -
                       SUPLA_SENDER_NAME_MAXSIZE
                   && ev->size <= sizeof(TChannelAndTimerState_ExtendedValue)) {
            TChannelAndTimerState_ExtendedValue *state = (TChannelAndTimerState_ExtendedValue*)ev->value;
            memcpy(csev, &state->Channel, sizeof(TChannelState_ExtendedValue));
            result = YES;
        }
        
        return !result;
    }];

    return result;
}

-(TDSC_ChannelState)state {
    return _csev;
}

-(NSNumber *)channelId {
    return [NSNumber numberWithInt:_csev.ChannelID];
}

-(NSString *)channelIdString {
    return [NSString stringWithFormat:@"%i", _csev.ChannelID];
}

-(NSNumber *)ipv4 {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_IPV4) {
        return [NSNumber numberWithInt:_csev.IPv4];
    }
    return nil;
}

-(NSString *)ipv4String {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_IPV4) {
        return [NSString stringWithFormat:@"%u.%u.%u.%u",
        (_csev.IPv4 & 0xff),
        (_csev.IPv4 >> 8 & 0xff),
        (_csev.IPv4 >> 16 & 0xff),
        (_csev.IPv4 >> 24 & 0xff)];
    }
    return nil;
}

-(NSData *)macAddress {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_MAC) {
        return [NSData dataWithBytes:_csev.MAC length:sizeof(_csev.MAC)];
    }
    return nil;
}

-(NSString *)macAddressString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_MAC) {
        NSString *result = @"";
        for(short a=0;a<sizeof(_csev.MAC);a++) {
            result = [NSString stringWithFormat:@"%@%@%02x",
                      result,
                      a > 0 ? @":" : @"",
                      _csev.MAC[a]];
        }
        return result;
    }
    return nil;
}

-(NSNumber *)batteryLevel {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BATTERYLEVEL) {
         return [NSNumber numberWithInt:_csev.BatteryLevel];
    }
    return nil;
}

-(NSString *)batteryLevelString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BATTERYLEVEL) {
        return [NSString stringWithFormat:@"%i%%", _csev.BatteryLevel];
    }
    return nil;
}

-(NSNumber *)isBatteryPowered {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BATTERYPOWERED) {
        return [NSNumber numberWithBool:_csev.BatteryPowered > 0];
    }
    return nil;
}

-(NSString *)isBatteryPoweredString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BATTERYPOWERED) {
        return _csev.BatteryPowered > 0 ? @"YES" : @"NO";
    }
    return nil;
}

-(NSNumber *)wiFiSignalStrength {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_WIFISIGNALSTRENGTH) {
         return [NSNumber numberWithInt:_csev.WiFiSignalStrength];
    }
    return nil;
}

-(NSString *)wiFiSignalStrengthString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_WIFISIGNALSTRENGTH) {
        return [NSString stringWithFormat:@"%i%%", _csev.WiFiSignalStrength];
    }
    return nil;
}

-(NSNumber *)wiFiRSSI {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_WIFIRSSI) {
         return [NSNumber numberWithInt:_csev.WiFiRSSI];
    }
    return nil;
}

-(NSString *)wiFiRSSIString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_WIFIRSSI) {
        return [NSString stringWithFormat:@"%i", _csev.WiFiRSSI];
    }
    return nil;
}

-(NSNumber *)bridgeNodeSignalStrength {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BRIDGENODESIGNALSTRENGTH) {
         return [NSNumber numberWithInt:_csev.BridgeNodeSignalStrength];
    }
    return nil;
}

-(NSString *)bridgeNodeSignalStrengthString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BRIDGENODESIGNALSTRENGTH) {
        return [NSString stringWithFormat:@"%i%%", _csev.BridgeNodeSignalStrength];
    }
    return nil;
}

-(NSNumber *)uptime {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_UPTIME) {
         return [NSNumber numberWithInt:_csev.Uptime];
    }
    return nil;
}

-(NSString *)uptimeWithSeconds:(unsigned int)uptime {
    return [NSString stringWithFormat:@"%u %@ %02u:%02u:%02u",
            uptime / 86400,
            [NSLocalizedString(@"Days", nil) lowercaseString],
            uptime % 86400 / 3600,
            uptime % 86400 % 3600 / 60,
            uptime % 86400 % 3600 % 60];
}

-(NSString *)uptimeString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_UPTIME) {
        return [self uptimeWithSeconds:_csev.Uptime];
    }
    return nil;
}

-(NSNumber *)connectionUptime {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_CONNECTIONUPTIME) {
         return [NSNumber numberWithInt:_csev.ConnectionUptime];
    }
    return nil;
}

-(NSString *)connectionUptimeString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_CONNECTIONUPTIME) {
        return [self uptimeWithSeconds:_csev.ConnectionUptime];
    }
    return nil;
}

-(NSNumber *)isBridgeNodeOnline {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BRIDGENODEONLINE) {
        return [NSNumber numberWithBool:_csev.BridgeNodeOnline > 0];
    }
    return nil;
}

-(NSString *)isBridgeNodeOnlineString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BRIDGENODEONLINE) {
        return _csev.BridgeNodeOnline > 0 ? @"YES" : @"NO";
    }
    return nil;
}

-(NSNumber *)batteryHealth {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BATTERYHEALTH) {
         return [NSNumber numberWithInt:_csev.BatteryHealth];
    }
    return nil;
}

-(NSString *)batteryHealthString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_BATTERYHEALTH) {
      return [NSString stringWithFormat:@"%i%%", _csev.BatteryHealth];
    }
    return nil;
}

-(NSNumber *)lastConnectionResetCause {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_LASTCONNECTIONRESETCAUSE) {
         return [NSNumber numberWithInt:_csev.LastConnectionResetCause];
    }
    return nil;
}

-(NSString *)lastConnectionResetCauseString {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_LASTCONNECTIONRESETCAUSE) {
        NSArray<NSString*>* key_table = @[@"0: unknown", @"1: server timeout",
                                          @"2: Wi-Fi connection lost",
                                          @"3: server connection reset"];
        if (_csev.LastConnectionResetCause >= 0 &&
            _csev.LastConnectionResetCause < key_table.count) {
            return NSLocalizedString(key_table[_csev.LastConnectionResetCause], nil);
        } else {
            return [NSString stringWithFormat:@"%i", _csev.LastConnectionResetCause];
        }
    }
    return nil;
}

-(NSNumber *)lightSourceLifespan {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_LIGHTSOURCELIFESPAN) {
         return [NSNumber numberWithInt:_csev.LightSourceLifespan];
    }
    return nil;
}

-(NSString *)lightSourceLifespanString {
    NSNumber *percent = nil;
    if (self.lightSourceLifespanLeft != nil) {
        percent = self.lightSourceLifespanLeft;
    } else if (self.lightSourceOperatingTimePercentLeft != nil) {
        percent = self.lightSourceOperatingTimePercentLeft;
    }
    
    if (percent != nil) {
        return [NSString stringWithFormat:@"%uh (%0.2f%%)",
                self.lightSourceLifespan.intValue,
                percent.floatValue];
    }
    
    return [NSString stringWithFormat:@"%u", self.lightSourceLifespan.intValue];
}

-(NSNumber *)lightSourceLifespanLeft {
    if (!(_csev.Fields & SUPLA_CHANNELSTATE_FIELD_LIGHTSOURCEOPERATINGTIME)) {
        return [NSNumber numberWithInt:_csev.LightSourceLifespanLeft/100.00];
    }
    return nil;
}

-(NSNumber *)lightSourceOperatingTime {
    if (_csev.Fields & SUPLA_CHANNELSTATE_FIELD_LIGHTSOURCEOPERATINGTIME) {
         return [NSNumber numberWithInt:_csev.LightSourceOperatingTime];
    }
    return nil;
}

-(NSNumber *)lightSourceOperatingTimePercent {
    if (self.lightSourceOperatingTime != nil
        && self.lightSourceLifespan != nil
        && self.lightSourceLifespan.intValue > 0) {
        return [NSNumber numberWithFloat:self.lightSourceOperatingTime.intValue / 36.00 / self.lightSourceLifespan.intValue];
    }
    return nil;
}

-(NSNumber *)lightSourceOperatingTimePercentLeft {
    NSNumber *percent = self.lightSourceOperatingTimePercent;
    if (percent != nil) {
        return [NSNumber numberWithFloat:100.00 - percent.floatValue];
    }
    return nil;
}

-(NSString *)lightSourceOperatingTimeString {
    int timeSec = self.lightSourceOperatingTime.intValue;
    return [NSString stringWithFormat:@"%02uh %02u:%02u",
            timeSec / 3600,
            timeSec % 3600 / 60,
            timeSec % 3600 % 60];
}


@end

@implementation SAChannelExtendedValue (SAChannelStateExtendedValue)

- (SAChannelStateExtendedValue*)channelState {
    return [[SAChannelStateExtendedValue alloc] initWithExtendedValue:self];
}

@end
