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

struct FilledButton: View {
    var title: String
    var fullWidth: Bool = false
    var action: () -> Void
    
    @Environment(\.isEnabled) var isEnabled
    
    var body: some View {
        return Button(action: action) {
            if (fullWidth) {
                Text.LabelLarge(text: title)
                    .frame(maxWidth: .infinity)
            } else {
                Text.LabelLarge(text: title)
            }
        }
        .buttonStyle(FilledButtonStyle(isEnabled: isEnabled))
    }
}

#Preview {
    VStack {
        FilledButton(title: "Title") {}
        FilledButton(title: "Title", fullWidth: true) {}
    }
}

struct FilledButtonStyle: ButtonStyle {
    private let isEnabled: Bool
    
    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor = if(!isEnabled) {
            Color.Supla.disabled
        } else if (configuration.isPressed) {
            Color.Supla.primaryVariant
        } else {
            Color.Supla.primary
        }
        
        configuration.label
            .foregroundColor(.Supla.onPrimary)
            .font(.Supla.labelLarge)
            .padding(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
            .background(backgroundColor)
            .cornerRadius(Dimens.buttonRadius)
    }
}
