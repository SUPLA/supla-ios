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

struct IconButton: View {
    let name: String
    let size: ButtonSize
    let action: () -> Void

    init(
        name: String,
        size: ButtonSize = .icon,
        action: @escaping () -> Void
    ) {
        self.name = name
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(name)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: Dimens.iconSize, height: Dimens.iconSize)
            }
            .padding(size.paddings)
            .frame(width: size.height, height: size.height)
        }
    }
}

extension View {
    func iconButtonStyle(colors: ButtonLayerColors = .primary) -> some View {
        self.buttonStyle(IconButtonStyle(colors: colors))
    }
}

private struct IconButtonStyle: ButtonStyle {
    let colors: ButtonLayerColors

    @Environment(\.isEnabled) private var isEnabled

    init(colors: ButtonLayerColors = .primary) {
        self.colors = colors
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(colors.value(disabled: !isEnabled, pressed: configuration.isPressed))
            .cornerRadius(Dimens.buttonRadius)
    }
}

#Preview {
    VStack {
        IconButton(name: .Icons.arrowClose) {}
            .buttonStyle(IconButtonStyle())
        IconButton(name: .Icons.arrowRight) {}
            .borderedButtonStyle()
        IconButton(name: .Icons.arrowRight) {}
            .filledButtonStyle()
        IconButton(name: .Icons.minus) {}
            .borderedButtonStyle(colors: .criticalBordered, radius: Dimens.iconSize)
    }
}
