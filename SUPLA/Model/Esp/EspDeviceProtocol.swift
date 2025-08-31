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

enum EspDeviceProtocol {
    case supla
    case mqtt
    case unknown(id: Int)

    var id: Int {
        switch (self) {
        case .supla: 0
        case .mqtt: 1
        case .unknown(let id): id
        }
    }

    static func from(_ string: String?) -> EspDeviceProtocol? {
        guard let string else { return nil }
        let id = Int(string) ?? 0
        
        return switch (id) {
        case 0: .supla
        case 1: .mqtt
        default: .unknown(id: id)
        }
    }
}
