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

import Combine
import SwiftUI

let PIN_LENGTH = 4

struct PinTextFieldModifier<Value: Hashable>: ViewModifier {
    @Binding var value: String

    @Binding private var focusedField: Value?

    @State private var previousValue: String = ""
    private var isError: Bool = false

    private var pinLength = PIN_LENGTH
    private var focusValue: Value? = nil
    private var onChange: (String) -> Void = { _ in }
    private var keyboardType: UIKeyboardType = .numberPad

    init(_ value: Binding<String>) {
        self._value = value
        self._focusedField = .constant(nil)
    }

    func focused(_ binding: Binding<Value?>, equals: Value) -> Self {
        var copy = self
        copy._focusedField = binding
        copy.focusValue = equals
        return copy
    }

    func error(_ binding: Bool) -> Self {
        var copy = self
        copy.isError = binding
        return copy
    }

    func onChange(_ onChange: @escaping (String) -> Void) -> Self {
        var copy = self
        copy.onChange = onChange
        return copy
    }

    func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        var copy = self
        copy.keyboardType = keyboardType
        return copy
    }

    func pinLenght(_ length: Int) -> Self {
        var copy = self
        copy.pinLength = length
        return copy
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            HStack {
                ForEach(0 ..< pinLength, id: \.self) { index in
                    PinItem(index, focused: focusedField == focusValue)
                }
            }

            if let focusValue = focusValue {
                HiddenTextField(content)
                    .focused($focusedField, equals: focusValue)
            } else {
                HiddenTextField(content)
            }
        }
    }

    @ViewBuilder
    private func HiddenTextField(_ content: Content) -> some View {
        content
            .frame(width: 192, height: 56, alignment: .center)
            .font(.system(size: 0))
            .accentColor(.clear)
            .foregroundColor(.clear)
            .multilineTextAlignment(.center)
            .keyboardType(keyboardType)
            .padding()
            .onReceive(Just(value)) { _ in
                if (value.count > pinLength) {
                    value = String(value.prefix(pinLength))
                }
                if (previousValue != value) {
                    previousValue = value
                    onChange(previousValue)
                }
            }
    }

    @ViewBuilder
    private func PinItem(_ index: Int, focused: Bool = false) -> some View {
        let itemFocused = value.count == index || (value.count == pinLength && index == 3)
        let color = if (focused && itemFocused) { Color.Supla.primary }
        else if (isError) { Color.Supla.error }
        else { Color.Supla.disabled }

        ZStack(alignment: .center) {
            if (index < value.count) {
                Circle()
                    .foregroundColor(color)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 48, height: 56)
        .background(RoundedRectangle(cornerRadius: 4).fill(Color.Supla.surface))
        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(color, lineWidth: 1))
    }
}

private extension View {
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

private enum TestFieldFocus: Hashable {}

#Preview("Empty") {
    @State var text = ""
    return TextField("", text: $text)
        .modifier(PinTextFieldModifier<TestFieldFocus>($text))
}

#Preview("One item") {
    @State var text = "1"
    return TextField("", text: $text)
        .modifier(PinTextFieldModifier<TestFieldFocus>($text))
}

#Preview("error") {
    @State var text = "11"
    return TextField("", text: $text)
        .modifier(
            PinTextFieldModifier<TestFieldFocus>($text)
                .error(true)
        )
}
