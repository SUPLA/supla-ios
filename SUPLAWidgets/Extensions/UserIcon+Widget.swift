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
    
import UIKit

extension UserIcon {
    var darkMode: Bool { UITraitCollection.current.userInterfaceStyle == .dark }

    var type: UserIcons.IconType {
        switch (self) {
        case .icon1: darkMode ? .night0 : .light0
        case .icon2: darkMode ? .night1 : .light1
        case .icon3: darkMode ? .night2 : .light2
        case .icon4: darkMode ? .night3 : .light3
        }
    }
}
