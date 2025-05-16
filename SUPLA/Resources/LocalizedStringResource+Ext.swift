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

import SwiftUI

@available(iOS 17, *)
extension LocalizedStringResource {
    enum General {
        static var action: LocalizedStringResource { LocalizedStringResource("general_action", defaultValue: "Action") }
    }

    enum Widgets {
        static var controlNameDefault = String.LocalizationValue("Control Button")
        static var controlName: LocalizedStringResource { LocalizedStringResource("widgets_control_title", defaultValue: controlNameDefault) }
        static var controlDescription: LocalizedStringResource { LocalizedStringResource("widgets_control_description", defaultValue: "Button which allows to perform a predefined single action.") }
    }
}
