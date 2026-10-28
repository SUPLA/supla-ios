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
    struct SegmentedItem: View {
        let label: String
        let options: [String]
        let selectedIndex: Int
        let onChange: (Int) -> Void

        var body: some View {
            let items = options.enumerated().map { Option(id: $0.offset, label: $0.element) }
            let selected = Binding<Option>(
                get: { items[min(max(selectedIndex, 0), max(items.count - 1, 0))] },
                set: { onChange($0.id) }
            )

            SettingsView.Row {
                Text(label)
                    .fontBodyMedium()
                Spacer(minLength: Distance.small)
                SuplaCore.SegmentedPicker(selected: selected, items: items)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.vertical, 4)
            }
        }

        struct Option: PickerItem {
            let id: Int
            let label: String
        }
    }
}

#Preview {
    BackgroundStack(alignment: .top) {
        SettingsView.Block {
            SettingsView.SegmentedItem(
                label: "Temperature unit",
                options: ["°C", "°F"],
                selectedIndex: 0,
                onChange: { _ in }
            )
        }
    }
}
