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

protocol SubjectPickerItem: Hashable, Identifiable {
    var icon: IconResult? { get }
    var label: String { get }
    var isLocation: Bool { get }
}

extension SuplaCore {
    struct SubjectPicker<T: SubjectPickerItem>: View {
        @Binding var selected: T
        let items: [T]

        @State private var showPicker: Bool = false
        @Environment(\.isEnabled) private var isEnabled

        init(selected: Binding<T>, items: [T]) {
            self._selected = selected
            self.items = items
        }

        init(_ selectableList: SelectableList<T>, onChange: @escaping (T) -> Void) {
            self._selected = Binding<T>(
                get: { selectableList.selected },
                set: { onChange($0) }
            )
            self.items = selectableList.items
        }

        var body: some View {
            HStack {
                Text(selected.label)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontBodyMedium()
                    .textColor(isEnabled ? Color.Supla.onBackground : Color.Supla.disabled)
                Image(String.Icons.arrowDown)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(isEnabled ? Color.Supla.primary : Color.Supla.disabled)
            }
            .padding(Distance.small)
            .background(Color.Supla.surface)
            .cornerRadius(Dimens.buttonRadius)
            .onTapGesture { showPicker.toggle() }
            .popover(isPresented: $showPicker) {
                if #available(iOS 16.4, *) {
                    popoverView
                        .frame(minWidth: 300, maxHeight: 400)
                        .presentationCompactAdaptation(.popover)
                } else {
                    popoverView
                }
            }
        }

        private var popoverView: some View {
            LazyList(items: items) { item in
                HStack(alignment: .center) {
                    if let icon = item.icon {
                        icon.image
                            .resizable()
                            .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                    }
                    Text(item.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontBodyMedium()
                }
                .padding([.top, .bottom], Distance.small)
                .padding([.leading, .trailing], Distance.default)
                .background(item.isLocation ? Color.Supla.surfaceVariant : Color.Supla.surface)
                .onTapGesture {
                    selected = item
                    showPicker.toggle()
                }
            }
        }
    }
}
