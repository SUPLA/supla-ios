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
    
extension StateDialogFeature {
    enum StateDialogItem: Int, Identifiable, CaseIterable {
        case channelId
        case ipAddress
        case macAddress
        case batteryLevel
        case powerSupply
        case wifiRssi
        case wifiSignal
        case bridgeNode
        case bridgeSignal
        case uptime
        case connectionTime
        case batteryHealth
        case connectionReset
        case switchCycleCount
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
            case .powerSupply: Strings.State.powerSupply
            case .wifiRssi: Strings.State.wifiRssi
            case .wifiSignal: Strings.State.wifiSignalStrength
            case .bridgeNode: Strings.State.bridgeNodeOnline
            case .bridgeSignal: Strings.State.bridgeNodeSignal
            case .uptime: Strings.State.uptime
            case .connectionTime: Strings.State.connectionTime
            case .batteryHealth: Strings.State.batteryHealth
            case .connectionReset: Strings.State.connectionResetCause
            case .switchCycleCount: Strings.State.switchCycleCount
            case .lightSourceLifespan: Strings.State.lightSourceLifespan
            case .lightSourceOperatingTime: Strings.State.sourceOperatingTime
            }
        }
        
        func extract(from value: SharedCore.SuplaChannelStatePrintable) -> String? {
            switch self {
            case .channelId: value.channelIdString?.string
            case .ipAddress: value.ipV4
            case .macAddress: value.macAddress
            case .batteryLevel: value.batteryLevelString?.string
            case .powerSupply: value.batteryPoweredString?.string
            case .wifiRssi: value.wifiRssiString?.string
            case .wifiSignal: value.wifiSignalStrengthString?.string
            case .bridgeNode: value.bridgeNodeOnlineString?.string
            case .bridgeSignal: value.bridgeNodeSignalStrengthString?.string
            case .uptime: value.uptimeString?.string
            case .connectionTime: value.connectionUptimeString?.string
            case .batteryHealth: value.batteryHealthString?.string
            case .connectionReset: value.lastConnectionResetCauseString?.string
            case .switchCycleCount: value.switchCycleCountString?.string
            case .lightSourceLifespan: value.lightSourceLifespanString
            case .lightSourceOperatingTime: value.lightSourceOperatingTimeString
            }
        }
        
        static func values(_ printableState: SuplaChannelStatePrintable) -> [StateDialogItem: String] {
            StateDialogItem.allCases
                .reduce(into: [StateDialogFeature.StateDialogItem: String?]()) {
                    $0[$1] = $1.extract(from: printableState)
                }
                .filter { $0.value != nil && $0.value?.isEmpty == false }
                .mapValues { $0! }
        }
    }
}

private extension SuplaChannelStatePrintable {
    var lightSourceLifespanString: String? {
        guard let lightSourceLifespan = lightSourceLifespanForPrintable else { return nil }
        
            let left = lightSourceLifespanLeftForPrintable ?? lightSourceOperatingTimePercentLeft
            
            if let left {
                return String.init(format: "%dh (%0.2f%%)", lightSourceLifespan, left.intValue)
            } else {
                return String.init(format: "%dh", lightSourceLifespan)
            }
    }
    
    var lightSourceOperatingTimeString: String? {
        guard let lightSourceOperatingTime = lightSourceOperatingTimeForPrintable else { return nil }
        let timeInSec = lightSourceOperatingTime.intValue
        return String.init(format: "%02dh %02d:%02d", timeInSec / 3600, timeInSec % 3600 / 60, timeInSec % 60)
    }
}
