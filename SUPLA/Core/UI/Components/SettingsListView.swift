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

struct SettingsListView<Content: View>: SwiftUI.View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 1) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Supla.background)
    }
}

struct SettingsItemWithCheckbox: SwiftUI.View {
    let label: String
    let onChange: ((Bool) -> Void)?
    
    @Binding private var checked: Bool
    
    init(label: String, checked: Binding<Bool>, onChange: ((Bool) -> Void)? = nil) {
        self.label = label
        self._checked = checked
        self.onChange = onChange
    }
    
    var body: some View {
        HStack {
            Toggle(isOn: $checked) {
                Text(label)
                    .fontBodyMedium()
            }
            .onChange(of: checked) { onChange?($0) }
        }
        .padding([.leading, .trailing], Distance.default)
        .padding([.top, .bottom], Distance.small)
        .background(Color.Supla.surface)
    }
}
