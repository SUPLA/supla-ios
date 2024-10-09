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

struct BorderedButton: View {
    var title: String
    var fullWidth: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            if (fullWidth) {
                Text.LabelLarge(text: title)
                    .frame(maxWidth: .infinity)
            } else {
                Text.LabelLarge(text: title)
            }
        }
        .buttonStyle(BorderedButtonStyle())
    }
}

#Preview {
    BorderedButton(title: "Title") {}
}

struct BorderedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let color = configuration.isPressed ? Color(UIColor.buttonPressed) : Color(UIColor.primary)
        configuration.label
            .foregroundColor(.Supla.onBackground)
            .font(.Supla.labelLarge)
            .cornerRadius(Dimens.buttonRadius)
            .padding(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
            .overlay(RoundedRectangle(cornerRadius: Dimens.buttonRadius).stroke(color, lineWidth: 1))
    }
}
