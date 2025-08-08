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
    protocol ProvidePasswordDialogDelegate: AnyObject {
        func onCloseProvidePasswordDialog()
        func onPasswordProvided(_ password: String)
    }
    
    struct ProvidePasswordDialogState: Changeable {
        var error: String?
        var processing: Bool
        var ssid: String?

        init(error: String? = nil, processing: Bool = false, ssid: String? = nil) {
            self.error = error
            self.processing = processing
            self.ssid = ssid
        }
    }

    struct ProvidePasswordDialog: SwiftUI.View {
        let state: ProvidePasswordDialogState
        weak var delegate: ProvidePasswordDialogDelegate?
        
        @State private var password: String = ""

        var body: some SwiftUI.View {
            SuplaCore.Dialog.Base(onDismiss: {}) {
                SuplaCore.Dialog.Header(title: Strings.AddWizard.passwordEnterTitle)
                
                SuplaCore.Dialog.Content {
                    if let ssid = state.ssid {
                        Text(ssid)
                            .fontLabelMedium()
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        PasswordTextField(
                            title: Strings.General.password.uppercased(),
                            text: $password,
                            disabled: state.processing,
                            error: state.error != nil
                        )
                        .onSubmitCompat { delegate?.onPasswordProvided(password) }
                        .submitLabelCompat(.go)
                        if let error = state.error {
                            SuplaCore.Dialog.FieldErrorText(error)
                        }
                    }
                    Text(Strings.AddWizard.passwordInstruction)
                        .fontBodySmall()
                        .textColor(Color.Supla.onSurfaceVariant)
                }
                
                SuplaCore.Dialog.DoubleButtons(
                    onNegativeClick: { delegate?.onCloseProvidePasswordDialog() },
                    onPositiveClick: { delegate?.onPasswordProvided(password) },
                    processing: state.processing,
                    positiveDisabled: password.isEmpty,
                    negativeText: Strings.General.cancel,
                    positiveText: Strings.General.ok
                )
            }
        }
    }
}

#Preview {
    AddWizardFeature.ProvidePasswordDialog(
        state: AddWizardFeature.ProvidePasswordDialogState(
            error: Strings.General.incorrectPassword,
            ssid: "SUPLA-EXAMPLE-78218479E27C"
        )
    )
}

#Preview("Processing") {
    AddWizardFeature.ProvidePasswordDialog(
        state: AddWizardFeature.ProvidePasswordDialogState(
            processing: true,
            ssid: "SUPLA-EXAMPLE-78218479E27C"
        )
    )
}
