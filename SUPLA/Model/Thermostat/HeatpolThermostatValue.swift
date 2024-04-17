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

struct HeatpolThermostatValue {
    let online: Bool
    let on: Bool
    let flags: [SuplaHeatpolThermostatFlag]
    let measuredTemperature: Float
    let presetTemperature: Float
    
    static func from(_ data: Data, online: Bool) -> HeatpolThermostatValue {
        if (data.count < MemoryLayout<TThermostat_Value>.size) {
            return HeatpolThermostatValue(online: online, on: false, flags: [], measuredTemperature: 0, presetTemperature: 0)
        }
        let value = data.withUnsafeBytes { $0.load(as: TThermostat_Value.self) }
        
        return HeatpolThermostatValue(
            online: online,
            on: value.IsOn == 1,
            flags: SuplaHeatpolThermostatFlag.from(flags: value.Flags),
            measuredTemperature: Float(value.MeasuredTemperature) / 100,
            presetTemperature: Float(value.PresetTemperature) / 100
        )
    }
}
