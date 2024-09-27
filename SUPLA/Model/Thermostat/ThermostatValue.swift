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

import Foundation

struct ThermostatValue {
    let online: Bool
    let state: ThermostatState
    let mode: SuplaHvacMode
    let setpointTemperatureHeat: Float
    let setpointTemperatureCool: Float
    let flags: [SuplaThermostatFlag]

    var subfunction: ThermostatSubfunction { flags.contains(.heatOrCool) ? .cool : .heat }

    var indicatorIcon: ThermostatIndicatorIcon {
        if (!online) {
            .offline
        } else if (mode == .off) {
            .off
        } else if (flags.contains(.forcedOffBySensor)) {
            .forcedOffBySensor
        } else if (flags.contains(.cooling)) {
            .cooling
        } else if (flags.contains(.heating)) {
            .heating
        } else {
            .standby
        }
    }

    var issueIcon: IssueIconType? {
        if (online && flags.contains(.thermometerError)) {
            .error
        } else if (online && flags.contains(.batterCoverOpen)) {
            .error
        } else if (online && flags.contains(.clockError)) {
            .warning
        } else {
            nil
        }
    }
    
    var issueText: String? {
        if (flags.contains(.thermometerError)) {
            return Strings.ThermostatDetail.thermometerError
        } else if (flags.contains(.batterCoverOpen)) {
            return Strings.ThermostatDetail.batteryCoverOpen
        } else if (flags.contains(.clockError)) {
            return Strings.ThermostatDetail.clockError
        } else {
            return nil
        }
    }

    var setpointText: String? {
        if (!online) {
            return ""
        }
        
        @Singleton var formatter: ValuesFormatter
        
        switch (mode) {
        case .cool: return formatter.temperatureToString(setpointTemperatureCool)
        case .heat: return formatter.temperatureToString(setpointTemperatureHeat)
        case .off: return "Off"
        case .auto:
            let min = formatter.temperatureToString(setpointTemperatureHeat)
            let max = formatter.temperatureToString(setpointTemperatureCool)
            return "\(min) - \(max)"
        default: return ""
        }
    }
    
    static func from(_ hvacValue: THVACValue, online: Bool) -> ThermostatValue {
        ThermostatValue(
            online: online,
            state: ThermostatState(value: hvacValue.IsOn),
            mode: SuplaHvacMode.from(hvacMode: hvacValue.Mode),
            setpointTemperatureHeat: hvacValue.SetpointTemperatureHeat.fromSuplaTemperature(),
            setpointTemperatureCool: hvacValue.SetpointTemperatureCool.fromSuplaTemperature(),
            flags: SuplaThermostatFlag.from(flags: hvacValue.Flags)
        )
    }
}

struct ThermostatState {
    let value: UInt8
    var power: Float? { value > 1 ? Float(value) - 1 : nil }

    func isOn() -> Bool { value > 0 }
    func isOff() -> Bool { value == 0 }
}
