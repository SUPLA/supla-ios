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
    
import SharedCore

extension SAChannelStateExtendedValue : SharedCore.SuplaChannelStatePrintable {
    
    public var channelId: Int32 { state().ChannelID }
    
    public var macAddress: String? {
        hasField(SUPLA_CHANNELSTATE_FIELD_MAC) {
            String(format: "%02x:%02x:%02x:%02x:%02x:%02x", $0.MAC.0, $0.MAC.1, $0.MAC.2, $0.MAC.3, $0.MAC.4, $0.MAC.5)
        }
    }
    
    public var ipV4: String? {
        hasField(SUPLA_CHANNELSTATE_FIELD_IPV4) {
            IntExtensionsKt.ipV4String(Int32(bitPattern: $0.IPv4))
        }
    }
    
    public var batteryHealthForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_BATTERYHEALTH) {
            KotlinInt(int: Int32($0.BatteryHealth))
        }
    }
    
    public var batteryLevelForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_BATTERYLEVEL) {
            KotlinInt(int: Int32($0.BatteryLevel))
        }
    }
    
    public var batteryPoweredForPrintable: KotlinBoolean? {
        hasField(SUPLA_CHANNELSTATE_FIELD_BATTERYPOWERED) {
            KotlinBoolean(bool: $0.BatteryPowered > 0)
        }
    }
    
    public var bridgeNodeOnlineForPrintable: KotlinBoolean? {
        hasField(SUPLA_CHANNELSTATE_FIELD_BRIDGENODEONLINE) {
            KotlinBoolean(bool: $0.BridgeNodeOnline > 0)
        }
    }
    
    public var bridgeNodeSignalStrengthForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_BRIDGENODESIGNALSTRENGTH) {
            KotlinInt(int: Int32($0.BridgeNodeSignalStrength))
        }
    }
    
    public var uptimeForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_UPTIME) {
            KotlinInt(integerLiteral: Int($0.Uptime))
        }
    }
    
    public var connectionUptimeForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_CONNECTIONUPTIME) {
            KotlinInt(integerLiteral: Int($0.ConnectionUptime))
        }
    }
    
    public var lastConnectionResetCauseForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_LASTCONNECTIONRESETCAUSE) {
            KotlinInt(int: Int32($0.LastConnectionResetCause))
        }
    }
    
    public var lightSourceLifespanForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_LIGHTSOURCELIFESPAN) {
            KotlinInt(int: Int32($0.LightSourceLifespan))
        }
    }
    
    public var lightSourceLifespanLeftForPrintable: KotlinFloat? {
        let state = state()
        if (state.Fields & SUPLA_CHANNELSTATE_FIELD_LIGHTSOURCELIFESPAN > 0 && state.Fields & SUPLA_CHANNELSTATE_FIELD_LIGHTSOURCEOPERATINGTIME == 0) {
            return KotlinFloat(float: Float(state.LightSourceLifespanLeft) / 100.0)
        } else {
            return nil
        }
    }
    
    public var lightSourceOperatingTimeForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_LIGHTSOURCEOPERATINGTIME) {
            KotlinInt(int: Int32($0.LightSourceOperatingTime))
        }
    }
    
    public var switchCycleCountForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_SWITCHCYCLECOUNT) {
            KotlinInt(int: Int32($0.SwitchCycleCount))
        }
    }
    
    public var wifiRssiForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_WIFIRSSI) {
            KotlinInt(int: Int32($0.WiFiRSSI))
        }
    }
    
    public var wifiSignalStrengthForPrintable: KotlinInt? {
        hasField(SUPLA_CHANNELSTATE_FIELD_WIFISIGNALSTRENGTH) {
            KotlinInt(int: Int32($0.WiFiSignalStrength))
        }
    }
    
    private func hasField<T>(_ field: Int32, _ callback: (TDSC_ChannelState) -> T) -> T? {
        let state = state()
        if (state.Fields & field > 0) {
            return callback(state)
        } else {
            return nil
        }
    }
}
