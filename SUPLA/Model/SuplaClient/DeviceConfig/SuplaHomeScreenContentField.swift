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

enum SuplaHomeScreenContent: Int, CaseIterable {
    case none = 0
    case temperature = 1
    case temperatureAndHumidity = 2
    case time = 3
    case timeAndDate = 4
    case temperatureAndTime = 5
    case mainAndAuxTemperature = 6
    
    var value: UInt64 {
        UInt64(1 << rawValue)
    }
    
    static func from(bits: UInt64) -> [SuplaHomeScreenContent] {
        var result: [SuplaHomeScreenContent] = []
        
        for field in SuplaHomeScreenContent.allCases {
            if ((field.value & bits) > 0) {
                result.append(field)
            }
        }
        
        return result
    }
    
    static func from(value: UInt64) -> SuplaHomeScreenContent {
        for field in SuplaHomeScreenContent.allCases {
            if ((field.value & value) > 0) {
                return field
            }
        }
        
        fatalError("SuplaHomeScreenContent not expected value `\(value)`")
    }
}

struct SuplaHomeScreenContentField: SuplaField {
    let type: SuplaFieldType = .homeScreenContent
    let available: [SuplaHomeScreenContent]
    let content: SuplaHomeScreenContent
    
    init(config: TDeviceConfig_HomeScreenContent) {
        available = SuplaHomeScreenContent.from(bits: config.ContentAvailable)
        content = SuplaHomeScreenContent.from(value: config.HomeScreenContent)
    }
    
    init(available: [SuplaHomeScreenContent], content: SuplaHomeScreenContent) {
        self.available = available
        self.content = content
    }
}
