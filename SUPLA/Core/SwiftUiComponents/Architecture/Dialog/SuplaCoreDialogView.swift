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

extension SuplaCore.Dialog {
    struct Base<Content: View>: SwiftUI.View {
        let onDismiss: () -> Void
        let alignment: SwiftUICore.HorizontalAlignment
        let spacing: CGFloat
        let content: Content
        
        init(
            onDismiss: @escaping () -> Void = {},
            alignment: SwiftUICore.HorizontalAlignment = .center,
            spacing: CGFloat = 0,
            @ViewBuilder _ content: () -> Content
        ) {
            self.onDismiss = onDismiss
            self.alignment = alignment
            self.spacing = spacing
            self.content = content()
        }
        
        var body: some SwiftUI.View {
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
                .frame(maxWidth: UIScreen.main.bounds.size.width - 50)
                .background(Color.Supla.surface)
                .cornerRadius(Dimens.radiusDefault)
            }
        }
    }
    
    struct Content<Content: View>: SwiftUI.View {
        let alignment: SwiftUICore.HorizontalAlignment
        let spacing: CGFloat
        let content: Content
        
        init(
            alignment: SwiftUICore.HorizontalAlignment = .leading,
            spacing: CGFloat = Distance.default,
            @ViewBuilder _ content: () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content()
        }
        
        var body: some SwiftUI.View {
            VStack(alignment: alignment, spacing: spacing) {
                content
            }
            .padding([.leading, .trailing], Distance.default)
        }
    }
    
    struct Header: SwiftUI.View {
        let title: String
        
        var body: some SwiftUI.View {
            VStack(spacing: 0) {
                Text(title)
                    .fontHeadlineSmall()
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .top, .trailing, .bottom], Distance.default)
                Divider()
            }
            .padding([.bottom], Distance.default)
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
    
    struct DoubleButtons: SwiftUI.View {
        let onNegativeClick: () -> Void
        let onPositiveClick: () -> Void
        let processing: Bool
        let positiveDisabled: Bool
        let negativeText: String
        let positiveText: String
        
        init(
            onNegativeClick: @escaping () -> Void,
            onPositiveClick: @escaping () -> Void,
            processing: Bool = false,
            positiveDisabled: Bool = false,
            negativeText: String = Strings.General.cancel,
            positiveText: String = Strings.General.ok
        ) {
            self.onNegativeClick = onNegativeClick
            self.onPositiveClick = onPositiveClick
            self.processing = processing
            self.positiveDisabled = positiveDisabled
            self.negativeText = negativeText
            self.positiveText = positiveText
        }
        
        var body: some SwiftUI.View {
            Divider()
                .padding(.top, Distance.default)
            HStack(spacing: Distance.tiny) {
                BorderedButton(
                    title: negativeText,
                    fullWidth: true,
                    action: onNegativeClick
                )
                if (processing) {
                    ZStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }.frame(maxWidth: .infinity)
                } else {
                    FilledButton(
                        title: positiveText,
                        fullWidth: true,
                        action: onPositiveClick
                    ).disabled(positiveDisabled)
                }
            }
            .padding(Distance.default)
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
            
            SuplaCore.Dialog.DoubleButtons(
                onNegativeClick: {},
                onPositiveClick: {}
            )
        }
    }
}
