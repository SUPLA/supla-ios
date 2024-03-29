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

struct RollerShutterValue {
    let online: Bool
    let position: Int
    let bottomPosition: Int
    let flags: [SuplaRollerShutterFlag]
    
    var hasValidPosition: Bool {
        position != RollerShutterValue.invalidPosition
    }
    
    static let invalidPosition = -1
    static let invalidBottomPosition = 0 // more precisely <= 0
    static let maxPosition = 100
    
    static func from(_ data: Data, online: Bool) -> RollerShutterValue {
        if (data.count < MemoryLayout<TDSC_RollerShutterValue>.size) {
            return RollerShutterValue(online: online, position: invalidPosition, bottomPosition: 0, flags: [])
        }
        let value = data.withUnsafeBytes { $0.load(as: TDSC_RollerShutterValue.self) }
        
        return RollerShutterValue(
            online: online,
            position: Int(value.position).run { $0 < invalidPosition || $0 > maxPosition ? invalidPosition : $0 },
            bottomPosition: Int(value.bottom_position)
                .run { $0 <= invalidBottomPosition || $0 > maxPosition ? maxPosition : $0 },
            flags: SuplaRollerShutterFlag.from(flags: value.flags)
        )
    }
}
