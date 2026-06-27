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

let standardPadding = EdgeInsets(top: 0, leading: Distance.default, bottom: 0, trailing: Distance.default)
let roundedPadding = EdgeInsets(top: 0, leading: Distance.tiny, bottom: 0, trailing: Distance.tiny)

struct RoundedControlButton<Content: View>: View {
    let type: RoundedControlButtonType
    let active: Bool
    let fullWidth: Bool
    let action: () -> Void
    let content: () -> Content
    let padding: EdgeInsets
    
    @Environment(\.isEnabled) private var isEnabled

    init(
        type: RoundedControlButtonType = .neutral,
        active: Bool = false,
        fullWidth: Bool = false,
        padding: EdgeInsets = standardPadding,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.type = type
        self.active = active
        self.fullWidth = fullWidth
        self.padding = padding
        self.action = action
        self.content = content
    }

    init(
        _ label: String,
        type: RoundedControlButtonType = .neutral,
        active: Bool = false,
        fullWidth: Bool = false,
        padding: EdgeInsets = standardPadding,
        action: @escaping () -> Void,
    ) where Content == AnyView {
        self.type = type
        self.active = active
        self.fullWidth = fullWidth
        self.padding = padding
        self.action = action
        content = {
            AnyView(
                Text(label)
                    .fontLabelLarge()
            )
        }
    }
    
    init(
        _ icon: IconResult,
        type: RoundedControlButtonType = .neutral,
        active: Bool = false,
        fullWidth: Bool = false,
        color: Color? = nil,
        padding: EdgeInsets = roundedPadding,
        action: @escaping () -> Void,
    ) where Content == AnyView {
        self.type = type
        self.active = active
        self.fullWidth = fullWidth
        self.padding = padding
        self.action = action
        content = {
            AnyView(
                icon.image
                    .resizable()
                    .if(color != nil) { $0.foregroundColor(color!) }
                    .frame(width: Dimens.iconSize, height: Dimens.iconSize)
            )
        }
    }

    var body: some View {
        Button(
            action: {
                if (isEnabled) {
                    action()
                }
            }
        ) {
            content()
                .frame(height: Dimens.buttonHeight)
                .if(fullWidth) { $0.frame(maxWidth: .infinity) }
        }
        .buttonStyle(
            RoundedControlButtonStyle(
                isSelected: isEnabled && active,
                type: type,
                padding: padding
            )
        )
    }
}

enum RoundedControlButtonType {
    case positive, negative, neutral

    var pressedColor: Color {
        switch (self) {
        case .positive: return .Supla.primary
        case .negative: return .Supla.error
        case .neutral: return .Supla.onBackground
        }
    }

    var textColor: UIColor {
        switch (self) {
        case .positive: return .onBackground
        case .negative: return .negativeBorder
        case .neutral: return .black
        }
    }

    var inactiveColor: UIColor {
        switch (self) {
        case .positive: return .onBackground
        case .negative: return .onBackground
        case .neutral: return .black
        }
    }
}

private struct RoundedControlButtonStyle: ButtonStyle {
    let isSelected: Bool
    let type: RoundedControlButtonType
    let padding: EdgeInsets
    
    init(
        isSelected: Bool,
        type: RoundedControlButtonType,
        padding: EdgeInsets = standardPadding
    ) {
        self.isSelected = isSelected
        self.type = type
        self.padding = padding
    }

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed || isSelected
        let radius = Dimens.buttonHeight / 2
        let borderColor = pressed ? type.pressedColor : Color.Supla.disabled
        let foregroundColor = pressed ? type.pressedColor : Color.Supla.onBackground

        configuration.label
            .padding(padding)
            .foregroundColor(foregroundColor)
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.Supla.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(borderColor, lineWidth: 1)
                    }
                    .shadow(color: borderColor.opacity(0.4), radius: 3, x: 0, y: 3)
                    .overlay {
                        if pressed {
                            InnerShadowRounded(cornerRadius: 32)
                        }
                    }
            }
    }
}

private struct InnerShadowRounded: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(Color.black.opacity(0.22), lineWidth: 2)
            .blur(radius: 2)
            .offset(x: 1.5, y: 1.5)
            .mask(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(LinearGradient(
                        colors: [.black, .clear],
                        startPoint: .bottomTrailing,
                        endPoint: .topLeading
                    ))
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.7), lineWidth: 2)
                    .blur(radius: 2)
                    .offset(x: -1.5, y: -1.5)
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(LinearGradient(
                                colors: [.black, .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

#Preview {
    VStack(spacing: Distance.small) {
        RoundedControlButton(
            "Inactive",
            active: false,
            action: {}
        )
        RoundedControlButton(
            "Negative",
            type: .negative,
            active: true,
            action: {}
        )
        RoundedControlButton(
            "Positive",
            type: .positive,
            active: true,
            action: {}
        )
        RoundedControlButton(
            "Neutral",
            type: .neutral,
            active: true,
            action: {}
        )
        RoundedControlButton(
            "Neutral full width",
            type: .neutral,
            active: false,
            fullWidth: true,
            action: {}
        )
        RoundedControlButton(
            .suplaIcon(name: .Icons.soundOff),
            type: .positive,
            color: .Supla.primary,
            action: {}
        )
    }
    .padding(Distance.default)
}
