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

extension SuplaCore {
    enum PickerStyle {
        case text
        case dialog
    }

    struct Picker<T: PickerItem>: View {
        var selected: Binding<T?>
        let items: [T]
        let padding: EdgeInsets?

        private var style: PickerStyle = .text
        @Environment(\.isEnabled) private var isEnabled
        
        private var defaultPadding: EdgeInsets {
            switch style {
            case .dialog:
                return .init(top: Distance.small, leading: Distance.small, bottom: Distance.small, trailing: Distance.small)
            case .text:
                return .init(top: 4, leading: Distance.default, bottom: 4, trailing: Distance.default)
            }
        }

        init(selected: Binding<T?>, items: [T], padding: EdgeInsets? = nil) {
            self.selected = selected
            self.items = items
            self.padding = padding
        }

        init(_ selectableList: SelectableList<T>, padding: EdgeInsets? = nil, onChange: @escaping (T?) -> Void) {
            self.selected = Binding<T?>(
                get: { selectableList.selected },
                set: { onChange($0) }
            )
            self.items = selectableList.items
            self.padding = padding
        }

        var body: some View {
            Menu {
                SwiftUI.Picker(selection: selected) {
                    ForEach(items) { item in
                        HStack {
                            Text(item.label)
                                .fontBodyMedium()
                                .padding([.top, .bottom], 4)
                                .padding([.leading, .trailing], Distance.default)
                        }.tag(item)
                    }
                } label: {
                    
                }
            } label: {
                switch (style) {
                case .text: textStyledPickerLabel()
                case .dialog: dialogStyledPickerLabel()
                }
            }
            .accentColor(Color.Supla.onBackground)
        }

        func style(_ pickerStyle: PickerStyle) -> Picker {
            var picker = self
            picker.style = pickerStyle
            return picker
        }

        private func textStyledPickerLabel() -> some View {
            HStack {
                Text(selected.wrappedValue?.label ?? "---")
                    .fontBodyMedium()
                    .textColor(isEnabled ? Color.Supla.onBackground : Color.Supla.disabled)
                Image(.Icons.arrowDown)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(isEnabled ? Color.Supla.onBackground : Color.Supla.disabled)
            }
            .padding(padding ?? defaultPadding)
        }

        private func dialogStyledPickerLabel() -> some View {
            HStack {
                Text(selected.wrappedValue?.label ?? "---")
                    .fontBodyMedium()
                    .textColor(isEnabled ? Color.Supla.onBackground : Color.Supla.disabled)
                Spacer()
                Image(.Icons.arrowDown)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(isEnabled ? Color.Supla.primary : Color.Supla.disabled)
            }
            .padding(padding ?? defaultPadding)
            .background(Color.Supla.surface)
            .cornerRadius(Dimens.buttonRadius)
            .overlay(RoundedRectangle(cornerRadius: Dimens.buttonRadius).stroke(Color.Supla.grayLighter))
        }
    }
}
