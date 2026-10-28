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

extension SettingsView {
    struct TextFieldItem: View {
        let label: String
        @Binding var value: String
        let prefix: String?
        let suffix: String?
        let width: CGFloat?
        let height: CGFloat?
        let keyboardType: UIKeyboardType

        init(
            label: String,
            value: Binding<String>,
            prefix: String? = nil,
            suffix: String? = nil,
            width: CGFloat? = nil,
            height: CGFloat? = 32,
            keyboardType: UIKeyboardType = .decimalPad
        ) {
            self.label = label
            self._value = value
            self.prefix = prefix
            self.suffix = suffix
            self.width = width
            self.height = height
            self.keyboardType = keyboardType
        }

        var body: some View {
            SettingsView.Row {
                SettingsView.Label(label)
                Spacer(minLength: Distance.small)
                AccessoryTextField(
                    text: $value,
                    height: height,
                    prefix: {
                        if let prefix {
                            AccessoryText(prefix)
                        }
                    },
                    suffix: {
                        if let suffix {
                            AccessoryText(suffix)
                        }
                    }
                )
                .keyboardType(keyboardType)
                .frame(width: width)
            }
        }
    }
}

#Preview {
    BackgroundStack {
        SettingsView.Block {
            SettingsView.TextFieldItem(
                label: "Low battery alert",
                value: .constant("25"),
                prefix: "<",
                suffix: "%",
                width: 112
            )
        }
    }
}
