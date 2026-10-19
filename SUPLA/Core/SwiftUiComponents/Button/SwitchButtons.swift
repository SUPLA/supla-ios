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
    let colors: SuplaButtonColors
}

struct SwitchButtons: View {
    let leftButton: SwitchButtonState?
    let rightButton: SwitchButtonState?
    
    let enabled: Bool

    let onRightButtonClick: () -> Void
    let onLeftButtonClick: () -> Void
    
    let padding: EdgeInsets?
    let spacing: CGFloat?
    
    init(
        leftButton: SwitchButtonState?,
        rightButton: SwitchButtonState?,
        enabled: Bool = false,
        padding: EdgeInsets? = nil,
        spacing: CGFloat? = nil,
        onLeftButtonClick: @escaping () -> Void = {},
        onRightButtonClick: @escaping () -> Void = {}
    ) {
        self.leftButton = leftButton
        self.rightButton = rightButton
        self.enabled = enabled
        self.padding = padding
        self.spacing = spacing
        self.onLeftButtonClick = onLeftButtonClick
        self.onRightButtonClick = onRightButtonClick
    }

    var body: some View {
        HStack(spacing: spacing ?? Distance.default) {
            if let leftButton {
                SwitchButton(
                    state: leftButton,
                    onClick: onLeftButtonClick
                )
                .disabled(!enabled)
            }
            if let rightButton {
                SwitchButton(
                    state: rightButton,
                    onClick: onRightButtonClick
                )
                .disabled(!enabled)
            }
        }
        .padding(padding ?? SwitchButtons.defaultPadding)
    }
    
    private static let defaultPadding = EdgeInsets(top: Distance.default, leading: Distance.default, bottom: Distance.default, trailing: Distance.default)
}

struct SwitchButton: View {
    let label: String
    let icon: IconResult?
    let colors: SuplaButtonColors
    let active: Bool
    let fullWidth: Bool
    let onClick: () -> Void
    
    init(
        state: SwitchButtonState,
        fullWidth: Bool = true,
        onClick: @escaping () -> Void
    ) {
        self.colors = state.colors
        self.label = state.label
        self.icon = state.icon
        self.active = state.active
        self.fullWidth = fullWidth
        self.onClick = onClick
    }
    
    init(
        _ label: String,
        colors: SuplaButtonColors = .buttonColors,
        active: Bool = false,
        fullWidth: Bool = true,
        onClick: @escaping () -> Void
    ) {
        self.label = label
        self.icon = nil
        self.active = active
        self.colors = colors
        self.fullWidth = fullWidth
        self.onClick = onClick
    }

    var body: some View {
        SuplaButton(
            colors: colors,
            active: active,
            fullWidth: fullWidth,
            action: onClick
        ) {
            HStack(spacing: Distance.tiny) {
                if let icon {
                    icon.image
                        .resizable()
                        .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                }
                Text(label)
                    .fontLabelLarge()
            }
        }
    }
}

#Preview {
    VStack(spacing: Distance.small) {
        SwitchButton("Title only", onClick: {})
        SwitchButton(
            state: SwitchButtonState(
                icon: .originalSuplaIcon(name: .Icons.fncDimmerOff),
                label: "Title icon",
                active: false,
                colors: .primaryColors
            ),
            onClick: {}
        )
        SwitchButton(
            state: SwitchButtonState(
                icon: .originalSuplaIcon(name: .Icons.fncDimmerOff),
                label: "Title icon",
                active: true,
                colors: .primaryColors
            ),
            onClick: {}
        )
    }
    .padding(Distance.default)
}
