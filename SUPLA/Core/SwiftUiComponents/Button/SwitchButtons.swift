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

struct SwitchButtonState {
    let icon: IconResult?
    let label: String
    let active: Bool
    let type: BaseControlButtonView.ButtonType
}

struct SwitchButtons: View {
    let leftButton: SwitchButtonState?
    let rightButton: SwitchButtonState?
    
    let enabled: Bool

    let onRightButtonClick: () -> Void
    let onLeftButtonClick: () -> Void
    
    init(
        leftButton: SwitchButtonState?,
        rightButton: SwitchButtonState?,
        enabled: Bool = false,
        onLeftButtonClick: @escaping () -> Void = {},
        onRightButtonClick: @escaping () -> Void = {}
    ) {
        self.leftButton = leftButton
        self.rightButton = rightButton
        self.enabled = enabled
        self.onLeftButtonClick = onLeftButtonClick
        self.onRightButtonClick = onRightButtonClick
    }

    var body: some View {
        HStack(spacing: Distance.default) {
            if let leftButton {
                SwitchButton(
                    state: leftButton,
                    enabled: enabled,
                    onClick: onLeftButtonClick
                )
            }
            if let rightButton {
                SwitchButton(
                    state: rightButton,
                    enabled: enabled,
                    onClick: onRightButtonClick
                )
            }
        }
        .padding(Distance.default)
    }
}

struct SwitchButton: View {
    let state: SwitchButtonState
    let enabled: Bool
    let onClick: () -> Void
    
    var body: some View {
        RoundedControlButtonWrapperView(
            type: state.type,
            text: state.label,
            icon: state.icon,
            active: enabled && state.active,
            isEnabled: enabled,
            onTap: onClick
        )
        .frame(height: Dimens.buttonHeight)
    }
}
