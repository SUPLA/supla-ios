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
    
extension StateDialogFeature {
    enum StateDialogItem: Int, Identifiable, CaseIterable {
        case channelId
        case ipAddress
        case macAddress
        case batteryLevel
        case batteryPowered
        case wifiRssi
        case wifiSignal
        case bridgeNode
        case bridgeSignal
        case uptime
        case connectionTime
        case batteryHealth
        case connectionReset
        case lightSourceLifespan
        case lightSourceOperatingTime
        
        var id: Int {
            self.rawValue
        }
        
        var label: String {
            switch self {
            case .channelId: Strings.State.channelId
            case .ipAddress: Strings.State.ipAddress
            case .macAddress: Strings.State.macAddress
            case .batteryLevel: Strings.State.batteryLevel
            case .batteryPowered: Strings.State.batteryPowered
            case .wifiRssi: Strings.State.wifiRssi
            case .wifiSignal: Strings.State.wifiSignalStrength
            case .bridgeNode: Strings.State.bridgeNodeOnline
            case .bridgeSignal: Strings.State.bridgeNodeSignal
            case .uptime: Strings.State.uptime
            case .connectionTime: Strings.State.connectionTime
            case .batteryHealth: Strings.State.batteryHealth
            case .connectionReset: Strings.State.connectionResetCause
            case .lightSourceLifespan: Strings.State.lightSourceLifespan
            case .lightSourceOperatingTime: Strings.State.sourceOperatingTime
            }
        }
        
        func extract(from value: SAChannelStateExtendedValue) -> String? {
            switch self {
            case .channelId: value.channelId().stringValue
            case .ipAddress: value.ipv4String()
            case .macAddress: value.macAddressString()
            case .batteryLevel: value.batteryLevelString()
            case .batteryPowered: value.isBatteryPoweredString()
            case .wifiRssi: value.wiFiRSSIString()
            case .wifiSignal: value.wiFiSignalStrengthString()
            case .bridgeNode: value.isBridgeNodeOnlineString()
            case .bridgeSignal: value.bridgeNodeSignalStrengthString()
            case .uptime: value.uptimeString()
            case .connectionTime: value.connectionUptimeString()
            case .batteryHealth: value.batteryHealthString()
            case .connectionReset: value.lastConnectionResetCauseString()
            default: nil
            }
        }
    }
}
