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
    struct ItemWithCheckbox: SwiftUI.View {
        let label: String
        let padding: EdgeInsets?
        let onChange: ((Bool) -> Void)?

        @Binding private var checked: Bool

        init(label: String, checked: Binding<Bool>, padding: EdgeInsets? = nil, onChange: ((Bool) -> Void)? = nil) {
            self.label = label
            self._checked = checked
            self.padding = padding
            self.onChange = onChange
        }

        var body: some View {
            SettingsView.Row {
                Toggle(isOn: $checked) {
                    Text(label)
                        .fontBodyMedium()
                }
                .onChange(of: checked) { onChange?($0) }
                .padding(padding ?? ItemWithCheckbox.defaultPadding)
                .tint(Color.Supla.primary)
            }
        }
        
        private static let defaultPadding: EdgeInsets = EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
    }
}

#Preview {
    BackgroundStack(alignment: .top) {
        SettingsView.Block {
            SettingsView.ItemWithCheckbox(label: "Show channel info", checked: .constant(true))
        }
    }
}
