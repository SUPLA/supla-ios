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
    let state: ThermostatState
    let mode: SuplaHvacMode
    let setpointTemperatureHeat: Float
    let setpointTemperatureCool: Float
    let flags: [SuplaThermostatFlag]
    
    var subfunction: ThermostatSubfunction {
        get { flags.contains(.heatOrCool) ? .cool : .heat }
    }
    
    static func from(hvacValue: THVACValue) -> ThermostatValue {
        ThermostatValue(
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
    
    func isOn() -> Bool { value > 0 }
    func isOff() -> Bool { value == 0 }
}
