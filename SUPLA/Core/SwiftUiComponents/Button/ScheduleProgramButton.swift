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

private let radius: CGFloat = 16

enum ScheduleProgramButtonState {
    case active(color: Color, label: String, icon: String?)
    case `default`(color: Color, label: String, icon: String?)

    var color: Color {
        switch self {
        case .active(let color, _, _):
            return color
        case .default(let color, _, _):
            return color
        }
    }

    var label: String {
        switch self {
        case .active(_, let label, _):
            return label
        case .default(_, let label, _):
            return label
        }
    }
    
    var icon: String? {
        switch self {
        case .active(_, _, let icon):
            return icon
        case .default(_, _, let icon):
            return icon
        }
    }

    var isActive: Bool {
        switch self {
        case .active: true
        case .default: false
        }
    }
}

struct ScheduleProgramButton: View {
    let state: ScheduleProgramButtonState
    let action: () -> Void
    let onLongPress: (() -> Void)?
    
    init(
        state: ScheduleProgramButtonState,
        action: @escaping () -> Void,
        onLongPress: (() -> Void)? = nil
    ) {
        self.state = state
        self.action = action
        self.onLongPress = onLongPress
    }

    var body: some View {
        let button = Button(
            action: action,
            label: {
                HStack {
                    if let icon = state.icon {
                        Image(icon)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: Dimens.iconSizeSmall, height: Dimens.iconSizeSmall)
                            .foregroundColor(.black)
                    }
                    Text(state.label)
                        .fontLabelMedium()
                        .textColor(.black)
                }
            }
        ).buttonStyle(ScheduleProgramButtonStyle(state: state))

        if let onLongPress {
            button.simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in onLongPress() }
            )
        } else {
            button
        }
    }
}

private struct ScheduleProgramButtonStyle: ButtonStyle {
    let state: ScheduleProgramButtonState

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Distance.small)
            .frame(minHeight: radius * 2)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(state.color)
            )
            .if(state.isActive || configuration.isPressed) {
                $0.overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(Color.Supla.onBackground)
                )
            }
            .padding(.vertical, 1) // To avoid cutting od border line
    }
}

#Preview {
    VStack {
        HStack {
            ScheduleProgramButton(
                state: .active(color: .Supla.lightBlue, label: "22.5°", icon: nil),
                action: {},
                onLongPress: {}
            )
            ScheduleProgramButton(
                state: .default(color: .Supla.lightRed, label: "21.0°", icon: nil),
                action: {},
                onLongPress: {}
            )
        }
    }
}
