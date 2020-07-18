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

#import "SAChannelStatePopup.h"
#import "SAChannelStateExtendedValue.h"

@interface SAChannelStatePopup ()

@end

@implementation SAChannelStatePopup


-(void)updateListWithChannelState:(SAChannelStateExtendedValue*)state {
 
    if (state && state.ipv4 != nil) {
        [self.lIPTitle setText:NSLocalizedString(@"IP", nil)];
        [self.lIP setText:state.ipv4String];
        self.lIPTitle.hidden = NO;
        self.lIP.hidden = NO;
    } else {
        [self.lIPTitle setText:@""];
        [self.lIP setText:@""];
        self.lIPTitle.hidden = YES;
        self.lIP.hidden = YES;
    }

    if (state && state.macAddress != nil) {
        [self.lMACTitle setText:NSLocalizedString(@"MAC", nil)];
        [self.lMAC setText:state.macAddressString];
        self.lMACTitle.hidden = NO;
        self.lMAC.hidden = NO;
    } else {
        [self.lMACTitle setText:@""];
        [self.lMAC setText:@""];
        self.lMACTitle.hidden = NO;
        self.lMAC.hidden = NO;
    }
    
    if (state && state.batteryLevel != nil) {
        [self.lBatteryLevelTitle setText:NSLocalizedString(@"Battery level", nil)];
        [self.lBatteryLevel setText:state.batteryLevelString];
        self.lBatteryLevelTitle.hidden = NO;
        self.lBatteryLevel.hidden = NO;
    } else {
        [self.lBatteryLevelTitle setText:@""];
        [self.lBatteryLevel setText:@""];
        self.lBatteryLevelTitle.hidden = NO;
        self.lBatteryLevel.hidden = NO;
    }

    if (state && state.isBatteryPowered != nil) {
        [self.lBatteryPoweredTitle setText:NSLocalizedString(@"Battery powered", nil)];
        [self.lBatteryPowered setText:state.isBatteryPoweredString];
        self.lBatteryPoweredTitle.hidden = NO;
        self.lBatteryPowered.hidden = NO;
    } else {
        [self.lBatteryPoweredTitle setText:@""];
        [self.lBatteryPowered setText:@""];
        self.lBatteryPoweredTitle.hidden = NO;
        self.lBatteryPowered.hidden = NO;
    }

    if (state && state.wiFiRSSI != nil) {
        [self.lWifiRSSITitle setText:NSLocalizedString(@"Wifi RSSI", nil)];
        [self.lWifiRSSI setText:state.wiFiRSSIString];
        self.lWifiRSSITitle.hidden = NO;
        self.lWifiRSSI.hidden = NO;
    } else {
        [self.lWifiRSSITitle setText:@""];
        [self.lWifiRSSI setText:@""];
        self.lWifiRSSITitle.hidden = NO;
        self.lWifiRSSI.hidden = NO;
    }

    if (state && state.wiFiSignalStrength != nil) {
        [self.lWifiSignalStrengthTitle setText:NSLocalizedString(@"Wifi signal strength", nil)];
        [self.lWifiSignalStrength setText:state.wiFiSignalStrengthString];
        self.lWifiSignalStrengthTitle.hidden = NO;
        self.lWifiSignalStrength.hidden = NO;
    } else {
        [self.lWifiSignalStrengthTitle setText:@""];
        [self.lWifiSignalStrength setText:@""];
        self.lWifiSignalStrengthTitle.hidden = NO;
        self.lWifiSignalStrength.hidden = NO;
    }
    
    if (state && state.isBridgeNodeOnline != nil) {
        [self.lBridgeNodeOnlineTitle setText:NSLocalizedString(@"Bridge node - online", nil)];
        [self.lBridgeNodeOnline setText:state.isBridgeNodeOnlineString];
        self.lBridgeNodeOnlineTitle.hidden = NO;
        self.lBridgeNodeOnline.hidden = NO;
    } else {
        [self.lBridgeNodeOnlineTitle setText:@""];
        [self.lBridgeNodeOnline setText:@""];
        self.lBridgeNodeOnlineTitle.hidden = NO;
        self.lBridgeNodeOnline.hidden = NO;
    }
    
    if (state && state.bridgeNodeSignalStrength != nil) {
        [self.lBridgeNodeSignalStrengthTitle setText:NSLocalizedString(@"Bridge node - signal strength", nil)];
        [self.lBridgeNodeSignalStrength setText:state.bridgeNodeSignalStrengthString];
        self.lBridgeNodeSignalStrengthTitle.hidden = NO;
        self.lBridgeNodeSignalStrength.hidden = NO;
    } else {
        [self.lBridgeNodeSignalStrengthTitle setText:@""];
        [self.lBridgeNodeSignalStrength setText:@""];
        self.lBridgeNodeSignalStrengthTitle.hidden = NO;
        self.lBridgeNodeSignalStrength.hidden = NO;
    }

    if (state && state.uptime != nil) {
        [self.lUptimeTitle setText:NSLocalizedString(@"Uptime", nil)];
        [self.lUptime setText:state.uptimeString];
        self.lUptimeTitle.hidden = NO;
        self.lUptime.hidden = NO;
    } else {
        [self.lUptimeTitle setText:@""];
        [self.lUptime setText:@""];
        self.lUptimeTitle.hidden = NO;
        self.lUptime.hidden = NO;
    }
    
    if (state && state.connectionUptime != nil) {
        [self.lConnectionUptimeTitle setText:NSLocalizedString(@"Connection uptime", nil)];
        [self.lConnectionUptime setText:state.connectionUptimeString];
        self.lConnectionUptimeTitle.hidden = NO;
        self.lConnectionUptime.hidden = NO;
    } else {
        [self.lConnectionUptimeTitle setText:@""];
        [self.lConnectionUptime setText:@""];
        self.lConnectionUptimeTitle.hidden = NO;
        self.lConnectionUptime.hidden = NO;
    }

    if (state && state.batteryHealth != nil) {
        [self.lBatteryHealthTitle setText:NSLocalizedString(@"Battery health", nil)];
        [self.lBatteryHealth setText:state.batteryHealthString];
        self.lBatteryHealthTitle.hidden = NO;
        self.lBatteryHealth.hidden = NO;
    } else {
        [self.lBatteryHealthTitle setText:@""];
        [self.lBatteryHealth setText:@""];
        self.lBatteryHealthTitle.hidden = NO;
        self.lBatteryHealth.hidden = NO;
    }

    if (state && state.lastConnectionResetCause != nil) {
        [self.lConnectionResetCauseTitle setText:NSLocalizedString(@"Connection reset cause", nil)];
        [self.lConnectionResetCause setText:state.lastConnectionResetCauseString];
        self.lConnectionResetCauseTitle.hidden = NO;
        self.lConnectionResetCause.hidden = NO;
    } else {
        [self.lConnectionResetCauseTitle setText:@""];
        [self.lConnectionResetCause setText:@""];
        self.lConnectionResetCauseTitle.hidden = NO;
        self.lConnectionResetCause.hidden = NO;
    }
    
    if (state && state.lightSourceLifespan != nil) {
        [self.lLightsourceLifespanTitle setText:NSLocalizedString(@"Light source lifespan", nil)];
        [self.lLightsourceLifespan setText:state.lightSourceLifespanString];
        self.lLightsourceLifespanTitle.hidden = NO;
        self.lLightsourceLifespan.hidden = NO;
    } else {
        [self.lLightsourceLifespanTitle setText:@""];
        [self.lLightsourceLifespan setText:@""];
        self.lLightsourceLifespanTitle.hidden = NO;
        self.lLightsourceLifespan.hidden = NO;
    }
    
    if (state && state.lightSourceOperatingTime != nil) {
        [self.lLightsourceOperatingTimeTitle setText:NSLocalizedString(@"Light source operating time", nil)];
        [self.lLightsourceOperatingTime setText:state.lightSourceOperatingTimeString];
        self.lLightsourceOperatingTimeTitle.hidden = NO;
        self.lLightsourceOperatingTime.hidden = NO;
    } else {
        [self.lLightsourceOperatingTimeTitle setText:@""];
        [self.lLightsourceOperatingTime setText:@""];
        self.lLightsourceOperatingTimeTitle.hidden = NO;
        self.lLightsourceOperatingTime.hidden = NO;
    }

    [self.vList sizeToFit];
}

@end
