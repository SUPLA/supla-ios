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

struct SwitchButtons: View {
    let isOn: Bool
    let enabled: Bool
    let onIcon: IconResult?
    let offIcon: IconResult?

    let onTurnOnClick: () -> Void
    let onTurnOffClick: () -> Void

    var body: some View {
        HStack(spacing: Distance.default) {
            RoundedControlButtonWrapperView(
                type: .negative,
                text: Strings.General.turnOff,
                icon: offIcon,
                active: enabled && !isOn,
                isEnabled: enabled,
                onTap: onTurnOffClick
            )
            .frame(height: Dimens.buttonHeight)
            RoundedControlButtonWrapperView(
                type: .positive,
                text: Strings.General.turnOn,
                icon: onIcon,
                active: enabled && isOn,
                isEnabled: enabled,
                onTap: onTurnOnClick
            )
            .frame(height: Dimens.buttonHeight)
        }
        .padding(Distance.default)
    }
}
