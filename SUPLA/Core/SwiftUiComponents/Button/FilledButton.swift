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
    let buttonSpec: ButtonSpec
    let action: () -> Void
    
    @Environment(\.isEnabled) var isEnabled
    
    init(buttonSpec: ButtonSpec, action: @escaping () -> Void) {
        self.buttonSpec = buttonSpec
        self.action = action
    }
    
    init(title: String, fullWidth: Bool = false, action: @escaping () -> Void) {
        self.buttonSpec = .default(title, fullWidth: fullWidth)
        self.action = action
    }
    
    var body: some View {
        return Button(action: action) {
            Text(buttonSpec.text)
                .fontLabelLarge()
                .if(buttonSpec.fullWidth) { $0.frame(maxWidth: .infinity) }
        }
        .buttonStyle(
            FilledButtonStyle(
                isEnabled: isEnabled,
                backgroundColor: buttonSpec.backgroundColor
            )
        )
    }
    
    enum ButtonSpec {
        case `default`(String = Strings.General.ok, fullWidth: Bool = true)
        case critical(String = Strings.General.delete, fullWidth: Bool = true)
        
        var withFullWidth: ButtonSpec {
            switch (self) {
            case .default(let text, _): .default(text, fullWidth: true)
            case .critical(let text, _): .critical(text, fullWidth: true)
            }
        }
        
        var text: String {
            switch (self) {
            case .default(let text, _): text
            case .critical(let text, _): text
            }
        }
        
        var fullWidth: Bool {
            switch (self) {
            case .default(_, let width): width
            case .critical(_, let width): width
            }
        }
        
        var textColor: ButtonColorSpec {
            switch (self) {
            case .default(_, _): .primaryText
            case .critical(_, _): .criticalText
            }
        }
        
        var backgroundColor: ButtonColorSpec {
            switch (self) {
            case .default(_, _): .primaryBackground
            case .critical(_, _): .criticalBackground
            }
        }
        
        static func optional(_ title: String?, fullWidth: Bool = true) -> ButtonSpec? {
            if let title {
                .default(title, fullWidth: fullWidth)
            } else {
                nil
            }
        }
        
        static func criticalOptional(_ title: String?, fullWidth: Bool = true) -> ButtonSpec? {
            if let title {
                .critical(title, fullWidth: fullWidth)
            } else {
                nil
            }
        }
    }
}

#Preview {
    VStack {
        FilledButton(title: "Title") {}
        FilledButton(title: "Title", fullWidth: true) {}
        FilledButton(buttonSpec: .critical("Title", fullWidth: true)) {}
    }
    .padding(Distance.default)
}

struct FilledButtonStyle: ButtonStyle {
    private let isEnabled: Bool
    private let textColor: ButtonColorSpec
    private let backgroundColor: ButtonColorSpec
    
    init(
        isEnabled: Bool,
        textColor: ButtonColorSpec = .primaryText,
        backgroundColor: ButtonColorSpec = .primaryBackground
    ) {
        self.isEnabled = isEnabled
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(textColor.value(disabled: !isEnabled, pressed: configuration.isPressed))
            .font(.Supla.labelLarge)
            .padding(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
            .background(backgroundColor.value(disabled: !isEnabled, pressed: configuration.isPressed))
            .cornerRadius(Dimens.buttonRadius)
    }
}
