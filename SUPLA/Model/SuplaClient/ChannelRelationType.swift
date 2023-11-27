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

enum ChannelRelationType: Int16, CaseIterable {
    case defaultType = 0
    case openingSensor = 1
    case partialOpeningSensor = 2
    case meter = 3
    case mainThermometer = 4
    case auxThermometerFloor = 5
    case auxThermometerWater = 6
    case auxThermometerGenericHeater = 7
    case auxThermometerGenericCooler = 8
    
    func isAux() -> Bool {
        switch (self) {
        case .auxThermometerFloor,
                .auxThermometerWater,
                .auxThermometerGenericCooler,
                .auxThermometerGenericHeater:
            return true
        default: return false
        }
    }
    
    func isThermometer() -> Bool {
        switch (self) {
        case .mainThermometer,
                .auxThermometerFloor,
                .auxThermometerWater,
                .auxThermometerGenericCooler,
                .auxThermometerGenericHeater:
            return true
        default: return false
        }
    }
}

extension ChannelRelationType {
    static func from(_ value: Int16) -> ChannelRelationType {
        for type in ChannelRelationType.allCases {
            if (type.rawValue == value) {
                return type
            }
        }
        
        fatalError("Invalid value for ChannelRelationType `\(value)`")
    }
}
