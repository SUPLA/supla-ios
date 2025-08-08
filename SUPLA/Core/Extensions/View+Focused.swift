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

extension View {
    @ViewBuilder
    func focused<Value>(_ binding: Binding<Value?>, equals value: Value) -> some View where Value: Hashable {
        self.modifier(TextFieldFocused(binding: binding, value: value))
    }
}

private struct TextFieldFocused<Value>: ViewModifier where Value: Hashable {
    private let value: Value
    @FocusState private var focused: Value?
    @Binding private var binding: Value?

    init(binding: Binding<Value?>, value: Value) {
        self._binding = binding
        self.value = value
    }

    func body(content: Content) -> some View {
        content
            .focused($focused, equals: value)
            .onChange(of: binding) { newValue in
                focused = newValue
            }
            .onChange(of: focused) { newValue in
                if newValue != nil {
                    binding = newValue
                }
            }
            .onAppear {
                focused = binding
            }
    }
}

