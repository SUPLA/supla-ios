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
    
extension SAChannelState {
    func update(_ state: TDSC_ChannelState) {
        
        ipv4 = state.hasField(SUPLA_CHANNELSTATE_FIELD_IPV4).ifTrue {
            String(format: "%d.%d.%d.%d", (state.IPv4 & 0xFF), (state.IPv4 >> 8 & 0xFF), (state.IPv4 >> 16 & 0xFF), (state.IPv4 >> 24 & 0xFF))
        }
        
        macAddress = state.hasField(SUPLA_CHANNELSTATE_FIELD_MAC).ifTrue {
            String(format: "%02x:%02x:%02x:%02x:%02x:%02x", state.MAC.0, state.MAC.1, state.MAC.2, state.MAC.3, state.MAC.4, state.MAC.5)
        }
        
        batteryLevel = state.hasField(SUPLA_CHANNELSTATE_FIELD_BATTERYLEVEL).ifTrue {
            NSNumber(value: state.BatteryLevel)
        }
        
        batteryPowered = state.hasField(SUPLA_CHANNELSTATE_FIELD_BATTERYPOWERED).ifTrue {
            NSNumber(booleanLiteral: state.BatteryPowered > 0)
        }
        
        wifiRssi = state.hasField(SUPLA_CHANNELSTATE_FIELD_WIFIRSSI).ifTrue {
            NSNumber(value: state.WiFiRSSI)
        }
        
        wifiSignalStrength = state.hasField(SUPLA_CHANNELSTATE_FIELD_WIFISIGNALSTRENGTH).ifTrue {
            if (state.WiFiSignalStrength >= 0 && state.WiFiSignalStrength <= 100) {
                NSNumber(value: state.WiFiSignalStrength)
            } else {
                nil
            }
        }
        
        bridgeNodeOnline = state.hasField(SUPLA_CHANNELSTATE_FIELD_BRIDGENODEONLINE).ifTrue {
            NSNumber(booleanLiteral: state.BridgeNodeOnline > 0)
        }
        
        bridgeNodeSignalStrength = state.hasField(SUPLA_CHANNELSTATE_FIELD_BRIDGENODESIGNALSTRENGTH).ifTrue {
            if (state.BridgeNodeSignalStrength >= 0 && state.BridgeNodeSignalStrength <= 100) {
                NSNumber(value: state.BridgeNodeSignalStrength)
            } else {
                nil
            }
        }
        
        uptime = state.hasField(SUPLA_CHANNELSTATE_FIELD_UPTIME).ifTrue {
            NSNumber(value: state.Uptime)
        }
        
        connectionUptime = state.hasField(SUPLA_CHANNELSTATE_FIELD_UPTIME).ifTrue {
            NSNumber(value: state.ConnectionUptime)
        }
        
        batteryHealth = state.hasField(SUPLA_CHANNELSTATE_FIELD_BATTERYHEALTH).ifTrue {
            NSNumber(value: state.BatteryHealth)
        }
        
        lastConnectionResetCause = state.hasField(SUPLA_CHANNELSTATE_FIELD_LASTCONNECTIONRESETCAUSE).ifTrue {
            NSNumber(value: state.LastConnectionResetCause)
        }
        
        if (state.hasField(SUPLA_CHANNELSTATE_FIELD_LIGHTSOURCELIFESPAN)) {
            lightSourceLifespanLeft = NSNumber(floatLiteral: Double(state.LightSourceLifespanLeft) / 100)
            lightSourceLifespan = NSNumber(value: state.LightSourceLifespan)
        } else {
            lightSourceLifespanLeft = nil
            lightSourceLifespan = nil
        }
        
        if (state.hasField(SUPLA_CHANNELSTATE_FIELD_LIGHTSOURCEOPERATINGTIME)) {
            lightSourceLifespanLeft = nil
            lightSourceOperatingTime = NSNumber(value: state.LightSourceOperatingTime)
        } else {
            lightSourceOperatingTime = nil
        }
    }
}

fileprivate extension TDSC_ChannelState {
    func hasField(_ field: Int32) -> Bool {
        Fields & field > 0
    }
}
