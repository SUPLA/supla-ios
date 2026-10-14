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

struct SuplaButton<Content: View>: View {
    let colors: SuplaButtonColors
    let active: Bool
    let fullWidth: Bool
    let action: () -> Void
    let content: () -> Content
    let padding: EdgeInsets
    
    @Environment(\.isEnabled) private var isEnabled

    init(
        colors: SuplaButtonColors = .buttonColors,
        active: Bool = false,
        fullWidth: Bool = false,
        padding: EdgeInsets = standardPadding,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.colors = colors
        self.active = active
        self.fullWidth = fullWidth
        self.padding = padding
        self.action = action
        self.content = content
    }

    init(
        _ label: String,
        colors: SuplaButtonColors = .buttonColors,
        active: Bool = false,
        fullWidth: Bool = false,
        padding: EdgeInsets = standardPadding,
        action: @escaping () -> Void,
    ) where Content == AnyView {
        self.colors = colors
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
        colors: SuplaButtonColors = .buttonColors,
        active: Bool = false,
        fullWidth: Bool = false,
        padding: EdgeInsets = roundedPadding,
        action: @escaping () -> Void,
    ) where Content == AnyView {
        self.colors = colors
        self.active = active
        self.fullWidth = fullWidth
        self.padding = padding
        self.action = action
        content = {
            AnyView(
                icon.image
                    .resizable()
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
            SuplaButtonStyle(
                isSelected: active,
                colors: colors,
                padding: padding,
            )
        )
    }
}

private struct SuplaButtonStyle: ButtonStyle {
    let isSelected: Bool
    let colors: SuplaButtonColors
    let padding: EdgeInsets

    @Environment(\.isEnabled) private var isEnabled
    
    init(
        isSelected: Bool,
        colors: SuplaButtonColors,
        padding: EdgeInsets = standardPadding,
    ) {
        self.isSelected = isSelected
        self.colors = colors
        self.padding = padding
    }

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed || isSelected
        let radius = Dimens.buttonHeight / 2
        let borderColor = colors.border(active: isSelected, disabled: !isEnabled)
        let foregroundColor = colors.content(active: isSelected, disabled: !isEnabled)
        
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
        HStack {
            SuplaButton(
                "Neutral",
                active: false,
                action: {}
            )
            SuplaButton(
                "Neutral",
                active: true,
                action: {}
            )
            SuplaButton(
                "Neutral",
                active: true,
                action: {}
            ).disabled(true)
        }

        HStack {
            SuplaButton(
                "Negative",
                colors: .errorColors,
                active: false,
                action: {}
            )
            SuplaButton(
                "Negative",
                colors: .errorColors,
                active: true,
                action: {}
            )
        }
        HStack {
            SuplaButton(
                "Positive",
                colors: .primaryColors,
                active: false,
                action: {}
            )
            SuplaButton(
                "Positive",
                colors: .primaryColors,
                active: true,
                action: {}
            )
        }
        SuplaButton(
            "Neutral full width",
            active: false,
            fullWidth: true,
            action: {}
        )
        HStack {
            SuplaButton(
                .suplaIcon(name: .Icons.soundOff),
                colors: .primaryColors.copy(content: .Supla.primary),
                action: {}
            )
            SuplaButton(
                .suplaIcon(name: .Icons.soundOff),
                colors: .primaryColors.copy(borderDisabledAndPressed: .Supla.primary),
                active: true,
                action: {}
            ).disabled(true)
        }
    }
    .padding(Distance.default)
}
