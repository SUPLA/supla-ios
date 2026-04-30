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
    
extension RgbDetailFeature {
    enum ColorDialog {
        protocol Delegate: AnyObject {
            func onColorDialogDismiss()
            func onColorDialogConfirm(_ color: UIColor?)
        }
        
        struct View: SwiftUI.View {
            weak var delegate: Delegate?
            
            init(colorString: String, delegate: Delegate? = nil) {
                self.delegate = delegate
                self._colorFieldValue = State(initialValue: colorString)
                self._color = State(initialValue: colorString.toColorOrNull())
            }
            
            @State private var colorFieldValue: String
            @State private var color: UIColor?
            
            var body: some SwiftUI.View {
                SuplaCore.Dialog.Base(onDismiss: {}) {
                    SuplaCore.Dialog.Header(title: Strings.RgbDetail.selectColor)
                    
                    SuplaCore.Dialog.Content(alignment: .center) {
                        ColorTextField(value: $colorFieldValue, label: Strings.RgbDetail.color, color: color)
                    }
                    
                    SuplaCore.Dialog.DoubleButtons(
                        onSecondaryClick: { delegate?.onColorDialogDismiss() },
                        onPrimaryClick: { delegate?.onColorDialogConfirm(color) },
                        primaryDisabled: color == nil
                    )
                    .onChange(of: colorFieldValue) { color = $0.toColorOrNull() }
                }
            }
        }
        
        struct ColorTextField: SwiftUI.View {
            let label: String?
            let color: UIColor?
            var value: Binding<String>
            
            init(value: Binding<String>, label: String? = nil, color: UIColor? = nil) {
                self.value = value
                self.label = label
                self.color = color
            }
            
            var body: some SwiftUI.View {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        if let label {
                            SwiftUI.Text(value.wrappedValue.isEmpty ? "" : label.uppercased())
                                .fontBodySmall()
                                .textColor(.gray)
                        }
                        SwiftUI.TextField(label ?? "", text: value)
                            .fontBodyLarge()
                    }
                    .frame(maxWidth: .infinity)
                    
                    RgbDetailFeature.ColorBox(color: color)
                }
                .padding([.top, .bottom], Distance.tiny)
                .padding([.leading, .trailing], Distance.small)
                .clipShape(RoundedRectangle(cornerRadius: Dimens.buttonRadius))
                .overlay(RoundedRectangle(cornerRadius: Dimens.buttonRadius).stroke(Color.Supla.outline))
            }
        }
    }
}

#Preview {
    RgbDetailFeature.ColorDialog.View(colorString: "#FF0000")
}
