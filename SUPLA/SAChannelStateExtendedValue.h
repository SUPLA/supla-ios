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

#import "SAExtendedValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAChannelStateExtendedValue : SAExtendedValue
-(TDSC_ChannelState)state;
-(NSNumber *)channelId;
-(NSString *)channelIdString;
-(NSNumber *)ipv4;
-(NSString *)ipv4String;
-(NSData *)macAddress;
-(NSString *)macAddressString;
-(NSNumber *)batteryLevel;
-(NSString *)batteryLevelString;
-(NSNumber *)isBatteryPowered;
-(NSString *)isBatteryPoweredString;
-(NSNumber *)wiFiSignalStrength;
-(NSString *)wiFiSignalStrengthString;
-(NSNumber *)wiFiRSSI;
-(NSString *)wiFiRSSIString;
-(NSNumber *)bridgeNodeSignalStrength;
-(NSString *)bridgeNodeSignalStrengthString;
-(NSNumber *)uptime;
-(NSString *)uptimeString;
-(NSNumber *)connectionUptime;
-(NSString *)connectionUptimeString;
-(NSNumber *)isBridgeNodeOnline;
-(NSString *)isBridgeNodeOnlineString;
-(NSNumber *)batteryHealth;
-(NSString *)batteryHealthString;
-(NSNumber *)lastConnectionResetCause;
-(NSString *)lastConnectionResetCauseString;
-(NSNumber *)lightSourceLifespan;
-(NSString *)lightSourceLifespanString;
-(NSNumber *)lightSourceLifespanLeft;
-(NSNumber *)lightSourceOperatingTime;
-(NSNumber *)lightSourceOperatingTimePercent;
-(NSNumber *)lightSourceOperatingTimePercentLeft;
-(NSString *)lightSourceOperatingTimeString;

-(id)initWithChannelState:(TDSC_ChannelState *)state;
@end

@interface SAChannelExtendedValue (SAChannelStateExtendedValue)
- (SAChannelStateExtendedValue*)channelState;
@end

NS_ASSUME_NONNULL_END
