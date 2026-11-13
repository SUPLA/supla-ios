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

private let contentDefaultPadding = EdgeInsets(
    top: 0,
    leading: Distance.default,
    bottom: Distance.small,
    trailing: Distance.default
)

extension SuplaCore.Dialog {
    struct Base<Content: View>: SwiftUI.View {
        let onDismiss: () -> Void
        let alignment: SwiftUICore.HorizontalAlignment
        let spacing: CGFloat
        let width: CGFloat?
        let content: Content
        
        @ObservedObject private var orientationObserver = OrientationObserver()
        
        init(
            onDismiss: @escaping () -> Void = {},
            alignment: SwiftUICore.HorizontalAlignment = .center,
            spacing: CGFloat = 0,
            width: CGFloat? = nil,
            @ViewBuilder _ content: () -> Content
        ) {
            self.onDismiss = onDismiss
            self.alignment = alignment
            self.spacing = spacing
            self.width = width
            self.content = content()
        }
        
        @ViewBuilder
        var body: some SwiftUI.View {
            let isLandscape = orientationObserver.orientation.isLandscape
            let width: CGFloat = self.width ?? (isLandscape ? 500 : 300)
            
            ZStack {
                Rectangle()
                    .fill(Color.Supla.dialogScrim)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            onDismiss()
                        }
                    }

                VStack(alignment: alignment, spacing: spacing) {
                    content
                }
                .frame(maxWidth: width)
                .background(Color.Supla.surface)
                .cornerRadius(Dimens.radiusDefault)
            }
        }
    }
    
    struct Content<Content: View>: SwiftUI.View {
        let alignment: SwiftUICore.HorizontalAlignment
        let spacing: CGFloat
        let padding: EdgeInsets
        let content: Content
        
        init(
            alignment: SwiftUICore.HorizontalAlignment = .leading,
            spacing: CGFloat = Distance.default,
            padding: EdgeInsets = contentDefaultPadding,
            @ViewBuilder _ content: () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.padding = padding
            self.content = content()
        }
        
        var body: some SwiftUI.View {
            VStack(alignment: alignment, spacing: spacing) {
                content
            }
            .padding([.leading, .trailing], Distance.default)
            .padding(.bottom, Distance.small)
        }
    }
    
    struct Header: SwiftUI.View {
        let title: String
        
        var body: some SwiftUI.View {
            VStack(spacing: 0) {
                Text(title)
                    .fontTitleLarge()
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .top, .trailing, .bottom], Distance.default)
            }
        }
    }
    
    struct Divider: SwiftUI.View {
        var body: some SwiftUI.View {
            SuplaCore.Divider().color(UIColor.grayLight)
        }
    }
    
    struct TextField: SwiftUI.View {
        let label: String?
        var value: Binding<String>
        let disabled: Bool
        
        init(value: Binding<String>, label: String? = nil, disabled: Bool = false) {
            self.value = value
            self.label = label
            self.disabled = disabled
        }
        
        var body: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                if let label {
                    SwiftUI.Text(value.wrappedValue.isEmpty ? "" : label.uppercased())
                        .fontBodySmall()
                        .textColor(.gray)
                }
                SwiftUI.TextField(label ?? "", text: value)
                    .disabled(disabled)
                    .fontBodyLarge()
            }
            .padding([.top, .bottom], Distance.tiny)
            .padding([.leading, .trailing], Distance.small)
            .background(disabled ? Color.clear : Color.Supla.surface)
            .clipShape(RoundedRectangle(cornerRadius: Dimens.buttonRadius))
            .overlay(RoundedRectangle(cornerRadius: Dimens.buttonRadius).stroke(Color.Supla.outline))
        }
    }
    
    struct Buttons: SwiftUI.View {
        let onNegativeClick: () -> Void
        let onPositiveClick: () -> Void
        let processing: Bool
        let positiveDisabled: Bool
        let negativeButtonText: String
        let positiveButtonText: String
        let positiveButtonFullWidth: Bool
        let positiveButtonColors: ButtonColors
        let padding: EdgeInsets?
        
        @ObservedObject private var orientationObserver = OrientationObserver()
        
        init(
            onSecondaryClick: @escaping () -> Void,
            onPrimaryClick: @escaping () -> Void,
            processing: Bool = false,
            primaryDisabled: Bool = false,
            secondaryText: String = Strings.General.cancel,
            primaryButtonData: ButtonData = .default(Strings.General.ok),
            padding: EdgeInsets? = nil
        ) {
            self.onNegativeClick = onSecondaryClick
            self.onPositiveClick = onPrimaryClick
            self.processing = processing
            self.positiveDisabled = primaryDisabled
            self.negativeButtonText = secondaryText
            self.positiveButtonText = primaryButtonData.title
            self.positiveButtonFullWidth = primaryButtonData.fullWidth
            self.positiveButtonColors = primaryButtonData.colors
            self.padding = padding
        }
        
        init(
            onNegativeClick: @escaping () -> Void,
            onPositiveClick: @escaping () -> Void,
            processing: Bool = false,
            positiveDisabled: Bool = false,
            negativeButtonText: String = Strings.General.cancel,
            positiveButtonText: String = Strings.General.ok,
            positiveButtonFullWidth: Bool = true,
            positiveButtonColors: ButtonColors = .primary,
            padding: EdgeInsets? = nil
        ) {
            self.onNegativeClick = onNegativeClick
            self.onPositiveClick = onPositiveClick
            self.processing = processing
            self.positiveDisabled = positiveDisabled
            self.negativeButtonText = negativeButtonText
            self.positiveButtonText = positiveButtonText
            self.positiveButtonFullWidth = positiveButtonFullWidth
            self.positiveButtonColors = positiveButtonColors
            self.padding = padding
        }
        
        @ViewBuilder
        var body: some SwiftUI.View {
            if (orientationObserver.orientation.isLandscape) {
                landscapeButtons
            } else {
                portraitButtons
            }
        }
        
        @ViewBuilder
        private var portraitButtons: some SwiftUI.View {
            VStack(spacing: Distance.tiny) {
                PositiveButton(
                    title: positiveButtonText,
                    fullWidth: positiveButtonFullWidth,
                    processing: processing,
                    colors: positiveButtonColors,
                    onClick: onPositiveClick
                )
                .disabled(positiveDisabled)
                NegativeButton(
                    title: negativeButtonText,
                    fullWidth: true,
                    onClick: onNegativeClick
                )
            }
            .padding(padding ?? SuplaCore.Dialog.Buttons.defaultPadding)
        }
        
        @ViewBuilder
        private var landscapeButtons: some SwiftUI.View {
            HStack(spacing: Distance.tiny) {
                NegativeButton(
                    title: negativeButtonText,
                    fullWidth: true,
                    onClick: onNegativeClick
                )
                PositiveButton(
                    title: positiveButtonText,
                    fullWidth: positiveButtonFullWidth,
                    processing: processing,
                    colors: positiveButtonColors,
                    onClick: onPositiveClick
                )
                .disabled(positiveDisabled)
            }
            .padding(padding ?? SuplaCore.Dialog.Buttons.defaultPadding)
        }
        
        private static let defaultPadding = EdgeInsets(
            top: Distance.default,
            leading: Distance.default,
            bottom: Distance.default,
            trailing: Distance.default
        )
    }
    
    struct PositiveButton: SwiftUI.View {
        let title: String
        let fullWidth: Bool
        let processing: Bool
        let colors: ButtonColors
        let onClick: () -> Void
        
        init(
            title: String,
            fullWidth: Bool = true,
            processing: Bool = false,
            colors: ButtonColors = .primary,
            onClick: @escaping () -> Void
        ) {
            self.title = title
            self.fullWidth = fullWidth
            self.processing = processing
            self.colors = colors
            self.onClick = onClick
        }
        
        init(
            buttonData: ButtonData,
            processing: Bool = false,
            onClick: @escaping () -> Void
        ) {
            self.title = buttonData.title
            self.fullWidth = buttonData.fullWidth
            self.processing = processing
            self.colors = buttonData.colors
            self.onClick = onClick
        }
        
        var body: some SwiftUI.View {
            if (processing) {
                ZStack {
                    ProgressView().progressViewStyle(.circular)
                }.if(fullWidth) { $0.frame(maxWidth: .infinity) }
            } else {
                TitleButton(
                    title: title,
                    fullWidth: fullWidth,
                    action: onClick
                )
                .filledButtonStyle(colors: colors)
            }
        }
    }
    
    struct NegativeButton: SwiftUI.View {
        let title: String
        let fullWidth: Bool
        let colors: ButtonColors
        let onClick: () -> Void
        
        init(
            title: String,
            fullWidth: Bool = true,
            colors: ButtonColors = .primary,
            onClick: @escaping () -> Void
        ) {
            self.title = title
            self.fullWidth = fullWidth
            self.colors = colors
            self.onClick = onClick
        }
        
        init(
            buttonData: ButtonData,
            onClick: @escaping () -> Void
        ) {
            self.title = buttonData.title
            self.fullWidth = buttonData.fullWidth
            self.colors = buttonData.colors
            self.onClick = onClick
        }
        
        var body: some SwiftUI.View {
            TitleButton(
                title: title,
                fullWidth: fullWidth,
                action: onClick
            )
            .textButtonStyle(colors: .onBackground)
        }
    }
    
    struct ButtonData {
        let title: String
        let fullWidth: Bool
        let colors: ButtonColors
        
        static func `default`(_ title: String, fullWidth: Bool = true) -> ButtonData {
            ButtonData(title: title, fullWidth: fullWidth, colors: .primary)
        }
        
        static func critical(_ title: String, fullWidth: Bool = true) -> ButtonData {
            ButtonData(title: title, fullWidth: fullWidth, colors: .criticalFilled)
        }
        
        static func optional(_ title: String?, fullWidth: Bool = true) -> ButtonData? {
            if let title {
                ButtonData(title: title, fullWidth: fullWidth, colors: .primary)
            } else {
                nil
            }
        }
    }
    
    struct FieldErrorText: SwiftUI.View {
        let text: String
        
        init(_ text: String) {
            self.text = text
        }
        
        var body: some SwiftUI.View {
            Text(text)
                .fontTitleSmall()
                .textColor(Color.Supla.error)
                .padding([.leading], Distance.small)
                .padding(.top, 2)
        }
    }
}

#Preview {
    VStack {
        SuplaCore.Dialog.Base(onDismiss: {}) {
            SuplaCore.Dialog.Header(title: "Header")
            
            SuplaCore.Dialog.Content {
                SuplaCore.Dialog.TextField(value: .constant("Value"), label: "Label")
                    .padding([.leading, .trailing], Distance.default)
                SuplaCore.Dialog.TextField(value: .constant(""), label: "Label")
                    .padding([.leading, .trailing], Distance.default)
            }
            
            SuplaCore.Dialog.Buttons(
                onSecondaryClick: {},
                onPrimaryClick: {}
            )
        }
    }
}
