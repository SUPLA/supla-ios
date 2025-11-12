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

extension AddWizardFeature {
    struct AddWizardNetworkSelectionView: SwiftUI.View {
        @Binding var networkName: String
        @Binding var networkPassword: String
        @Binding var rememberPassword: Bool
        let error: Bool
        let onCancel: () -> Void
        let onBack: () -> Void
        let onNext: () -> Void
        let onNetworkSearch: () -> Void
        
        var body: some SwiftUI.View {
            AddWizardFeature.AddWizardScaffold(
                icon: .Image.AddWizard.step2,
                onCancel: onCancel,
                onNext: onNext,
                onBack: onBack
            ) {
                AddWizardFeature.AddWizardContentText(text: Strings.AddWizard.step2Message)
                
                TextFieldScaffold(label: Strings.AddWizard.networkName) {
                    TextField("", text: $networkName)
                        .textFieldStyle(StandardTextFieldStyle(error: error))
                        .autocorrectionDisabled(true)
                        .textContentType(.none)
                        .textInputAutocapitalization(.never)
                }
                TextFieldScaffold(label: Strings.General.password) {
                    VStack(spacing: Distance.tiny) {
                        PasswordTextField(text: $networkPassword, error: error)
                        Toggle(isOn: $rememberPassword) {
                            Text(Strings.AddWizard.rememberPassword)
                                .fontBodyMedium()
                                .textColor(.Supla.onPrimaryContainer)
                        }
                        .toggleStyle(iOSCheckboxToggleStyle(color: .onPrimaryContainer))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .bottom], Distance.tiny)
                        .padding(.leading, Distance.small)
                    }
                }
            }
        }
    }
}

private struct TextFieldScaffold<Content: View>: View {
    let label: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Distance.tiny) {
            TextFieldLabel(label, color: .Supla.onPrimaryContainer)
            content()
        }.padding([.leading, .trailing], Distance.default)
    }
}

#Preview {
    BackgroundStack(alignment: .top, color: .Supla.primaryContainer) {
        AddWizardFeature.AddWizardNetworkSelectionView(
            networkName: .constant("Ssid"),
            networkPassword: .constant("pass"),
            rememberPassword: .constant(true),
            error: false,
            onCancel: {},
            onBack: {},
            onNext: {},
            onNetworkSearch: {}
        )
    }
}
