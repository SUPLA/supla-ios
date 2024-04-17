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

struct FacadeBlindValue: ShadingSystemValue {
    let online: Bool
    let position: Int
    let tilt: Int
    let flags: [SuplaRollerShutterFlag]

    var hasValidTilt: Bool {
        tilt != SHADING_SYSTEM_INVALID_VALUE
    }

    static let maxValue = 100

    static func from(_ data: Data, online: Bool) -> FacadeBlindValue {
        if (data.count < MemoryLayout<TDSC_FacadeBlindValue>.size) {
            return FacadeBlindValue(online: online, position: SHADING_SYSTEM_INVALID_VALUE, tilt: SHADING_SYSTEM_INVALID_VALUE, flags: [])
        }
        let value = data.withUnsafeBytes { $0.load(as: TDSC_FacadeBlindValue.self) }

        return FacadeBlindValue(
            online: online,
            position: Int(value.position).run { $0 < SHADING_SYSTEM_INVALID_VALUE || $0 > maxValue ? SHADING_SYSTEM_INVALID_VALUE : $0 },
            tilt: Int(value.tilt).run { $0 < SHADING_SYSTEM_INVALID_VALUE || $0 > maxValue ? SHADING_SYSTEM_INVALID_VALUE : $0 },
            flags: SuplaRollerShutterFlag.from(flags: value.flags)
        )
    }
}
