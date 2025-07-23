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
        let content: Content
        
        init(onDismiss: @escaping () -> Void = {}, @ViewBuilder _ content: () -> Content) {
            self.onDismiss = onDismiss
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

                content
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 50)
                    .background(Color.Supla.surface)
                    .cornerRadius(Dimens.radiusDefault)
            }
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
}

#Preview {
    VStack {
        SuplaCore.Dialog.TextField(value: .constant("Value"), label: "Label")
        SuplaCore.Dialog.TextField(value: .constant(""), label: "Label")
    }
}
