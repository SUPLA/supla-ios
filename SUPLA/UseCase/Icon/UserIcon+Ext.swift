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

extension UserIcon {
    private var localDarkMode: Bool {
        @Singleton<GlobalSettings> var settings

        return settings.darkMode == .always
            || (settings.darkMode == .auto && UITraitCollection.current.userInterfaceStyle == .dark)
    }

    func type(darkMode: Bool? = nil) -> UserIcons.IconType {
        switch (self) {
        case .icon1: darkMode ?? localDarkMode ? .night0 : .light0
        case .icon2: darkMode ?? localDarkMode ? .night1 : .light1
        case .icon3: darkMode ?? localDarkMode ? .night2 : .light2
        case .icon4: darkMode ?? localDarkMode ? .night3 : .light3
        }
    }
}
