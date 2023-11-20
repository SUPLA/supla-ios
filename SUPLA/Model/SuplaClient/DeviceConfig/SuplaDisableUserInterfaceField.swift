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

enum SuplaUiDisabledType: UInt8, CaseIterable {
    case no = 0
    case yes = 1
    case partial = 2
    
    static func from(value: UInt8) -> SuplaUiDisabledType {
        for type in SuplaUiDisabledType.allCases {
            if (type.rawValue == value) {
                return type
            }
        }
        
        fatalError("SuplaUiDisabledType not expected value `\(value)`")
    }
}

struct SuplaDisableUserInterfaceField: SuplaField {
    let type: SuplaFieldType = .disableUserInterface
    let disabled: SuplaUiDisabledType
    let minAllowedTemperature: UInt16
    let maxAllowedTemperature: UInt16
    
    init(config: TDeviceConfig_DisableUserInterface) {
        disabled = SuplaUiDisabledType.from(value: config.DisableUserInterface)
        minAllowedTemperature = config.minAllowedTemperatureSetpointFromLocalUI
        maxAllowedTemperature = config.maxAllowedTemperatureSetpointFromLocalUI
    }
    
    init(disabled: SuplaUiDisabledType, minAllowedTemperature: UInt16, maxAllowedTemperature: UInt16) {
        self.disabled = disabled
        self.minAllowedTemperature = minAllowedTemperature
        self.maxAllowedTemperature = maxAllowedTemperature
    }
}

