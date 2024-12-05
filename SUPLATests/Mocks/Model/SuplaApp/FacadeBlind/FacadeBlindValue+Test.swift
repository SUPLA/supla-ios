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

@testable import SUPLA
import SharedCore

extension FacadeBlindValue {
    static func mockData(position: Int = 0, tilt: Int = 0, flags: Int32 = 0) -> Data {
        var cValue = TDSC_FacadeBlindValue(
            position: Int8(position),
            tilt: Int8(tilt),
            reserved: 0,
            flags: Int16(flags),
            reserved2: (0, 0, 0)
        )
        return Data(bytes: &cValue, count: MemoryLayout<TDSC_FacadeBlindValue>.size)
    }
}
