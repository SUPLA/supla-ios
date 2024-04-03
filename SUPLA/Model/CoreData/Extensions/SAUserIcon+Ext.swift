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

extension SAUserIcon {
    func isEmpty() -> Bool {
        return uimage1 == nil && uimage2 == nil && uimage3 == nil && uimage4 == nil
    }

    func getIcon(_ icon: UserIcon, darkMode: Bool) -> NSObject? {
        return switch (icon) {
        case .icon1: darkMode && uimage1_dark != nil ? uimage1_dark : uimage1
        case .icon2: darkMode && uimage2_dark != nil ? uimage2_dark : uimage2
        case .icon3: darkMode && uimage3_dark != nil ? uimage3_dark : uimage3
        case .icon4: darkMode && uimage4_dark != nil ? uimage4_dark : uimage4
        }
    }
}
