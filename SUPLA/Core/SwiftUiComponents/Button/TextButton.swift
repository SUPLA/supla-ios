//
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

struct TextButton: View {
    var title: String
    
    var normalColor: Color = .Supla.primary
    var pressedColor: Color = .Supla.buttonPressed
    
    var action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(TextButtonStyle(normalColor: normalColor, pressedColor: pressedColor))
    }
}

#Preview {
    TextButton(title: "Title") {}
}

#Preview("Blue") {
    TextButton(title: "Title", normalColor: .blue) {}
}

struct TextButtonStyle: ButtonStyle {
    var normalColor: Color
    var pressedColor: Color

    func makeBody(configuration: Configuration) -> some View {
        let color = configuration.isPressed ? pressedColor : normalColor
        configuration.label
            .foregroundColor(color)
            .font(.Supla.labelLarge)
            .cornerRadius(Dimens.buttonRadius)
            .padding(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
    }
}
