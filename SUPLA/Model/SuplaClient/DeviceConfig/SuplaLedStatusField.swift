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

enum SuplaLedStatusType: UInt8, CaseIterable {
    case onWhenConnected = 0
    case offWhenConnected = 1
    case alwaysOff = 2
    
    static func from(value: UInt8) -> SuplaLedStatusType {
        for field in SuplaLedStatusType.allCases {
            if (field.rawValue == value) {
                return field
            }
        }
        
        SALog.error("Invalid SuplaLedStatusType value `\(value)'")
        return .onWhenConnected
    }
}

struct SuplaLedStatusField: SuplaField {
    let type: SuplaFieldType = .statusLed
    let ledStatus: SuplaLedStatusType
    
    init(config: TDeviceConfig_StatusLed) {
        ledStatus = SuplaLedStatusType.from(value: config.StatusLedType)
    }
    
    init(ledStatus: SuplaLedStatusType) {
        self.ledStatus = ledStatus
    }
}


