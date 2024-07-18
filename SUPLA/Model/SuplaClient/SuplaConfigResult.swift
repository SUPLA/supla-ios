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

enum SuplaConfigResult: UInt8, CaseIterable {
    case resultFalse = 0
    case resultTrue = 1
    case dataError = 2
    case typeNotSupported = 3
    case functionNotSupported = 4
    case localConfigDisabled = 5
    case notAllowed = 6
    
    
    static func from(value: UInt8) -> SuplaConfigResult {
        for result in SuplaConfigResult.allCases {
            if (result.rawValue == value) {
                return result
            }
        }
        
        SALog.error("Invalid SuplaConfigResult value `\(value)'")
        return .resultFalse
    }
}
