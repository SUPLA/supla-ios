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

import SharedCore

extension IssueIcon {
    var resource: UIImage? {
        switch onEnum(of: self) {
        case .warning: .iconWarning
        case .error: .iconError
        case .battery: .iconBattery
        case .battery0: .iconBattery0
        case .battery100: .iconBattery100
        case .battery25: .iconBattery25
        case .battery50: .iconBattery50
        case .battery75: .iconBattery75
        case .batteryNotUsed: .iconBatteryNotUsed
        }
    }

    var name: String {
        switch onEnum(of: self) {
        case .warning: "warning"
        case .error: "error"
        case .battery: "battery"
        case .battery0: "battery0"
        case .battery100: "battery100"
        case .battery25: "battery25"
        case .battery50: "battery50"
        case .battery75: "battery75"
        case .batteryNotUsed: "batteryNotUsed"
        }
    }
}