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

enum DarkModeSetting: Int, CaseIterable {
    case unset = 0
    case always = 1
    case never = 2
    case auto = 3
    
    var interfaceStyle: UIUserInterfaceStyle {
        switch (self) {
        case .unset, .never: .light
        case .always: .dark
        default: .unspecified
        }
    }
    
    static func from(_ value: Int) -> DarkModeSetting {
        for setting in DarkModeSetting.allCases {
            if (setting.rawValue == value) {
                return setting
            }
        }
        
        return .unset
    }
}
