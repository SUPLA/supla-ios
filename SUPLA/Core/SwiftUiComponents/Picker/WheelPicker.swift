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
    struct WheelPicker<T: PickerItem>: View {
        var selected: Binding<T>
        let items: [T]
        
        init(selected: Binding<T>, items: [T]) {
            self.selected = selected
            self.items = items
        }
        
        var body: some View {
            SwiftUI.Picker(selection: selected) {
                ForEach(self.items, id: \.self) { item in
                    Text(item.label).fontBodyMedium().tag(item)
                }
            } label: {}
                .pickerStyle(.wheel)
        }
    }
}
